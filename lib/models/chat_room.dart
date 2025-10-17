import 'package:cloud_firestore/cloud_firestore.dart';

<<<<<<< HEAD
/// ChatRoom model - Equivalent to iOS ChatRoom struct
class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final String lastMessageSenderId;
  final String otherParticipantName;
  final String? otherParticipantProfileImage;

  const ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    required this.otherParticipantName,
    this.otherParticipantProfileImage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      otherParticipantName: json['otherParticipantName'] ?? 'Unknown',
      otherParticipantProfileImage: json['otherParticipantProfileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'otherParticipantName': otherParticipantName,
      'otherParticipantProfileImage': otherParticipantProfileImage,
    };
  }
}

/// Message model - Equivalent to iOS Message struct
class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: id,
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

/// DateProposal model - Equivalent to iOS DateProposal struct
class DateProposal {
  final String id;
  final String proposerId;
  final String details;
  final DateTime date;
  final String place;
  final Timestamp timestamp;
  final String status; // "Pending", "Accepted", or "Declined"

  const DateProposal({
    required this.id,
    required this.proposerId,
    required this.details,
    required this.date,
    required this.place,
    required this.timestamp,
    required this.status,
  });

  factory DateProposal.fromJson(Map<String, dynamic> json, String id) {
    return DateProposal(
      id: id,
      proposerId: json['proposerId'] ?? '',
      details: json['details'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: json['place'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposerId': proposerId,
      'details': details,
      'date': Timestamp.fromDate(date),
      'place': place,
      'timestamp': timestamp,
      'status': status,
    };
  }
=======
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
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
}
