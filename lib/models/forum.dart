import 'package:cloud_firestore/cloud_firestore.dart';

/// Forum Model
class Forum {
  final String id;
  final String title;
  final String createdBy;
  final DateTime timestamp;
  final String? description;
  final List<String> members;
  final int messageCount;

  Forum({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.timestamp,
    this.description,
    this.members = const [],
    this.messageCount = 0,
  });

  /// Create from Firestore document
  factory Forum.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Forum(
      id: doc.id,
      title: data['title'] ?? '',
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      members: List<String>.from(data['members'] ?? []),
      messageCount: data['messageCount'] ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'members': members,
      'messageCount': messageCount,
    };
  }

  /// Check if user is member
  bool isMember(String userId) {
    return members.contains(userId);
  }

  int get memberCount => members.length;

  Forum copyWith({
    String? title,
    String? description,
    List<String>? members,
    int? messageCount,
  }) {
    return Forum(
      id: id,
      title: title ?? this.title,
      createdBy: createdBy,
      timestamp: timestamp,
      description: description ?? this.description,
      members: members ?? this.members,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
