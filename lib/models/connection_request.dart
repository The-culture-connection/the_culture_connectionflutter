import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionRequest {
  final String? id;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;

  ConnectionRequest({
    this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
  });

  factory ConnectionRequest.fromMap(Map<String, dynamic> data, String id) {
    return ConnectionRequest(
      id: id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ConnectionRequestWithProfile {
  final ConnectionRequest request;
  final ConnectionUserProfile profile;

  ConnectionRequestWithProfile({
    required this.request,
    required this.profile,
  });

  String get id => request.id ?? '';
}

class ConnectionUserProfile {
  final String id;
  final String fullName;
  final int age;
  final String jobTitle;
  final String? photoURL;

  ConnectionUserProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.jobTitle,
    this.photoURL,
  });

  factory ConnectionUserProfile.fromMap(Map<String, dynamic> data, String id) {
    return ConnectionUserProfile(
      id: id,
      fullName: data['Full Name'] ?? 'Unknown',
      age: data['Age'] ?? 0,
      jobTitle: data['Job Title'] ?? 'N/A',
      photoURL: data['photoURL'],
    );
  }
}
