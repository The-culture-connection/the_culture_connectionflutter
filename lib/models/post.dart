import 'package:cloud_firestore/cloud_firestore.dart';

<<<<<<< HEAD
/// Post model for newsfeed posts
=======
/// Post Model for news feed
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
class Post {
  final String id;
  final String title;
  final String description;
  final String type;
  final String userId;
  final String? postPhotoURL;
  final DateTime timestamp;
<<<<<<< HEAD

  const Post({
=======
  
  // Metadata
  final int likeCount;
  final int commentCount;
  final int shareCount;

  Post({
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.userId,
    this.postPhotoURL,
    required this.timestamp,
<<<<<<< HEAD
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
=======
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
  });

  /// Create from Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'general',
      userId: data['userId'] ?? '',
      postPhotoURL: data['postPhotoURL'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
      'title': title,
      'description': description,
      'type': type,
      'userId': userId,
      'postPhotoURL': postPhotoURL,
<<<<<<< HEAD
      'timestamp': timestamp,
    };
  }
}
=======
      'timestamp': Timestamp.fromDate(timestamp),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
    };
  }

  Post copyWith({
    String? title,
    String? description,
    String? type,
    String? postPhotoURL,
    int? likeCount,
    int? commentCount,
    int? shareCount,
  }) {
    return Post(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      userId: userId,
      postPhotoURL: postPhotoURL ?? this.postPhotoURL,
      timestamp: timestamp,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }
}
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
