/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onRequest, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

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

      // Skip if user doesn't have required data
      if (!user.skillsOffering || !user.skillsSeeking || !user.purposes) {
        logger.info(`Skipping user ${user.id} - missing required data`);
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

    // Save matches to Firestore
    try {
      const batch = db.batch();
      const timestamp = admin.firestore.FieldValue.serverTimestamp();

      for (const userMatch of matches) {
        const matchDocRef = db.collection("SkillMatches").doc(userMatch.userId);
        const userProfile = profiles.find((p) => p.id === userMatch.userId);
        const matchData = {
          userId: userMatch.userId,
          fullName: userProfile?.["Full Name"] || "Unknown",
          matches: userMatch.matches,
          totalMatches: userMatch.matches.length,
          createdAt: timestamp,
          updatedAt: timestamp,
        };

        batch.set(matchDocRef, matchData, {merge: true});
      }

      await batch.commit();
      logger.info(
        `Saved ${matches.length} match records to SkillMatches collection`,
      );
    } catch (firestoreError: any) {
      logger.error("Error saving matches to Firestore:", firestoreError);
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

    // Skip if other user doesn't have required data
    if (!otherUser.skillsOffering || !otherUser.skillsSeeking ||
        !otherUser.purposes) continue;

    let matchScore = 0;
    const matchReasons = [];

    // 1. Skills Matching (40% weight)
    const skillsScore = calculateSkillsMatch(user, otherUser);
    matchScore += skillsScore.score * 0.4;
    if (skillsScore.score > 0) {
      matchReasons.push(...skillsScore.reasons);
    }

    // 2. Purpose Matching (30% weight)
    const purposeScore = calculatePurposeMatch(user, otherUser);
    matchScore += purposeScore.score * 0.3;
    if (purposeScore.score > 0) {
      matchReasons.push(...purposeScore.reasons);
    }

    // 3. Business Needs Matching (20% weight)
    const businessScore = calculateBusinessMatch(user, otherUser);
    matchScore += businessScore.score * 0.2;
    if (businessScore.score > 0) {
      matchReasons.push(...businessScore.reasons);
    }

    // 4. Experience Level Compatibility (10% weight)
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
        skillsOffering: otherUser.skillsOffering,
        skillsSeeking: otherUser.skillsSeeking,
        purposes: otherUser.purposes,
        businessNeeds: otherUser.businessNeeds || [],
        experienceLevel: otherUser.experienceLevel,
        location: otherUser.location,
      });
    }
  }

  // Sort by score (highest first) and return top 5 matches
  return matches.sort((a, b) => b.score - a.score).slice(0, 5);
}

/**
 * Calculate skills matching score
 * - User's skillsOffering should match other's skillsSeeking
 * - Prioritize subcategory matches, then main category matches
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

  const userOffering = user.skillsOffering;
  const otherSeeking = otherUser.skillsSeeking;

  if (!userOffering || !otherSeeking) return {score: 0, reasons: []};

  // Check subcategory matches first (higher weight)
  const userSubCategories = userOffering.subCategories || [];
  const otherSeekingSubCategories = otherSeeking.subCategories || [];

  for (const userSub of userSubCategories) {
    if (otherSeekingSubCategories.includes(userSub)) {
      score += 0.8; // High weight for exact subcategory match
      reasons.push(`Your ${userSub} skills match their needs`);
    }
  }

  // Check main category matches (lower weight)
  const userMainCategories = userOffering.mainCategories || [];
  const otherSeekingCategories = otherSeeking.categories || [];

  for (const userMain of userMainCategories) {
    if (otherSeekingCategories.includes(userMain)) {
      score += 0.4; // Lower weight for main category match
      reasons.push(`Your ${userMain} expertise aligns with their interests`);
    }
  }

  // Normalize score to 0-1 range
  const maxPossibleScore = Math.max(userSubCategories.length,
    userMainCategories.length) * 0.8;
  const normalizedScore = maxPossibleScore > 0 ?
    Math.min(score / maxPossibleScore, 1) : 0;

  return {score: normalizedScore, reasons};
}

/**
 * Calculate purpose matching score
 * - Look for complementary purposes
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

  const userPurposes = user.purposes || [];
  const otherPurposes = otherUser.purposes || [];

  // Define complementary purpose pairs
  const complementaryPairs = [
    ["Looking to hire candidates", "Looking to get hired"],
    ["Looking for a mentor", "Looking for a mentee"],
    ["Starting a business", "Wants to invest in a business"],
    ["Networking", "Networking"], // Same purpose is also good
    ["Looking for a mentee", "Looking for a mentor"],
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
  // Max score of 2, normalize to 1
  const normalizedScore = Math.min(score / 2, 1);

  return {score: normalizedScore, reasons};
}

/**
 * Calculate business needs matching score
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

  const userBusinessNeeds = user.businessNeeds || [];
  const otherBusinessNeeds = otherUser.businessNeeds || [];

  // If neither user is starting a business, this doesn't apply
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
        otherUser.purposes?.includes(otherPurpose)) {
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
 * Calculate experience level compatibility
 * @param {any} user - The user to calculate experience match for
 * @param {any} otherUser - The other user to match against
 * @return {{score: number, reasons: string[]}} Experience match score
 */
function calculateExperienceMatch(user: any, otherUser: any): {
  score: number;
  reasons: string[];
} {
  const userLevel = user.experienceLevel;
  const otherLevel = otherUser.experienceLevel;

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
async function notifyOnNewConnectionRequest(
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
async function notifyOnNewMatch(user1Id: string, user2Id: string) {
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
      await notifyOnNewConnectionRequest(fromUserId, toUserId);

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
    await notifyOnNewMatch(fromUserId, toUserId);

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

