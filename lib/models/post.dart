import 'package:cloud_firestore/cloud_firestore.dart';

/// Post Model
class Post {
  final String id;
  final String title;
  final String description;
  final String type;
  final String userId;
  final String? postPhotoURL;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.userId,
    this.postPhotoURL,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create Post from Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      userId: data['userId'] ?? '',
      postPhotoURL: data['postPhotoURL'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert Post to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'userId': userId,
      'postPhotoURL': postPhotoURL,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Copy with method
  Post copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? userId,
    String? postPhotoURL,
    DateTime? timestamp,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      postPhotoURL: postPhotoURL ?? this.postPhotoURL,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
