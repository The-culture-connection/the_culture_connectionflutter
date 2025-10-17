import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/post.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/event.dart';
import '../models/business.dart';
import '../models/date_proposal.dart';
import '../models/connection.dart';
import '../models/earned_points.dart';
import '../models/forum.dart';

/// Firestore Service for database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('Profiles');
  CollectionReference get _postsCollection => _firestore.collection('Posts');
  CollectionReference get _chatRoomsCollection => _firestore.collection('ChatRooms');
  CollectionReference get _eventsCollection => _firestore.collection('Events');
  CollectionReference get _businessesCollection => _firestore.collection('Businesses');
  CollectionReference get _connectsCollection => _firestore.collection('Connects');
  CollectionReference get _matchesCollection => _firestore.collection('Matches');
  CollectionReference get _earnedPointsCollection => _firestore.collection('EarnedPointss');
  CollectionReference get _forumsCollection => _firestore.collection('Forums');

  // ============ USER PROFILE OPERATIONS ============

  /// Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.userId).set(profile.toFirestore());
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Stream user profile
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).update(data);
  }

  /// Search users by name
  Stream<List<UserProfile>> searchUsersByName(String query) {
    return _usersCollection
        .where('Full Name', isGreaterThanOrEqualTo: query)
        .where('Full Name', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  /// Search users by experience level
  Stream<List<UserProfile>> searchUsersByExperienceLevel(String level) {
    return _usersCollection
        .where('Experience Level', isEqualTo: level)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  /// Search users by skills offering
  Stream<List<UserProfile>> searchUsersBySkillsOffering(List<String> skills) {
    return _usersCollection
        .where('Skills Offering', arrayContainsAny: skills)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  /// Search users by skills seeking
  Stream<List<UserProfile>> searchUsersBySkillsSeeking(List<String> skills) {
    return _usersCollection
        .where('Skills Seeking', arrayContainsAny: skills)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  /// Get all users (with pagination)
  Future<List<UserProfile>> getAllUsers({int limit = 50}) async {
    final snapshot = await _usersCollection.limit(limit).get();
    return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  // ============ POST OPERATIONS ============

  /// Create post
  Future<String> createPost(Post post) async {
    final docRef = await _postsCollection.add(post.toFirestore());
    return docRef.id;
  }

  /// Stream posts (news feed)
  Stream<List<Post>> streamPosts({int limit = 50}) {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .toList());
  }

  /// Stream posts by user
  Stream<List<Post>> streamUserPosts(String userId) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .toList());
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  // ============ CHAT OPERATIONS ============

  /// Create chat room
  Future<String> createChatRoom(ChatRoom chatRoom) async {
    final docRef = await _chatRoomsCollection.add(chatRoom.toFirestore());
    return docRef.id;
  }

  /// Get or create chat room between two users
  Future<String> getOrCreateChatRoom(String user1Id, String user2Id) async {
    // Check if chat room already exists
    final existingRooms = await _chatRoomsCollection
        .where('participants', arrayContains: user1Id)
        .get();

    for (var doc in existingRooms.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] as List);
      if (participants.contains(user2Id)) {
        return doc.id;
      }
    }

    // Create new chat room
    final chatRoom = ChatRoom(
      id: '',
      participants: [user1Id, user2Id],
      createdAt: DateTime.now(),
    );
    
    return await createChatRoom(chatRoom);
  }

  /// Stream user chat rooms
  Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _chatRoomsCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final chatRooms = snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc))
              .toList();
          
          // Sort by lastMessageTimestamp in Dart instead of Firestore
          chatRooms.sort((a, b) {
            if (a.lastMessageTimestamp == null && b.lastMessageTimestamp == null) return 0;
            if (a.lastMessageTimestamp == null) return 1;
            if (b.lastMessageTimestamp == null) return -1;
            return b.lastMessageTimestamp!.compareTo(a.lastMessageTimestamp!);
          });
          
          return chatRooms;
        });
  }

  /// Send message
  Future<void> sendMessage(String chatRoomId, Message message) async {
    final batch = _firestore.batch();
    
    // Add message to subcollection
    final messageRef = _chatRoomsCollection
        .doc(chatRoomId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.toFirestore());
    
    // Update chat room's last message
    final chatRoomRef = _chatRoomsCollection.doc(chatRoomId);
    batch.update(chatRoomRef, {
      'lastMessage': message.text,
      'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
      'lastMessageSenderId': message.senderId,
    });
    
    await batch.commit();
  }

  /// Stream messages for chat room
  Stream<List<Message>> streamMessages(String chatRoomId) {
    return _chatRoomsCollection
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }

  // ============ EVENT OPERATIONS ============

  /// Create event
  Future<String> createEvent(Event event) async {
    final docRef = await _eventsCollection.add(event.toFirestore());
    return docRef.id;
  }

  /// Stream events
  Stream<List<Event>> streamEvents() {
    return _eventsCollection
        .orderBy('Date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList());
  }

  /// RSVP to event
  Future<void> rsvpEvent(String eventId, String userId) async {
    await _eventsCollection.doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId]),
    });
  }

  /// Cancel RSVP
  Future<void> cancelRsvp(String eventId, String userId) async {
    await _eventsCollection.doc(eventId).update({
      'attendees': FieldValue.arrayRemove([userId]),
    });
  }

  // ============ BUSINESS OPERATIONS ============

  /// Stream businesses
  Stream<List<Business>> streamBusinesses({String? category, String? cityKey}) {
    Query query = _businessesCollection;
    
    if (category != null) {
      query = query.where('categories', arrayContains: category);
    }
    
    if (cityKey != null) {
      query = query.where('cityKey', isEqualTo: cityKey);
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Business.fromFirestore(doc))
        .toList());
  }

  // ============ CONNECTION OPERATIONS ============

  /// Create connection request
  Future<String> createConnection(Connection connection) async {
    final docRef = await _connectsCollection.add(connection.toFirestore());
    return docRef.id;
  }

  /// Stream user connections
  Stream<List<Connection>> streamUserConnections(String userId) {
    return _connectsCollection
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Connection.fromFirestore(doc))
            .toList());
  }

  /// Accept connection
  Future<void> acceptConnection(String connectionId, String user1Id, String user2Id) async {
    final batch = _firestore.batch();
    
    // Update connection status
    batch.update(_connectsCollection.doc(connectionId), {'status': 'accepted'});
    
    // Create match
    final matchRef = _matchesCollection.doc();
    final match = Match(
      id: matchRef.id,
      user1Id: user1Id,
      user2Id: user2Id,
      timestamp: DateTime.now(),
    );
    batch.set(matchRef, match.toFirestore());
    
    await batch.commit();
  }

  /// Stream user matches
  Stream<List<Match>> streamUserMatches(String userId) {
    return _matchesCollection
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot1) async {
      final snapshot2 = await _matchesCollection
          .where('user2Id', isEqualTo: userId)
          .get();
      
      final allDocs = [...snapshot1.docs, ...snapshot2.docs];
      return allDocs.map((doc) => Match.fromFirestore(doc)).toList();
    });
  }

  // ============ POINTS OPERATIONS ============

  /// Add points
  Future<void> addPoints(String userId, int points, String action) async {
    final batch = _firestore.batch();
    
    // Create earned points record
    final earnedPointsRef = _earnedPointsCollection.doc();
    final earnedPoints = EarnedPoints(
      id: earnedPointsRef.id,
      userId: userId,
      points: points,
      action: action,
      timestamp: DateTime.now(),
      date: DateTime.now(),
    );
    batch.set(earnedPointsRef, earnedPoints.toFirestore());
    
    // Update user total points
    batch.update(_usersCollection.doc(userId), {
      'totalPoints': FieldValue.increment(points),
    });
    
    await batch.commit();
  }

  /// Stream user points history
  Stream<List<EarnedPoints>> streamUserPointsHistory(String userId) {
    return _earnedPointsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EarnedPoints.fromFirestore(doc))
            .toList());
  }

  // ============ FORUM OPERATIONS ============

  /// Create forum
  Future<String> createForum(Forum forum) async {
    final docRef = await _forumsCollection.add(forum.toFirestore());
    return docRef.id;
  }

  /// Stream forums
  Stream<List<Forum>> streamForums() {
    return _forumsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Forum.fromFirestore(doc))
            .toList());
  }

  /// Join forum
  Future<void> joinForum(String forumId, String userId) async {
    await _forumsCollection.doc(forumId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  // ============ DATE PROPOSAL OPERATIONS ============

  /// Create date proposal
  Future<void> createDateProposal(String chatRoomId, DateProposal proposal) async {
    await _chatRoomsCollection
        .doc(chatRoomId)
        .collection('dateProposals')
        .add(proposal.toFirestore());
  }

  /// Stream date proposals for chat room
  Stream<List<DateProposal>> streamDateProposals(String chatRoomId, String receiverId) {
    return _chatRoomsCollection
        .doc(chatRoomId)
        .collection('dateProposals')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DateProposal.fromFirestore(doc, receiverId))
            .toList());
  }

  /// Update date proposal status
  Future<void> updateDateProposalStatus(String chatRoomId, String proposalId, String status) async {
    await _chatRoomsCollection
        .doc(chatRoomId)
        .collection('dateProposals')
        .doc(proposalId)
        .update({'status': status});
  }

  // ============ BUSINESS DIRECTORY OPERATIONS ============

  /// Create forum
  Future<String> createForum(Forum forum) async {
    final docRef = await _forumsCollection.add(forum.toFirestore());
    return docRef.id;
  }

  /// Stream all businesses
  Stream<List<Business>> streamBusinesses() {
    return _db
        .collection('businesses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Business.fromFirestore(doc))
            .toList());
  }

  /// Create business
  Future<String> createBusiness(Business business) async {
    final docRef = await _db.collection('businesses').add(business.toFirestore());
    return docRef.id;
  }

  /// Update business
  Future<void> updateBusiness(String businessId, Business business) async {
    await _db.collection('businesses').doc(businessId).update(business.toFirestore());
  }

  /// Delete business
  Future<void> deleteBusiness(String businessId) async {
    await _db.collection('businesses').doc(businessId).delete();
  }

  /// Get business by ID
  Future<Business?> getBusiness(String businessId) async {
    final doc = await _db.collection('businesses').doc(businessId).get();
    if (!doc.exists) return null;
    return Business.fromFirestore(doc);
  }
}
