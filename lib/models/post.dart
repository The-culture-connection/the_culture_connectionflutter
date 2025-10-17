import 'package:cloud_firestore/cloud_firestore.dart';

/// Post model for newsfeed posts
class Post {
  final String id;
  final String title;
  final String description;
  final String type;
  final String userId;
  final String? postPhotoURL;
  final DateTime timestamp;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.userId,
    this.postPhotoURL,
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
      postPhotoURL: json['postPhotoURL'],
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'userId': userId,
      'postPhotoURL': postPhotoURL,
      'timestamp': timestamp,
    };
  }
}