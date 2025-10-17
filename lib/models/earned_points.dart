import 'package:cloud_firestore/cloud_firestore.dart';

/// Earned Points Model
class EarnedPoints {
  final String id;
  final String userId;
  final int points;
  final String action;
  final DateTime timestamp;
  final DateTime date;

  EarnedPoints({
    required this.id,
    required this.userId,
    required this.points,
    required this.action,
    DateTime? timestamp,
    DateTime? date,
  })  : timestamp = timestamp ?? DateTime.now(),
        date = date ?? DateTime.now();

  /// Create EarnedPoints from Firestore document
  factory EarnedPoints.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EarnedPoints(
      id: doc.id,
      userId: data['userId'] ?? '',
      points: data['points'] ?? 0,
      action: data['action'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  /// Convert EarnedPoints to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'points': points,
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'date': Timestamp.fromDate(date),
    };
  }

  /// Copy with method
  EarnedPoints copyWith({
    String? id,
    String? userId,
    int? points,
    String? action,
    DateTime? timestamp,
    DateTime? date,
  }) {
    return EarnedPoints(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
    );
  }
}
