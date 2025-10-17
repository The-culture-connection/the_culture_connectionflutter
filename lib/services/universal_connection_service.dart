import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Universal Connection Service - Handles all connection logic across the app
class UniversalConnectionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a connection request to another user
  static Future<ConnectionResult> sendConnectionRequest({
    required String toUserId,
    required String context,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ConnectionResult(
          success: false,
          message: 'You must be logged in to send connection requests',
        );
      }

      // Check if connection already exists
      final existingConnection = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      if (existingConnection.docs.isNotEmpty) {
        return ConnectionResult(
          success: false,
          message: 'Connection request already sent',
        );
      }

      // Check if there's a mutual connection
      final mutualConnection = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: currentUser.uid)
          .get();

      bool isMatch = false;
      if (mutualConnection.docs.isNotEmpty) {
        // Mutual connection exists - create a match
        isMatch = true;
        await _createMatch(currentUser.uid, toUserId);
        await _createChatRoom(currentUser.uid, toUserId);
      }

      // Create connection request
      await _firestore.collection('connections').add({
        'fromUserId': currentUser.uid,
        'toUserId': toUserId,
        'status': 'pending',
        'context': context,
        'createdAt': FieldValue.serverTimestamp(),
        'isMatch': isMatch,
      });

      // Send notification
      await _sendConnectionNotification(toUserId, isMatch);

      return ConnectionResult(
        success: true,
        message: isMatch 
            ? 'It\'s a match! You can now chat with this person.'
            : 'Connection request sent successfully',
        isMatch: isMatch,
      );

    } catch (e) {
      print('Error sending connection request: $e');
      return ConnectionResult(
        success: false,
        message: 'Failed to send connection request: $e',
      );
    }
  }

  /// Create a match between two users
  static Future<void> _createMatch(String userId1, String userId2) async {
    try {
      await _firestore.collection('matches').add({
        'user1Id': userId1,
        'user2Id': userId2,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating match: $e');
    }
  }

  /// Create a chat room between two users
  static Future<void> _createChatRoom(String userId1, String userId2) async {
    try {
      await _firestore.collection('chatRooms').add({
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      });
    } catch (e) {
      print('Error creating chat room: $e');
    }
  }

  /// Send notification to the target user
  static Future<void> _sendConnectionNotification(String toUserId, bool isMatch) async {
    try {
      // Get target user's FCM token
      final userDoc = await _firestore.collection('Profiles').doc(toUserId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // Send push notification via Firebase Cloud Messaging
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=YOUR_SERVER_KEY', // Replace with actual server key
          },
          body: json.encode({
            'to': fcmToken,
            'notification': {
              'title': isMatch ? 'New Match! 🎉' : 'New Connection Request',
              'body': isMatch 
                  ? 'You have a new match! Start chatting now.'
                  : 'Someone wants to connect with you.',
            },
            'data': {
              'type': isMatch ? 'match' : 'connection_request',
              'fromUserId': _auth.currentUser?.uid,
            },
          }),
        );

        if (response.statusCode == 200) {
          print('✅ Notification sent successfully');
        } else {
          print('❌ Failed to send notification: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Get user profile for connection
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('Profiles').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}

/// Result of a connection request
class ConnectionResult {
  final bool success;
  final String message;
  final bool isMatch;

  ConnectionResult({
    required this.success,
    required this.message,
    this.isMatch = false,
  });
}



