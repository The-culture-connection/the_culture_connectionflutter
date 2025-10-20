import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/date_proposal.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('ChatRooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatRoom> chatRooms = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        
        if (participants.length != 2) continue;
        
        final otherUserId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        
        if (otherUserId.isEmpty) continue;
        
        // Fetch other user's profile
        try {
          final profileDoc = await _db.collection('Profiles').doc(otherUserId).get();
          final profileData = profileDoc.data();
          
            final chatRoom = ChatRoom.fromMap(
              {...data, 'id': doc.id},
              profileData?['Full Name'] ?? 'Unknown',
              otherParticipantProfileImage: profileData?['photoURL'],
            );
          chatRooms.add(chatRoom);
        } catch (e) {
          print('Error fetching profile for user $otherUserId: $e');
        }
      }
      
      // Sort by last message timestamp
      chatRooms.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
      return chatRooms;
    });
  }

  // Send a message
  Future<void> sendMessage(String chatRoomId, String text) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || text.isEmpty) return;

    final timestamp = Timestamp.now();
    final messageData = {
      'senderId': currentUserId,
      'text': text,
      'timestamp': timestamp,
    };

    // Add message to subcollection
    await _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .add(messageData);

    // Update chat room's last message
    await _db.collection('ChatRooms').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
    });
  }

  // Fetch messages for a chat room
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Create a new chat room
  Future<String> createChatRoom(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    final participants = [currentUserId, otherUserId]..sort();
    
    final chatRoomData = {
      'participants': participants,
      'createdAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageTimestamp': Timestamp.now(),
      'lastMessageSenderId': '',
    };

    final docRef = await _db.collection('ChatRooms').add(chatRoomData);
    return docRef.id;
  }

  // Propose a date
  Future<void> proposeDate(String chatRoomId, String details, DateTime date, String place) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final proposalData = {
      'proposerId': currentUserId,
      'details': details,
      'date': Timestamp.fromDate(date),
      'place': place,
      'timestamp': Timestamp.now(),
      'status': 'Pending',
    };

    // Add the proposal to Firestore
    final docRef = await _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('DateProposals')
        .add(proposalData);

    // Call the Firebase function to notify about the new date proposal
    try {
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('notifyOnNewDateProposal').call({
        'chatRoomId': chatRoomId,
        'proposalId': docRef.id,
        'proposerId': currentUserId,
        'details': details,
        'date': date.toIso8601String(),
        'place': place,
      });
    } catch (e) {
      print('Error calling notifyOnNewDateProposal: $e');
    }
  }

  // Fetch date proposals for a chat room
  Stream<List<DateProposal>> getDateProposals(String chatRoomId) {
    return _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('DateProposals')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DateProposal.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Respond to a date proposal
  Future<void> respondToDateProposal(String chatRoomId, String proposalId, bool accept) async {
    final newStatus = accept ? 'Accepted' : 'Declined';
    
    await _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('DateProposals')
        .doc(proposalId)
        .update({'status': newStatus});

    // If accepted, add to calendar
    if (accept) {
      try {
        // Get the proposal details
        final proposalDoc = await _db
            .collection('ChatRooms')
            .doc(chatRoomId)
            .collection('DateProposals')
            .doc(proposalId)
            .get();
        
        if (proposalDoc.exists) {
          final data = proposalDoc.data()!;
          final date = (data['date'] as Timestamp).toDate();
          final details = data['details'] as String;
          final place = data['place'] as String;
          
          // Add to calendar (this would need calendar integration)
          await _addToCalendar(details, date, place);
        }
      } catch (e) {
        print('Error adding to calendar: $e');
      }
    }
  }

  // Add event to calendar
  Future<void> _addToCalendar(String details, DateTime date, String place) async {
    // This would integrate with the device's calendar
    // For now, we'll just show a success message
    print('Event added to calendar: $details at $place on $date');
  }

  // Calculate unread count for a chat room
  Future<int> getUnreadCount(String chatRoomId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return 0;

    final snapshot = await _db
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1))
        ))
        .get();

    return snapshot.docs.length;
  }
}
