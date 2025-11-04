/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions/v2";
import {onRequest, onCall} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {parse} from "csv-parse/sync";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions applies to v2 functions
// This sets default options for all v2 functions unless overridden
// Runtime is set in package.json engines field (Node.js 20)
setGlobalOptions({
  maxInstances: 10,
});

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ======= ADVANCED MATCHING SYSTEM FUNCTION =======
/**
 * Advanced matching system based on new registration flow
 * - Matches users based on skillsOffering, skillsSeeking, purposes,
 *   and businessNeeds
 * - Sends push notifications to matched users
 * - Uses complementary matching logic for purposes
 */
export const runAdvancedMatching = onRequest({
  cors: true,
  memory: "2GiB",
  timeoutSeconds: 540,
}, async (req, res) => {
  try {
    logger.info("Starting advanced matching system...");

    // Get all user profiles
    const profilesSnapshot = await db.collection("Profiles").get();
    const profiles = profilesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as any[];

    logger.info(`Found ${profiles.length} user profiles`);

    if (profiles.length < 2) {
      res.json({
        success: true,
        message: "Not enough users for matching",
        matches: 0,
        notifications: 0,
      });
      return;
    }

    const matches = [];
    const notifications = [];

    // Process each user
    for (let i = 0; i < profiles.length; i++) {
      const user = profiles[i];

      // Debug: Log available fields for first few users
      if (i < 3) {
        logger.info(`User ${user.id} fields:`, Object.keys(user));
        logger.info(`User ${user.id} Skills Offering:`,
          user["Skills Offering"]);
        logger.info(`User ${user.id} Skills Seeking:`,
          user["Skills Seeking"]);
      }

      // Check for skills data in both new and old formats
      const skillsOffering = user["Skills Offering"] || user["skillsOffering"];
      const skillsSeeking = user["Skills Seeking"] || user["skillsSeeking"];
      if (!skillsOffering || !skillsSeeking) {
        logger.info(`Skipping user ${user.id} - missing skills data`);
        continue;
      }

      logger.info(`Processing user ${user.id}...`);

      // Find matches for this user
      const userMatches = findMatchesForUser(user, profiles);

      if (userMatches.length > 0) {
        matches.push({
          userId: user.id,
          matches: userMatches,
        });

        // Send notification to user about new matches
        try {
          const notification = {
            title: "New Matches Found! 🎯",
            body: `You have ${userMatches.length} new potential connections`,
            data: {
              type: "new_matches",
              userId: user.id,
              matchCount: userMatches.length.toString(),
            },
          };

          // Send to user's FCM token if available
          if (user.fcmToken) {
            await admin.messaging().send({
              token: user.fcmToken,
              notification: {
                title: notification.title,
                body: notification.body,
              },
              data: notification.data,
            });
            notifications.push({userId: user.id, sent: true});
          } else {
            // Send to general topic as fallback
            await admin.messaging().send({
              topic: "general",
              notification: {
                title: notification.title,
                body: notification.body,
              },
              data: {
                ...notification.data,
                targetUserId: user.id,
              },
            });
            notifications.push({userId: user.id, sent: true, method: "topic"});
          }
        } catch (notificationError: any) {
          logger.error(
            `Error sending notification to user ${user.id}:`,
            notificationError,
          );
          notifications.push({
            userId: user.id,
            sent: false,
            error: notificationError.message,
          });
        }
      }
    }

    logger.info(
      `Matching completed. Found ${matches.length} users with matches, ` +
      `sent ${notifications.filter((n) => n.sent).length} notifications`,
    );

    // Helper function to remove undefined values from objects
    const removeUndefinedValues = (obj: any): any => {
      if (obj === null || obj === undefined) return null;
      if (typeof obj !== "object") return obj;
      if (Array.isArray(obj)) {
        return obj.map(removeUndefinedValues).filter(
          (item) => item !== undefined,
        );
      }
      const cleaned: any = {};
      for (const [key, value] of Object.entries(obj)) {
        if (value !== undefined) {
          cleaned[key] = removeUndefinedValues(value);
        }
      }
      return cleaned;
    };

    // Save matches to Firestore
    try {
      const timestamp = admin.firestore.FieldValue.serverTimestamp();

      logger.info(
        "Preparing to save " + matches.length + " matches to " +
        "SkillMatches collection",
      );

      let savedCount = 0;
      for (const userMatch of matches) {
        try {
          const matchDocRef = db.collection("SkillMatches")
            .doc(userMatch.userId);
          const userProfile = profiles.find((p) => p.id === userMatch.userId);

          // Clean the matches data to remove undefined values
          const cleanedMatches = removeUndefinedValues(userMatch.matches);
          const matchData = {
            userId: userMatch.userId,
            fullName: userProfile?.["Full Name"] || "Unknown",
            matches: cleanedMatches,
            totalMatches: cleanedMatches.length,
            createdAt: timestamp,
            updatedAt: timestamp,
          };

          logger.info(
            `Saving match for user ${userMatch.userId} directly to Firestore`,
          );
          await matchDocRef.set(matchData, {merge: true});
          savedCount++;
          logger.info(
            `Successfully saved match for user ${userMatch.userId}`,
          );
        } catch (userError: any) {
          logger.error(
            `Error saving match for user ${userMatch.userId}:`,
            userError,
          );
        }
      }

      logger.info(
        "Successfully saved " + savedCount + " out of " + matches.length +
        " match records to SkillMatches collection",
      );
    } catch (firestoreError: any) {
      logger.error("Error saving matches to Firestore:", firestoreError);
      logger.error("Firestore error details:", {
        code: firestoreError.code,
        message: firestoreError.message,
        stack: firestoreError.stack,
      });
      // Don't fail the function if Firestore save fails
    }

    res.json({
      success: true,
      totalUsers: profiles.length,
      usersWithMatches: matches.length,
      totalMatches: matches.reduce((sum, m) => sum + m.matches.length, 0),
      notificationsSent: notifications.filter((n) => n.sent).length,
      matches: matches,
      notifications: notifications,
    });
  } catch (error: any) {
    logger.error("Advanced matching failed:", error);
    res.status(500).json({
      success: false,
      error: error.message || "Matching failed",
    });
  }
});

/**
 * Find matches for a specific user based on the new matching criteria
 * @param {any} user - The user to find matches for
 * @param {any[]} allProfiles - All user profiles to match against
 * @return {any[]} Array of top 5 matches for the user
 */
function findMatchesForUser(user: any, allProfiles: any[]): any[] {
  const matches = [];

  for (const otherUser of allProfiles) {
    // Skip self
    if (otherUser.id === user.id) continue;

    // Skip if other user doesn't have required data (new registration flow)
    if (!otherUser["Skills Offering"] || !otherUser["Skills Seeking"]) continue;

    let matchScore = 0;
    const matchReasons = [];

    // 1. Skills Matching (40% weight)
    const skillsScore = calculateSkillsMatch(user, otherUser);
    matchScore += skillsScore.score * 0.4;
    if (skillsScore.score > 0) {
      matchReasons.push(...skillsScore.reasons);
    }

    // 2. Purpose Matching (30% weight) - Optional for new registration
    const purposeScore = calculatePurposeMatch(user, otherUser);
    matchScore += purposeScore.score * 0.3;
    if (purposeScore.score > 0) {
      matchReasons.push(...purposeScore.reasons);
    }

    // 3. Business Needs Matching (20% weight) - Optional for new registration
    const businessScore = calculateBusinessMatch(user, otherUser);
    matchScore += businessScore.score * 0.2;
    if (businessScore.score > 0) {
      matchReasons.push(...businessScore.reasons);
    }

    // 4. Experience Level Compatibility (10% weight) - Optional
    const experienceScore = calculateExperienceMatch(user, otherUser);
    matchScore += experienceScore.score * 0.1;
    if (experienceScore.score > 0) {
      matchReasons.push(...experienceScore.reasons);
    }

    // Only include matches with score > 0.3 (30% compatibility)
    if (matchScore > 0.3) {
      matches.push({
        userId: otherUser.id,
        name: otherUser["Full Name"] || "Unknown",
        score: Math.round(matchScore * 100) / 100,
        reasons: matchReasons,
        skillsOffering: otherUser["Skills Offering"] ||
          otherUser["skillsOffering"] || [],
        skillsSeeking: otherUser["Skills Seeking"] ||
          otherUser["skillsSeeking"] || [],
        purposes: otherUser.purposes || otherUser["Purposes"] || [],
        businessNeeds: otherUser.businessNeeds ||
          otherUser["Business Needs"] || [],
        experienceLevel: otherUser.experienceLevel ||
          otherUser["Experience Level"],
      });
    }
  }

  // Sort by score (highest first) and return top 5 matches
  return matches.sort((a, b) => b.score - a.score).slice(0, 5);
}

/**
 * Calculate skills matching score (updated for new registration flow)
 * - User's "Skills Offering" should match other's "Skills Seeking"
 * - Simple array-to-array matching with exact string comparison
 * @param {any} user - The user to calculate skills match for
 * @param {any} otherUser - The other user to match against
 * @return {{score: number, reasons: string[]}} Skills match score and reasons
 */
function calculateSkillsMatch(user: any, otherUser: any): {
  score: number;
  reasons: string[];
} {
  let score = 0;
  const reasons = [];

  const userOffering = user["Skills Offering"] ||
    user["skillsOffering"] || [];
  const otherSeeking = otherUser["Skills Seeking"] ||
    otherUser["skillsSeeking"] || [];

  // Ensure they are arrays
  const userOfferingArray = Array.isArray(userOffering) ? userOffering : [];
  const otherSeekingArray = Array.isArray(otherSeeking) ? otherSeeking : [];

  if (userOfferingArray.length === 0 || otherSeekingArray.length === 0) {
    return {score: 0, reasons: []};
  }

  // Check for exact matches between user's offering and other's seeking
  for (const userSkill of userOfferingArray) {
    if (otherSeekingArray.includes(userSkill)) {
      score += 1.0; // Full weight for exact match
      reasons.push(`Your ${userSkill} skills match their needs`);
    }
  }

  // Also check reverse - other's offering matches user's seeking
  const userSeeking = user["Skills Seeking"] ||
    user["skillsSeeking"] || [];
  const otherOffering = otherUser["Skills Offering"] ||
    otherUser["skillsOffering"] || [];

  // Ensure they are arrays
  const userSeekingArray = Array.isArray(userSeeking) ? userSeeking : [];
  const otherOfferingArray = Array.isArray(otherOffering) ? otherOffering : [];

  for (const otherSkill of otherOfferingArray) {
    if (userSeekingArray.includes(otherSkill)) {
      score += 1.0; // Full weight for reverse match
      reasons.push(`They offer ${otherSkill} which you're seeking`);
    }
  }

  // Normalize score to 0-1 range
  const maxPossibleMatches = Math.max(
    userOfferingArray.length, userSeekingArray.length);
  const normalizedScore = maxPossibleMatches > 0 ?
    Math.min(score / maxPossibleMatches, 1) : 0;

  return {score: normalizedScore, reasons};
}

/**
 * Calculate purpose matching score (updated for new registration flow)
 * - Look for complementary purposes (if available)
 * - Returns neutral score if no purposes data
 * @param {any} user - The user to calculate purpose match for
 * @param {any} otherUser - The other user to match against
 * @return {{score: number, reasons: string[]}} Purpose match score and reasons
 */
function calculatePurposeMatch(user: any, otherUser: any): {
  score: number;
  reasons: string[];
} {
  let score = 0;
  const reasons = [];

  const userPurposes = user.purposes || user["Purposes"] || [];
  const otherPurposes = otherUser.purposes || otherUser["Purposes"] || [];

  // If no purposes data, return neutral score
  if (userPurposes.length === 0 && otherPurposes.length === 0) {
    return {score: 0.5, reasons: ["No purpose data to match"]};
  }

  // Define complementary purpose pairs
  const complementaryPairs = [
    ["Looking to Hire", "Looking to get hired"],
    ["Starting a business", "Looking to invest in a start up"],
    ["Networking", "Networking"], // Same purpose is also good
  ];

  for (const [userPurpose, otherPurpose] of complementaryPairs) {
    if (userPurposes.includes(userPurpose) &&
        otherPurposes.includes(otherPurpose)) {
      score += 1.0;
      reasons.push(`${userPurpose} matches with ${otherPurpose}`);
    }
  }

  // Also check for exact matches (same purposes)
  for (const userPurpose of userPurposes) {
    if (otherPurposes.includes(userPurpose)) {
      score += 0.5; // Lower weight for exact matches
      reasons.push(`Both interested in ${userPurpose}`);
    }
  }

  // Normalize to 0-1 range
  const normalizedScore = Math.min(score / 2, 1);

  return {score: normalizedScore, reasons};
}

/**
 * Calculate business needs matching score (updated for new registration flow)
 * - Look for complementary business needs (if available)
 * - Returns neutral score if no business needs data
 * @param {any} user - The user to calculate business match for
 * @param {any} otherUser - The other user to match against
 * @return {{score: number, reasons: string[]}} Business match score and reasons
 */
function calculateBusinessMatch(user: any, otherUser: any): {
  score: number;
  reasons: string[];
} {
  let score = 0;
  const reasons = [];

  const userBusinessNeeds = user.businessNeeds ||
    user["Business Needs"] || [];
  const otherBusinessNeeds = otherUser.businessNeeds ||
    otherUser["Business Needs"] || [];

  // If no business needs data, return neutral score
  if (userBusinessNeeds.length === 0 && otherBusinessNeeds.length === 0) {
    return {score: 0.5, reasons: ["No business needs to match"]};
  }

  // Check for complementary business needs
  const complementaryBusinessNeeds = [
    ["Funding", "Wants to invest in a business"],
    ["Expertise", "Looking for a mentor"],
    ["To Hire", "Looking to hire candidates"],
  ];

  for (const [userNeed, otherPurpose] of complementaryBusinessNeeds) {
    if (userBusinessNeeds.includes(userNeed) &&
        (otherUser.purposes?.includes(otherPurpose) ||
         otherUser["Purposes"]?.includes(otherPurpose))) {
      score += 1.0;
      reasons.push(
        `Your ${userNeed} need matches their ${otherPurpose} purpose`,
      );
    }
  }

  // Check for exact business need matches
  for (const userNeed of userBusinessNeeds) {
    if (otherBusinessNeeds.includes(userNeed)) {
      score += 0.3; // Lower weight for exact matches
      reasons.push(`Both need ${userNeed}`);
    }
  }

  const normalizedScore = Math.min(score / 2, 1);
  return {score: normalizedScore, reasons};
}

/**
 * Calculate experience level compatibility (updated for new registration flow)
 * - Look for compatible experience levels (if available)
 * - Returns neutral score if no experience level data
 * @param {any} user - The user to calculate experience match for
 * @param {any} otherUser - The other user to match against
 * @return {{score: number, reasons: string[]}} Experience match score
 */
function calculateExperienceMatch(user: any, otherUser: any): {
  score: number;
  reasons: string[];
} {
  const userLevel = user.experienceLevel || user["Experience Level"];
  const otherLevel = otherUser.experienceLevel || otherUser["Experience Level"];

  if (!userLevel || !otherLevel) {
    return {score: 0.5, reasons: ["Experience level not specified"]};
  }

  // Define compatible experience level pairs
  const compatiblePairs = [
    ["Entry", "Mid"],
    ["Entry", "Senior"],
    ["Mid", "Senior"],
    ["Mid", "Entry"],
    ["Senior", "Mid"],
    ["Senior", "Entry"],
    ["Retired", "Senior"],
    ["Retired", "Mid"],
  ];

  for (const [level1, level2] of compatiblePairs) {
    if ((userLevel === level1 && otherLevel === level2) ||
        (userLevel === level2 && otherLevel === level1)) {
      return {
        score: 1.0,
        reasons: [
          `${userLevel} and ${otherLevel} experience levels are compatible`,
        ],
      };
    }
  }

  // Same level is also good
  if (userLevel === otherLevel) {
    return {
      score: 0.8,
      reasons: [`Both have ${userLevel} experience level`],
    };
  }

  return {
    score: 0.3,
    reasons: ["Experience levels may not be ideal match"],
  };
}

// ======= NOTIFICATION FUNCTIONS =======
/**
 * Sends push notification for new connection requests
 * @param {string} fromUserId - ID of the user sending the request
 * @param {string} toUserId - ID of the user receiving the request
 */
async function sendConnectionRequestNotification(
  fromUserId: string,
  toUserId: string,
) {
  try {
    const senderProfile = await db.collection("Profiles")
      .doc(fromUserId).get();
    if (!senderProfile.exists) {
      logger.warn(`Sender profile not found for user: ${fromUserId}`);
      return;
    }

    const senderData = senderProfile.data();
    const senderName = senderData?.["Full Name"] || "Someone";

    const recipientProfile = await db.collection("Profiles")
      .doc(toUserId).get();
    if (!recipientProfile.exists) {
      logger.warn(`Recipient profile not found for user: ${toUserId}`);
      return;
    }

    const recipientData = recipientProfile.data();
    const fcmToken = recipientData?.["fcmToken"];

    if (!fcmToken) {
      logger.warn(`No FCM token found for user: ${toUserId}`);
      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "New Connection Request! 🔗",
        body: `${senderName} wants to connect with you!`,
      },
      data: {
        type: "connection_request",
        fromUserId: fromUserId,
        toUserId: toUserId,
        senderName: senderName,
      },
      android: {
        notification: {
          icon: "ic_notification",
          color: "#FF7E00",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    logger.info(
      `Connection request notification sent successfully: ${response}`,
    );
  } catch (error) {
    logger.error("Error sending connection request notification:", error);
  }
}

/**
 * Sends push notification for new matches
 * @param {string} user1Id - ID of the first user in the match
 * @param {string} user2Id - ID of the second user in the match
 */
async function sendMatchNotificationHelper(user1Id: string, user2Id: string) {
  try {
    const [user1Profile, user2Profile] = await Promise.all([
      db.collection("Profiles").doc(user1Id).get(),
      db.collection("Profiles").doc(user2Id).get(),
    ]);

    const user1Data = user1Profile.data();
    const user2Data = user2Profile.data();
    const user1Name = user1Data?.["Full Name"] || "Someone";
    const user2Name = user2Data?.["Full Name"] || "Someone";
    const user1FcmToken = user1Data?.["fcmToken"];
    const user2FcmToken = user2Data?.["fcmToken"];

    if (user2FcmToken) {
      const message1 = {
        token: user2FcmToken,
        notification: {
          title: "🎉 It's a Match!",
          body: `You and ${user1Name} are now connected!`,
        },
        data: {
          type: "match",
          user1Id: user1Id,
          user2Id: user2Id,
          matchName: user1Name,
        },
        android: {
          notification: {
            icon: "ic_notification",
            color: "#FF7E00",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      await admin.messaging().send(message1);
      logger.info(`Match notification sent to user1: ${user1Id}`);
    }

    if (user1FcmToken) {
      const message2 = {
        token: user1FcmToken,
        notification: {
          title: "🎉 It's a Match!",
          body: `You and ${user2Name} are now connected!`,
        },
        data: {
          type: "match",
          user1Id: user1Id,
          user2Id: user2Id,
          matchName: user2Name,
        },
        android: {
          notification: {
            icon: "ic_notification",
            color: "#FF7E00",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      await admin.messaging().send(message2);
      logger.info(`Match notification sent to user2: ${user2Id}`);
    }
  } catch (error) {
    logger.error("Error sending match notification:", error);
  }
}

// ======= USER CONNECTION FUNCTION =======
/**
 * Handles user connection logic when a user connects with another user
 * - Records the connection request
 * - Checks for mutual like
 * - Creates match if mutual like exists
 * - Creates chat room for matched users
 */
export const handleUserConnection = onCall(async (request) => {
  try {
    const {fromUserId, toUserId} = request.data;

    if (!fromUserId || !toUserId) {
      throw new Error("fromUserId and toUserId are required");
    }

    logger.info(
      `Processing connection request from ${fromUserId} to ${toUserId}`,
    );

    // Step 1: Record the connection request
    const connectData = {
      fromUserId: fromUserId,
      toUserId: toUserId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };

    const connectRef = await db.collection("Connects").add(connectData);
    logger.info(`Connection request recorded with ID: ${connectRef.id}`);

    // Step 2: Check for mutual like
    const mutualLikeQuery = await db.collection("Connects")
      .where("fromUserId", "==", toUserId)
      .where("toUserId", "==", fromUserId)
      .get();

    if (mutualLikeQuery.empty) {
      logger.info(`No mutual like found between ${fromUserId} and ${toUserId}`);

      // Send notification for new connection request
      await sendConnectionRequestNotification(fromUserId, toUserId);

      return {
        success: true,
        message: "Connection request sent",
        isMatch: false,
        connectId: connectRef.id,
      };
    }

    logger.info(`Mutual like detected between ${fromUserId} and ${toUserId}`);

    // Step 3: Create match and delete connection requests
    const batch = db.batch();

    // Create match document
    const matchData = {
      user1Id: fromUserId,
      user2Id: toUserId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
    const matchRef = db.collection("Matches").doc();
    batch.set(matchRef, matchData);

    // Delete both connection requests
    batch.delete(connectRef);
    for (const doc of mutualLikeQuery.docs) {
      batch.delete(doc.ref);
    }

    await batch.commit();
    logger.info("Match created and connection requests deleted");

    // Send match notification to both users
    await sendMatchNotificationHelper(fromUserId, toUserId);

    // Step 4: Create chat room
    const participants = [fromUserId, toUserId].sort();

    // Check if chat room already exists
    const existingChatQuery = await db.collection("ChatRooms")
      .where("participants", "==", participants)
      .get();

    if (existingChatQuery.empty) {
      const chatRoomData = {
        participants: participants,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessage: "",
        lastMessageTimestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db.collection("ChatRooms").add(chatRoomData);
      logger.info(`Chat room created for ${fromUserId} and ${toUserId}`);
    } else {
      logger.info(
        `Chat room already exists between ${fromUserId} and ${toUserId}`,
      );
    }

    return {
      success: true,
      message: "Match created successfully!",
      isMatch: true,
      matchId: matchRef.id,
    };
  } catch (error) {
    logger.error("Error in handleUserConnection:", error);
    throw new Error(`Connection failed: ${error}`);
  }
});

/**
 * Send notification for new connection request
 * Using v2 API with onDocumentCreated
 */
export const notifyOnNewConnectionRequest = onDocumentCreated(
  {
    document: "Connects/{connectionId}",
    region: "us-central1",
  },
  async (event) => {
    logger.info("=== notifyOnNewConnectionRequest TRIGGERED ===");
    logger.info(`Connection ID: ${event.params.connectionId}`);
    
    const connectionData = event.data?.data();
    
    if (!connectionData) {
      logger.error("No connection data found in event.data");
      return;
    }
    
    logger.info("Connection data:", JSON.stringify(connectionData, null, 2));
    
    const toUserId = connectionData.toUserId;
    const fromUserId = connectionData.fromUserId;
    
    if (!toUserId || !fromUserId) {
      logger.error("Missing required fields in connection data");
      logger.error(`toUserId: ${toUserId}, fromUserId: ${fromUserId}`);
      return;
    }
    
    logger.info(`Processing connection request: ${fromUserId} -> ${toUserId}`);
    
    try {
      // Get recipient's FCM token
      logger.info(`Fetching recipient profile for userId: ${toUserId}`);
      const recipientDoc = await db.collection("Profiles").doc(toUserId).get();
      
      if (!recipientDoc.exists) {
        logger.error(`Recipient profile not found for userId: ${toUserId}`);
        return;
      }
      
      const recipientData = recipientDoc.data();
      logger.info(`Recipient profile found. Available fields: ${Object.keys(recipientData || {}).join(", ")}`);
      
      // Check for FCM token - handle null, undefined, or empty string
      const fcmTokenValue = recipientData?.["fcmToken"] || recipientData?.["fcm_token"];
      const fcmToken = (fcmTokenValue && typeof fcmTokenValue === "string" && fcmTokenValue.trim().length > 0) 
        ? fcmTokenValue.trim() 
        : null;
      
      logger.info(`FCM token value: ${fcmTokenValue}`);
      logger.info(`FCM token after validation: ${fcmToken ? "VALID" : "INVALID/NULL/EMPTY"}`);
      
      // Get sender's name first
      logger.info(`Fetching sender profile for userId: ${fromUserId}`);
      const senderDoc = await db.collection("Profiles").doc(fromUserId).get();
      
      if (!senderDoc.exists) {
        logger.warn(`Sender profile not found for userId: ${fromUserId}`);
      }
      
      const senderData = senderDoc.data();
      const senderName = senderData?.["Full Name"] || senderData?.["fullName"] || "Someone";
      
      logger.info(`Sender name: ${senderName}`);
      
      if (!fcmToken) {
        logger.warn(`No valid FCM token found for user ${toUserId}, falling back to general topic`);
        try {
          const fallbackMessage = {
            topic: "general",
            notification: {
              title: "New Connection Request",
              body: `${senderName} wants to connect with you!`,
            },
            data: {
              type: "connection_request",
              connectionId: event.params.connectionId,
              fromUserId: fromUserId,
              targetUserId: toUserId,
            },
          };
          const response = await admin.messaging().send(fallbackMessage);
          logger.info(`✅ Fallback notification sent to general topic: ${response}`);
        } catch (fallbackError: any) {
          logger.error("❌ Error sending fallback notification:", fallbackError);
          logger.error(`Fallback error details: ${JSON.stringify(fallbackError, null, 2)}`);
        }
        return;
      }
      
      // Send direct notification with token
      const message = {
        token: fcmToken,
        notification: {
          title: "New Connection Request",
          body: `${senderName} wants to connect with you!`,
        },
        data: {
          type: "connection_request",
          connectionId: event.params.connectionId,
          fromUserId: fromUserId,
        },
        android: {
          notification: {
            icon: "ic_notification",
            color: "#FF7E00",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };
      
      logger.info("Sending direct notification to user:", {
        recipientId: toUserId,
        senderId: fromUserId,
        senderName: senderName,
        hasToken: !!fcmToken,
      });
      
      const response = await admin.messaging().send(message);
      logger.info(`✅ Connection request notification sent successfully to ${toUserId}`);
      logger.info(`FCM Response: ${response}`);
    } catch (error: any) {
      logger.error("❌ Error sending connection request notification:");
      logger.error(`Error message: ${error.message}`);
      logger.error(`Error code: ${error.code}`);
      logger.error(`Error stack: ${error.stack}`);
      
      // Log the full error object
      if (error.errorInfo) {
        logger.error(`Error info: ${JSON.stringify(error.errorInfo, null, 2)}`);
      }
    }
  },
);

export const notifyOnNewMatch = onDocumentCreated(
  {
    document: "Matches/{matchId}",
    region: "us-central1",
  },
  async (event) => {
    logger.info("=== notifyOnNewMatch TRIGGERED ===");
    logger.info(`Match ID: ${event.params.matchId}`);
    
    const data = event.data?.data();
    if (!data) {
      logger.error("No match data found in event.data");
      return;
    }
    
    logger.info("Match data:", JSON.stringify(data, null, 2));
    
    const { user1Id, user2Id } = data;
    
    if (!user1Id || !user2Id) {
      logger.error(`Missing user IDs: user1Id=${user1Id}, user2Id=${user2Id}`);
      return;
    }

    logger.info(`Processing match notification for users: ${user1Id} and ${user2Id}`);

    for (const uid of [user1Id, user2Id]) {
      try {
        logger.info(`Fetching profile for user: ${uid}`);
        const userDoc = await db.collection("Profiles").doc(uid).get();
        
        if (!userDoc.exists) {
          logger.warn(`Profile not found for user: ${uid}`);
          continue;
        }
        
        const userData = userDoc.data();
        logger.info(`Profile found. Available fields: ${Object.keys(userData || {}).join(", ")}`);
        
        const token = userData?.["fcmToken"];
        logger.info(`FCM token for user ${uid}: ${token ? "FOUND" : "NOT FOUND"}`);
        
        if (token) {
          const message = {
            token,
            notification: {
              title: "🎉 It's a Match!",
              body: "You just matched with someone new!",
            },
            data: {
              type: "match",
              matchId: event.params.matchId,
              user1Id: user1Id,
              user2Id: user2Id,
            },
            android: {
              notification: {
                icon: "ic_notification",
                color: "#FF7E00",
                sound: "default",
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
                },
              },
            },
          };
          
          const response = await admin.messaging().send(message);
          logger.info(`✅ Match notification sent successfully to ${uid}: ${response}`);
        } else {
          logger.warn(`No FCM token found for user ${uid}, skipping notification`);
        }
      } catch (error: any) {
        logger.error(`❌ Error sending notification to user ${uid}:`);
        logger.error(`Error message: ${error.message}`);
        logger.error(`Error code: ${error.code}`);
        if (error.errorInfo) {
          logger.error(`Error info: ${JSON.stringify(error.errorInfo, null, 2)}`);
        }
      }
    }
    
    logger.info("=== notifyOnNewMatch COMPLETED ===");
  },
);
/**
 * Send notification for new match
 * NOTE: Commented out - using v1 API. Migrate to v2 if needed.
 */
/*
export const notifyOnNewMatch = functions.firestore
  .document("Matches/{matchId}")
  .onCreate(async (snap: any, context: any) => {
    const matchData = snap.data();
    const userId1 = matchData.userId1;
    const userId2 = matchData.userId2;
    
    try {
      // Send notification to both users
      const notifications = await Promise.all([
        sendMatchNotification(userId1, userId2),
        sendMatchNotification(userId2, userId1),
      ]);
      
      logger.info(`Match notifications sent: ${notifications.filter(Boolean).length}/2`);
    } catch (error) {
      logger.error("Error sending match notifications:", error);
    }
  });
*/

/**
 * Send notification for new message
 * NOTE: Commented out - using v1 API. Migrate to v2 if needed.
 */
/*
export const notifyOnNewMessage = functions.firestore
  .document("ChatRooms/{chatRoomId}/Messages/{messageId}")
  .onCreate(async (snap: any, context: any) => {
    const messageData = snap.data();
    const senderId = messageData.senderId;
    const chatRoomId = context.params.chatRoomId;
    
    try {
      // Get chat room participants
      const chatRoomDoc = await db.collection("ChatRooms").doc(chatRoomId).get();
      const chatRoomData = chatRoomDoc.data();
      const participants = chatRoomData?.participants || [];
      
      // Find the recipient (not the sender)
      const recipientId = participants.find((id: string) => id !== senderId);
      if (!recipientId) {
        logger.warn(`No recipient found for chat room ${chatRoomId}`);
        return;
      }
      
      // Get recipient's FCM token
      const recipientDoc = await db.collection("Profiles").doc(recipientId).get();
      const recipientData = recipientDoc.data();
      const fcmToken = recipientData?.fcmToken;
      
      if (!fcmToken) {
        logger.warn(`No FCM token found for recipient ${recipientId}`);
        return;
      }
      
      // Get sender's name
      const senderDoc = await db.collection("Profiles").doc(senderId).get();
      const senderData = senderDoc.data();
      const senderName = senderData?.["Full Name"] || "Someone";
      
      const message = {
        token: fcmToken,
        notification: {
          title: senderName,
          body: messageData.text,
        },
        data: {
          type: "message",
          chatRoomId: chatRoomId,
          senderId: senderId,
        },
      };
      
      await admin.messaging().send(message);
      logger.info(`Message notification sent to ${recipientId}`);
    } catch (error) {
      logger.error("Error sending message notification:", error);
    }
  });
*/

/**
 * Send notification for new date proposal
 * NOTE: Commented out - using v1 API. Migrate to v2 if needed.
 */
/*
export const notifyOnNewDateProposal = functions.firestore
  .document("ChatRooms/{chatRoomId}/DateProposals/{proposalId}")
  .onCreate(async (snap: any, context: any) => {
    const proposalData = snap.data();
    const proposerId = proposalData.proposerId;
    const chatRoomId = context.params.chatRoomId;
    
    try {
      // Get chat room participants
      const chatRoomDoc = await db.collection("ChatRooms").doc(chatRoomId).get();
      const chatRoomData = chatRoomDoc.data();
      const participants = chatRoomData?.participants || [];
      
      // Find the recipient (not the proposer)
      const recipientId = participants.find((id: string) => id !== proposerId);
      if (!recipientId) {
        logger.warn(`No recipient found for chat room ${chatRoomId}`);
        return;
      }
      
      // Get recipient's FCM token
      const recipientDoc = await db.collection("Profiles").doc(recipientId).get();
      const recipientData = recipientDoc.data();
      const fcmToken = recipientData?.fcmToken;
      
      if (!fcmToken) {
        logger.warn(`No FCM token found for recipient ${recipientId}`);
        return;
      }
      
      // Get proposer's name
      const proposerDoc = await db.collection("Profiles").doc(proposerId).get();
      const proposerData = proposerDoc.data();
      const proposerName = proposerData?.["Full Name"] || "Someone";
      
      const message = {
        token: fcmToken,
        notification: {
          title: "New Date Proposal",
          body: `${proposerName} proposed a date: ${proposalData.details}`,
        },
        data: {
          type: "date_proposal",
          chatRoomId: chatRoomId,
          proposalId: context.params.proposalId,
          proposerId: proposerId,
        },
      };
      
      await admin.messaging().send(message);
      logger.info(`Date proposal notification sent to ${recipientId}`);
    } catch (error) {
      logger.error("Error sending date proposal notification:", error);
    }
  });
*/

// ======= BUSINESS DATA PROCESSING FUNCTION =======
/**
 * Processes business data from CSV file in Firebase Storage
 * and creates individual business documents at /Businesses/Cincinnati/results/
 * 
 * This function:
 * 1. Downloads CSV from Firebase Storage at: Business Scraper/Business_download_enriched.csv
 * 2. Parses the CSV data
 * 3. Creates individual documents with mapped fields:
 *    - address → "address"
 *    - category → "categories" (as array)
 *    - description → "description"
 *    - Name → "name"
 *    - Phone → "phone"
 */
export const processBusinessData = onRequest({
  cors: true,
  memory: "2GiB",
  timeoutSeconds: 540,
}, async (req: any, res: any) => {
  try {
    logger.info("Starting business data processing from Storage...");
    logger.info("Request method:", req.method);
    logger.info("Request query:", req.query);
    logger.info("Request body:", req.body);

    // Storage path - can be overridden via query parameter
    const storagePath = req.query.storagePath || 
                       req.body?.storagePath || 
                       "Business Scraper/Business_download_enriched.csv";
    
    logger.info(`Attempting to download CSV from Storage: ${storagePath}`);

    // Get Firebase Storage
    const storage = admin.storage();
    const bucket = storage.bucket("culture-connection-d442f.firebasestorage.app");
    const file = bucket.file(storagePath);

    // Check if file exists
    const [exists] = await file.exists();
    if (!exists) {
      logger.error(`File not found in Storage: ${storagePath}`);
      res.status(404).json({
        success: false,
        error: `CSV file not found in Storage at: ${storagePath}`,
        hint: "Expected path: Business Scraper/Business_download_enriched.csv",
      });
      return;
    }

    logger.info("File found in Storage, downloading...");

    // Download the file
    const [fileContent] = await file.download();
    const csvString = fileContent.toString("utf-8");
    
    logger.info(`Downloaded CSV file, size: ${csvString.length} bytes`);

    // Parse CSV
    logger.info("Parsing CSV...");
    const records = parse(csvString, {
      columns: true,
      skip_empty_lines: true,
      trim: true,
      relax_column_count: true,
    });

    logger.info(`Found ${records.length} businesses in CSV`);

    if (!records || records.length === 0) {
      res.status(400).json({
        success: false,
        error: "No businesses found in CSV file",
      });
      return;
    }

    // Convert records to businesses array with proper field mapping
    const businesses = records.map((record: any) => ({
      Name: record.Name || record.name || "",
      Address: record.Address || record.address || "",
      Category: record.Category || record.category || "",
      Description: record.Description || record.description || "",
      Phone: record.Phone || record.phone || "",
      Website: record.Website || record.website || "",
    }));

    logger.info(`Processed ${businesses.length} businesses from CSV`);

    // Target collection paths - writing to both "results" and "results 2"
    const targetCollection = db.collection("Businesses").doc("Cincinnati").collection("results");
    const targetCollection2 = db.collection("Businesses").doc("Cincinnati").collection("results 2");
    
    logger.info(`Target collections: Businesses/Cincinnati/results and Businesses/Cincinnati/results 2`);

    // Process each business
    let successCount = 0;
    let errorCount = 0;
    const errors: any[] = [];

    // Use batch writes for efficiency (Firestore allows up to 500 operations per batch)
    // Since we're writing to 2 collections, adjust batch size (250 businesses * 2 = 500 ops max)
    const batchSize = 500; // We check operationCount which is now 2 per business
    let batch = db.batch();
    let operationCount = 0;

    for (let i = 0; i < businesses.length; i++) {
      const business = businesses[i];
      
      try {
        // Extract and map fields
        const name = business.Name || business.name || "";
        
        // Skip if no name (required field)
        if (!name || name.trim() === "") {
          logger.warn(`Skipping business at index ${i}: no name found`);
          errorCount++;
          errors.push({
            index: i,
            error: "Missing required field: Name",
            business: business,
          });
          continue;
        }

        // Handle categories - convert to array if needed
        const categoryField = business.category || business.Category || business.categories || business.Categories;
        let categoriesArray: string[] = [];
        
        if (categoryField) {
          if (Array.isArray(categoryField)) {
            categoriesArray = categoryField.filter((cat: any) => cat && String(cat).trim() !== "");
          } else if (typeof categoryField === "string") {
            // Split by common delimiters if it's a string
            categoriesArray = categoryField
              .split(/[,;|]/)
              .map((cat: string) => cat.trim())
              .filter((cat: string) => cat !== "");
          }
        }

        // Map the fields as specified
        const mappedBusiness = {
          name: name.trim(),
          address: business.address || business.Address || "",
          description: business.description || business.Description || "",
          phone: business.Phone || business.phone || "",
          website: business.Website || business.website || "",
          categories: categoriesArray,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Create document reference with a generated ID (or use name as base for ID)
        const docId = name.toLowerCase()
          .replace(/[^a-z0-9]+/g, "-")
          .replace(/^-+|-+$/g, "") || `business-${i}`;
        
        const businessDocRef = targetCollection.doc(docId);
        const businessDocRef2 = targetCollection2.doc(docId);

        // Set the document in both collections
        batch.set(businessDocRef, mappedBusiness, { merge: true });
        batch.set(businessDocRef2, mappedBusiness, { merge: true });
        operationCount += 2; // Count 2 operations (one for each collection)
        successCount++;

        // Commit batch if we've reached the limit
        if (operationCount >= batchSize) {
          await batch.commit();
          logger.info(`Committed batch: ${successCount} businesses processed so far`);
          batch = db.batch();
          operationCount = 0;
        }

      } catch (businessError: any) {
        errorCount++;
        errors.push({
          index: i,
          error: businessError.message || "Unknown error",
          business: business,
        });
        logger.error(`Error processing business at index ${i}:`, businessError);
      }
    }

    // Commit any remaining operations
    if (operationCount > 0) {
      await batch.commit();
      logger.info(`Committed final batch`);
    }

    logger.info(
      `Business data processing completed. ` +
      `Success: ${successCount}, Errors: ${errorCount}`
    );

    logger.info(`Final results: ${successCount} successful, ${errorCount} errors`);

    const response = {
      success: true,
      message: `Processed ${businesses.length} businesses`,
      totalBusinesses: businesses.length,
      successCount: successCount,
      errorCount: errorCount,
      errors: errors.length > 0 ? errors.slice(0, 10) : [], // Return first 10 errors
      targetPath: "Businesses/Cincinnati/results and Businesses/Cincinnati/results 2",
      sourceFile: storagePath,
    };

    logger.info("Sending response:", response);
    res.json(response);

  } catch (error: any) {
    logger.error("Business data processing failed:", error);
    res.status(500).json({
      success: false,
      error: error.message || "Processing failed",
      stack: error.stack,
    });
  }
});

// ======= TICKETMASTER SEARCH FUNCTION =======
export const ticketmastersearch = onRequest(
  {
    region: "us-central1",
    cors: true,
    memory: "512MiB",
    timeoutSeconds: 60,
    secrets: ["TICKETMASTER_API_KEY"],
  },
  async (req: any, res: any) => {
    try {
      // Handle CORS preflight
      if (req.method === "OPTIONS") {
        res.set("Access-Control-Allow-Origin", "*");
        res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.set("Access-Control-Allow-Headers", "Content-Type");
        return res.status(204).send("");
      }

      if (req.method !== "GET") {
        return res.status(405).send("Method Not Allowed");
      }

      const apiKey = process.env.TICKETMASTER_API_KEY;
      if (!apiKey) {
        logger.error("❌ TICKETMASTER_API_KEY not configured");
        // Return empty events array (not error) to match expected format
        return res.json({
          events: [],
          error: "Server not configured",
        });
      }

      const {city, lat, lng, radius, size = "25", keyword} = req.query;

      // Build Ticketmaster API URL
      const baseUrl = "https://app.ticketmaster.com/discovery/v2/events.json";
      const params = new URLSearchParams();
      params.set("apikey", apiKey);
      params.set("size", String(size));
      params.set("sort", "date,asc");
      // Format date as YYYY-MM-DDTHH:mm:ssZ (without milliseconds)
      const now = new Date();
      const formattedDate = now.toISOString().replace(/\.\d{3}Z$/, 'Z');
      params.set("startDateTime", formattedDate); // Only future events

      // Add keyword if provided
      if (keyword && String(keyword).trim()) {
        params.set("keyword", String(keyword).trim());
      }

      // Search by city or coordinates (exactly matching iOS app expectations)
      if (city) {
        params.set("city", String(city).trim());
      } else if (lat && lng) {
        params.set("geoPoint", `${lng},${lat}`);
        const radiusKm = radius ? Math.round(parseFloat(radius) * 1.609) : 40; // Convert miles to km
        params.set("radius", String(radiusKm));
        params.set("unit", "km");
      } else {
        // Return empty events array (not error) to match expected format
        return res.json({
          events: [],
        });
      }

      const url = `${baseUrl}?${params.toString()}`;
      logger.info(`🎫 Ticketmaster API request: ${url.replace(apiKey, "***")}`);

      const response = await fetch(url);
      if (!response.ok) {
        const errorText = await response.text();
        logger.error(`❌ Ticketmaster API error: ${response.status} - ${errorText}`);
        // Return empty events array (not error) to match expected format
        return res.json({
          events: [],
        });
      }

      const data = await response.json();

      // Transform Ticketmaster response to EXACT format expected by iOS app
      // TMEvent structure: id, title, startsAt, timezone, venue, address, url
      const events = (data._embedded?.events || []).map((event: any) => {
        const venue = event._embedded?.venues?.[0];
        const startDate = event.dates?.start;

        // Format address exactly as expected
        let formattedAddress: string | null = null;
        if (venue?.address?.line1) {
          const parts = [
            venue.address.line1,
            venue.city?.name,
            venue.state?.stateCode,
            venue.postalCode,
          ].filter(Boolean);
          formattedAddress = parts.join(", ");
        }

        // Format date - prefer dateTime, fallback to localDate
        let startsAtValue: string | null = null;
        if (startDate?.dateTime) {
          startsAtValue = startDate.dateTime;
        } else if (startDate?.localDate) {
          // If only localDate, append default time
          startsAtValue = `${startDate.localDate}T00:00:00`;
        }

        return {
          id: event.id || "",
          title: event.name || null,
          startsAt: startsAtValue,
          timezone: startDate?.timezone || null,
          venue: venue?.name || null,
          address: formattedAddress,
          url: event.url || null,
        };
      });

      // Page info (optional, matches TicketmasterResponse structure)
      const pageInfo = data.page ? {
        size: data.page.size || null,
        totalElements: data.page.totalElements || null,
        totalPages: data.page.totalPages || null,
        number: data.page.number || null,
      } : null;

      logger.info(`✅ Ticketmaster API returned ${events.length} events`);

      // Set cache headers
      res.set("Cache-Control", "public, max-age=3600, s-maxage=7200");
      res.set("Access-Control-Allow-Origin", "*");

      // Return exact format: { events: [...], page?: {...} }
      return res.json({
        events: events,
        ...(pageInfo && {page: pageInfo}),
      });
    } catch (error: any) {
      logger.error("❌ Ticketmaster function error:", error);
      // Return empty events array (not error) to match expected format
      return res.json({
        events: [],
      });
    }
  },
);