import 'package:cloud_firestore/cloud_firestore.dart';

/// Connection Model (for connection requests and matches)
class Connection {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;
  final String? type; // 'mentorship', 'networking', 'romantic', 'friendship'
  final String? status; // 'pending', 'accepted', 'declined'

  Connection({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
    this.type,
    this.status = 'pending',
  });

  /// Create from Firestore document
  factory Connection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Connection(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'],
      status: data['status'] ?? 'pending',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'status': status,
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  Connection copyWith({String? status}) {
    return Connection(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      timestamp: timestamp,
      type: type,
      status: status ?? this.status,
    );
  }
}

/// Match Model (mutual connections)
class Match {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime timestamp;
  final String? type;

  Match({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.timestamp,
    this.type,
  });

  /// Create from Firestore document
  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
    };
  }

  /// Get other user ID in match
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}
