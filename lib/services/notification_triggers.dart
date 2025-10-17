import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// NotificationTriggers - Handles triggering Firebase functions for notifications
class NotificationTriggers {
  static final NotificationTriggers _instance = NotificationTriggers._internal();
  factory NotificationTriggers() => _instance;
  NotificationTriggers._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Functions URLs (replace with your actual function URLs)
  static const String _baseUrl = 'https://us-central1-your-project-id.cloudfunctions.net';
  
  /// Trigger connection request notification
  /// This is automatically handled by Firebase function when a document is created in 'Connects' collection
  Future<void> sendConnectionRequest({
    required String toUserId,
    required String fromUserId,
    String? message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create connection request document
      // This will automatically trigger the notifyOnNewConnectionRequest Firebase function
      await _firestore.collection('Connects').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'message': message ?? 'I\'d like to connect with you!',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Connection request sent to: $toUserId');
    } catch (e) {
      print('❌ Error sending connection request: $e');
      rethrow;
    }
  }

  /// Trigger new message notification
  /// This is automatically handled by Firebase function when a message is created in ChatRooms/{chatRoomId}/Messages
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    String? messageType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create message document
      // This will automatically trigger the notifyOnNewMessage Firebase function
      await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('Messages')
          .add({
        'senderId': user.uid,
        'text': text,
        'messageType': messageType ?? 'text',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('✅ Message sent in chat room: $chatRoomId');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Trigger meeting proposal notification
  /// This is automatically handled by Firebase function when a DateProposal is created
  Future<void> sendMeetingProposal({
    required String chatRoomId,
    required DateTime proposedDate,
    required String location,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create date proposal document
      // This will automatically trigger the notifyOnNewDateProposal Firebase function
      await _firestore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('DateProposals')
          .add({
        'proposerId': user.uid,
        'proposedDate': Timestamp.fromDate(proposedDate),
        'location': location,
        'notes': notes ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Meeting proposal sent in chat room: $chatRoomId');
    } catch (e) {
      print('❌ Error sending meeting proposal: $e');
      rethrow;
    }
  }

  /// Trigger new match notification
  /// This is automatically handled by Firebase function when a ChatRoom is created
  Future<void> createMatch({
    required String otherUserId,
    String? matchReason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create chat room document
      // This will automatically trigger the notifyOnNewMatch Firebase function
      await _firestore.collection('ChatRooms').add({
        'participants': [user.uid, otherUserId],
        'matchReason': matchReason ?? 'You\'ve been matched!',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      print('✅ Match created with: $otherUserId');
    } catch (e) {
      print('❌ Error creating match: $e');
      rethrow;
    }
  }

  /// Trigger weekly matching algorithm
  /// This calls the runMatchingHttp Firebase function
  Future<void> runWeeklyMatching({
    bool dryRun = false,
    bool sendPush = false,
  }) async {
    try {
      final runId = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      // Call the Firebase function
      final response = await http.get(
        Uri.parse('$_baseUrl/runMatchingHttp?runId=$runId&dryRun=${dryRun ? 1 : 0}&sendPush=${sendPush ? 1 : 0}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Weekly matching completed: $result');
      } else {
        print('❌ Weekly matching failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error running weekly matching: $e');
      rethrow;
    }
  }

  /// Send post notification to all users
  /// This calls the sendPostNotification Firebase function
  Future<void> sendPostNotification({
    required String title,
    required String description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Call the Firebase function
      final response = await http.post(
        Uri.parse('$_baseUrl/sendPostNotification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Post notification sent: $result');
      } else {
        print('❌ Post notification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending post notification: $e');
      rethrow;
    }
  }

  /// Get nearby events (calls the nearbyPHQEvents function)
  Future<List<Map<String, dynamic>>> getNearbyEvents({
    required double latitude,
    required double longitude,
    String radius = '25mi',
    String type = 'mixed',
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nearbyPHQEvents?lat=$latitude&lng=$longitude&radius=$radius&type=$type&page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return List<Map<String, dynamic>>.from(result['events'] ?? []);
      } else {
        print('❌ Failed to get nearby events: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting nearby events: $e');
      return [];
    }
  }
}


