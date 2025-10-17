import 'package:cloud_firestore/cloud_firestore.dart';

/// ChatRoom Model
class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final String? lastMessageSenderId;

  ChatRoom({
    required this.id,
    required this.participants,
    DateTime? createdAt,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.lastMessageSenderId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create ChatRoom from Firestore document
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
    );
  }

  /// Convert ChatRoom to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp != null
          ? Timestamp.fromDate(lastMessageTimestamp!)
          : null,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }

  /// Get other participant's ID
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Copy with method
  ChatRoom copyWith({
    String? id,
    List<String>? participants,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    String? lastMessageSenderId,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
    );
  }
}
