import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Room Model
class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.lastMessageSenderId,
    this.unreadCounts = const {},
  });

  /// Create from Firestore document
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp != null
          ? Timestamp.fromDate(lastMessageTimestamp!)
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
    };
  }

  /// Get other participant ID (for 1-on-1 chats)
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get unread count for specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Get other participant name (for display purposes)
  String get otherParticipantName {
    // This would need to be populated from user data
    // For now, return a placeholder
    return 'Other User';
  }

  /// Get other participant profile image (for display purposes)
  String? get otherParticipantProfileImage {
    // This would need to be populated from user data
    // For now, return null
    return null;
  }

  ChatRoom copyWith({
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
  }) {
    return ChatRoom(
      id: id,
      participants: participants ?? this.participants,
      createdAt: createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}