import 'package:cloud_firestore/cloud_firestore.dart';

/// Forum Model
class Forum {
  final String forumId;
  final String forumName;
  final String? forumDescription;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final int postCount;

  Forum({
    required this.forumId,
    required this.forumName,
    this.forumDescription,
    required this.createdBy,
    required this.createdAt,
    this.memberCount = 1,
    this.postCount = 0,
  });

  /// Create from Firestore document
  factory Forum.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Forum(
      forumId: doc.id,
      forumName: data['forumName'] ?? '',
      forumDescription: data['forumDescription'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberCount: data['memberCount'] ?? 1,
      postCount: data['postCount'] ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'forumName': forumName,
      'forumDescription': forumDescription,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberCount': memberCount,
      'postCount': postCount,
    };
  }

  Forum copyWith({
    String? forumName,
    String? forumDescription,
    int? memberCount,
    int? postCount,
  }) {
    return Forum(
      forumId: forumId,
      forumName: forumName ?? this.forumName,
      forumDescription: forumDescription ?? this.forumDescription,
      createdBy: createdBy,
      createdAt: createdAt,
      memberCount: memberCount ?? this.memberCount,
      postCount: postCount ?? this.postCount,
    );
  }
}
