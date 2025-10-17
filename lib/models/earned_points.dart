import 'package:cloud_firestore/cloud_firestore.dart';

/// Earned Points Model (for rewards system)
class EarnedPoints {
  final String id;
  final String userId;
  final int points;
  final String action;
  final DateTime timestamp;
  final DateTime date;

  EarnedPoints({
    required this.id,
    required this.userId,
    required this.points,
    required this.action,
    required this.timestamp,
    required this.date,
  });

  /// Create from Firestore document
  factory EarnedPoints.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EarnedPoints(
      id: doc.id,
      userId: data['userId'] ?? '',
      points: data['points'] ?? 0,
      action: data['action'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'points': points,
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'date': Timestamp.fromDate(date),
    };
  }

  /// Get icon for action type
  String get actionIcon {
    switch (action.toLowerCase()) {
      case 'daily_login':
        return '📅';
      case 'profile_complete':
        return '✅';
      case 'new_connection':
        return '🤝';
      case 'event_rsvp':
        return '🎉';
      case 'message_sent':
        return '💬';
      case 'post_created':
        return '📝';
      default:
        return '⭐';
    }
  }

  /// Get display name for action
  String get actionDisplayName {
    switch (action.toLowerCase()) {
      case 'daily_login':
        return 'Daily Login';
      case 'profile_complete':
        return 'Profile Completed';
      case 'new_connection':
        return 'New Connection';
      case 'event_rsvp':
        return 'Event RSVP';
      case 'message_sent':
        return 'Message Sent';
      case 'post_created':
        return 'Post Created';
      default:
        return action;
    }
  }
}
