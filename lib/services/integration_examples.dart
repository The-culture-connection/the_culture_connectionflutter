import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_triggers.dart';

/// IntegrationExamples - Shows how to integrate notification triggers into existing screens
class IntegrationExamples {
  static final NotificationTriggers _notificationTriggers = NotificationTriggers();

  /// Example: Send connection request with notification
  /// Call this when user taps "Connect" button on a profile
  static Future<void> sendConnectionRequestWithNotification({
    required String targetUserId,
    String? customMessage,
    required BuildContext context,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError(context, 'User not authenticated');
        return;
      }

      // Send connection request (this will automatically trigger Firebase function)
      await _notificationTriggers.sendConnectionRequest(
        toUserId: targetUserId,
        fromUserId: user.uid,
        message: customMessage,
      );

      _showSuccess(context, 'Connection request sent!');
    } catch (e) {
      _showError(context, 'Failed to send connection request: $e');
    }
  }

  /// Example: Send message with notification
  /// Call this when user sends a message in chat
  static Future<void> sendMessageWithNotification({
    required String chatRoomId,
    required String messageText,
    required BuildContext context,
  }) async {
    try {
      // Send message (this will automatically trigger Firebase function)
      await _notificationTriggers.sendMessage(
        chatRoomId: chatRoomId,
        text: messageText,
      );

      // Clear the message input or show success feedback
      _showSuccess(context, 'Message sent!');
    } catch (e) {
      _showError(context, 'Failed to send message: $e');
    }
  }

  /// Example: Send meeting proposal with notification
  /// Call this when user proposes a meeting
  static Future<void> sendMeetingProposalWithNotification({
    required String chatRoomId,
    required DateTime proposedDate,
    required String location,
    String? notes,
    required BuildContext context,
  }) async {
    try {
      // Send meeting proposal (this will automatically trigger Firebase function)
      await _notificationTriggers.sendMeetingProposal(
        chatRoomId: chatRoomId,
        proposedDate: proposedDate,
        location: location,
        notes: notes,
      );

      _showSuccess(context, 'Meeting proposal sent!');
    } catch (e) {
      _showError(context, 'Failed to send meeting proposal: $e');
    }
  }

  /// Example: Create match with notification
  /// Call this when users are matched (e.g., from Today's Matches)
  static Future<void> createMatchWithNotification({
    required String otherUserId,
    String? matchReason,
    required BuildContext context,
  }) async {
    try {
      // Create match (this will automatically trigger Firebase function)
      await _notificationTriggers.createMatch(
        otherUserId: otherUserId,
        matchReason: matchReason,
      );

      _showSuccess(context, 'Match created!');
    } catch (e) {
      _showError(context, 'Failed to create match: $e');
    }
  }

  /// Example: Run weekly matching algorithm
  /// Call this from admin panel or scheduled task
  static Future<void> runWeeklyMatchingWithNotifications({
    bool dryRun = false,
    required BuildContext context,
  }) async {
    try {
      await _notificationTriggers.runWeeklyMatching(
        dryRun: dryRun,
        sendPush: !dryRun, // Send push notifications unless it's a dry run
      );

      _showSuccess(context, 'Weekly matching completed!');
    } catch (e) {
      _showError(context, 'Failed to run weekly matching: $e');
    }
  }

  /// Example: Send post notification to all users
  /// Call this when creating a new post
  static Future<void> sendPostNotificationToAllUsers({
    required String title,
    required String description,
    required BuildContext context,
  }) async {
    try {
      await _notificationTriggers.sendPostNotification(
        title: title,
        description: description,
      );

      _showSuccess(context, 'Post notification sent to all users!');
    } catch (e) {
      _showError(context, 'Failed to send post notification: $e');
    }
  }

  /// Example: Get nearby events
  /// Call this to fetch events for the Events screen
  static Future<List<Map<String, dynamic>>> getNearbyEventsWithLocation({
    required double latitude,
    required double longitude,
    String radius = '25mi',
    String type = 'mixed',
  }) async {
    try {
      return await _notificationTriggers.getNearbyEvents(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
      );
    } catch (e) {
      print('❌ Error getting nearby events: $e');
      return [];
    }
  }

  // Helper methods for UI feedback
  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Example usage in a widget:
/// 
/// ```dart
/// // In a profile card or connection screen:
/// ElevatedButton(
///   onPressed: () async {
///     await IntegrationExamples.sendConnectionRequestWithNotification(
///       targetUserId: profile.id,
///       customMessage: 'I\'d like to connect with you!',
///       context: context,
///     );
///   },
///   child: Text('Connect'),
/// )
/// ```
/// 
/// ```dart
/// // In a chat screen:
/// Future<void> _sendMessage() async {
///   if (_messageController.text.isNotEmpty) {
///     await IntegrationExamples.sendMessageWithNotification(
///       chatRoomId: widget.chatRoom.id,
///       messageText: _messageController.text,
///       context: context,
///     );
///     _messageController.clear();
///   }
/// }
/// ```
/// 
/// ```dart
/// // In an admin panel or settings:
/// ElevatedButton(
///   onPressed: () async {
///     await IntegrationExamples.runWeeklyMatchingWithNotifications(
///       dryRun: false,
///       context: context,
///     );
///   },
///   child: Text('Run Weekly Matching'),
/// )
/// ```


