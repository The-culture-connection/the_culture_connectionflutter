import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final String lastMessageSenderId;
  final String otherParticipantName;
  final String? otherParticipantProfileImage;
  final DateTime? createdAt;
  final Map<String, int>? unreadCounts;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    required this.otherParticipantName,
    this.otherParticipantProfileImage,
    this.createdAt,
    this.unreadCounts,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> data, String otherParticipantName, {String? otherParticipantProfileImage}) {
    return ChatRoom(
      id: data['id'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? 'No messages yet',
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      otherParticipantName: otherParticipantName,
      otherParticipantProfileImage: otherParticipantProfileImage,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      unreadCounts: data['unreadCounts'] != null ? Map<String, int>.from(data['unreadCounts']) : null,
    );
  }

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? 'No messages yet',
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      otherParticipantName: data['otherParticipantName'] ?? 'Unknown',
      otherParticipantProfileImage: data['otherParticipantProfileImage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      unreadCounts: data['unreadCounts'] != null ? Map<String, int>.from(data['unreadCounts']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'lastMessageSenderId': lastMessageSenderId,
      'otherParticipantName': otherParticipantName,
      'otherParticipantProfileImage': otherParticipantProfileImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'unreadCounts': unreadCounts,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'lastMessageSenderId': lastMessageSenderId,
      'otherParticipantName': otherParticipantName,
      'otherParticipantProfileImage': otherParticipantProfileImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'unreadCounts': unreadCounts,
    };
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere((id) => id != currentUserId, orElse: () => '');
  }

  int getUnreadCount(String userId) {
    return unreadCounts?[userId] ?? 0;
  }
}