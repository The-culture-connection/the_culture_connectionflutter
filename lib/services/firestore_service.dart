import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culture_connection/constants/app_constants.dart';
import 'package:culture_connection/models/user_profile.dart';
import 'package:culture_connection/models/post.dart';
import 'package:culture_connection/models/chat_room.dart';
import 'package:culture_connection/models/message.dart';
import 'package:culture_connection/models/event.dart';
import 'package:culture_connection/models/business.dart';
import 'package:culture_connection/models/date_proposal.dart';
import 'package:culture_connection/models/earned_points.dart';

/// Firestore database service
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== USER PROFILES ==========

  /// Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    await _db
        .collection(AppConstants.collectionProfiles)
        .doc(profile.userId)
        .set(profile.toFirestore());
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _db
        .collection(AppConstants.collectionProfiles)
        .doc(userId)
        .get();
    return doc.exists ? UserProfile.fromFirestore(doc) : null;
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.collectionProfiles)
        .doc(userId)
        .update(data);
  }

  /// Stream user profile
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _db
        .collection(AppConstants.collectionProfiles)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  /// Search users by name
  Future<List<UserProfile>> searchUsersByName(String name) async {
    final snapshot = await _db
        .collection(AppConstants.collectionProfiles)
        .where('Full Name', isGreaterThanOrEqualTo: name)
        .where('Full Name', isLessThan: '${name}z')
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  /// Search users with filters
  Future<List<UserProfile>> searchUsersWithFilters({
    String? name,
    String? experienceLevel,
    List<String>? skillsOffering,
    List<String>? skillsSeeking,
  }) async {
    Query query = _db.collection(AppConstants.collectionProfiles);

    if (name != null && name.isNotEmpty) {
      query = query
          .where('Full Name', isGreaterThanOrEqualTo: name)
          .where('Full Name', isLessThan: '${name}z');
    }

    if (experienceLevel != null && experienceLevel.isNotEmpty) {
      query = query.where('Experience Level', isEqualTo: experienceLevel);
    }

    if (skillsOffering != null && skillsOffering.isNotEmpty) {
      query = query.where('Skills Offering', arrayContainsAny: skillsOffering);
    } else if (skillsSeeking != null && skillsSeeking.isNotEmpty) {
      query = query.where('Skills Seeking', arrayContainsAny: skillsSeeking);
    }

    final snapshot = await query.limit(50).get();
    return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  // ========== POSTS ==========

  /// Create post
  Future<String> createPost(Post post) async {
    final docRef = await _db
        .collection(AppConstants.collectionPosts)
        .add(post.toFirestore());
    return docRef.id;
  }

  /// Get posts feed
  Stream<List<Post>> getPostsFeed({int limit = 20}) {
    return _db
        .collection(AppConstants.collectionPosts)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Get user posts
  Stream<List<Post>> getUserPosts(String userId) {
    return _db
        .collection(AppConstants.collectionPosts)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await _db.collection(AppConstants.collectionPosts).doc(postId).delete();
  }

  // ========== CHAT ROOMS & MESSAGES ==========

  /// Create chat room
  Future<String> createChatRoom(ChatRoom chatRoom) async {
    // Check if chat room already exists between participants
    final existingRoom = await _db
        .collection(AppConstants.collectionChatRooms)
        .where('participants', arrayContains: chatRoom.participants[0])
        .get();

    for (var doc in existingRoom.docs) {
      final room = ChatRoom.fromFirestore(doc);
      if (room.participants.contains(chatRoom.participants[1])) {
        return doc.id;
      }
    }

    // Create new chat room
    final docRef = await _db
        .collection(AppConstants.collectionChatRooms)
        .add(chatRoom.toFirestore());
    return docRef.id;
  }

  /// Get user chat rooms
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _db
        .collection(AppConstants.collectionChatRooms)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  /// Send message
  Future<void> sendMessage(String chatRoomId, Message message) async {
    // Add message to messages subcollection
    await _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .collection(AppConstants.collectionMessages)
        .add(message.toFirestore());

    // Update chat room last message
    await _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .update({
      'lastMessage': message.text,
      'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
      'lastMessageSenderId': message.senderId,
    });
  }

  /// Stream messages
  Stream<List<Message>> streamMessages(String chatRoomId) {
    return _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .collection(AppConstants.collectionMessages)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  // ========== CONNECTIONS ==========

  /// Create connection request
  Future<void> createConnection(String fromUserId, String toUserId) async {
    await _db.collection(AppConstants.collectionConnects).add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': Timestamp.now(),
    });
  }

  /// Create mutual match
  Future<void> createMatch(String user1Id, String user2Id) async {
    await _db.collection(AppConstants.collectionMatches).add({
      'user1Id': user1Id,
      'user2Id': user2Id,
      'timestamp': Timestamp.now(),
    });
  }

  // ========== EVENTS ==========

  /// Create event
  Future<String> createEvent(Event event) async {
    final docRef = await _db
        .collection(AppConstants.collectionEvents)
        .add(event.toFirestore());
    return docRef.id;
  }

  /// Get events
  Stream<List<Event>> getEvents() {
    return _db
        .collection(AppConstants.collectionEvents)
        .orderBy('Date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // ========== BUSINESSES ==========

  /// Get businesses
  Future<List<Business>> getBusinesses({String? cityKey}) async {
    Query query = _db.collection(AppConstants.collectionBusinesses);

    if (cityKey != null) {
      query = query.where('cityKey', isEqualTo: cityKey);
    }

    final snapshot = await query.limit(100).get();
    return snapshot.docs.map((doc) => Business.fromFirestore(doc)).toList();
  }

  // ========== POINTS ==========

  /// Add earned points
  Future<void> addEarnedPoints(EarnedPoints points) async {
    await _db
        .collection(AppConstants.collectionEarnedPoints)
        .add(points.toFirestore());

    // Update user total points
    await _db
        .collection(AppConstants.collectionProfiles)
        .doc(points.userId)
        .update({
      'totalPoints': FieldValue.increment(points.points),
    });
  }

  /// Get user earned points
  Stream<List<EarnedPoints>> getUserEarnedPoints(String userId) {
    return _db
        .collection(AppConstants.collectionEarnedPoints)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EarnedPoints.fromFirestore(doc))
            .toList());
  }

  // ========== DATE PROPOSALS ==========

  /// Create date proposal
  Future<void> createDateProposal(
      String chatRoomId, DateProposal proposal) async {
    await _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .collection(AppConstants.collectionDateProposals)
        .add(proposal.toFirestore());
  }

  /// Stream date proposals
  Stream<List<DateProposal>> streamDateProposals(String chatRoomId) {
    return _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .collection(AppConstants.collectionDateProposals)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DateProposal.fromFirestore(doc))
            .toList());
  }

  /// Update date proposal status
  Future<void> updateDateProposalStatus(
      String chatRoomId, String proposalId, String status) async {
    await _db
        .collection(AppConstants.collectionChatRooms)
        .doc(chatRoomId)
        .collection(AppConstants.collectionDateProposals)
        .doc(proposalId)
        .update({'status': status});
  }
}
