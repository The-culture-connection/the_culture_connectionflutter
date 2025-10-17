import 'package:cloud_firestore/cloud_firestore.dart';

/// Message Model
class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? replyToId;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.replyToId,
  });

  /// Create from Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      replyToId: data['replyToId'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'replyToId': replyToId,
    };
  }

  Message copyWith({
    String? text,
    bool? isRead,
    String? imageUrl,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      text: text ?? this.text,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      replyToId: replyToId,
    );
  }
}
