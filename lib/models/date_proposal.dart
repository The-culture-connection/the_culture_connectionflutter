import 'package:cloud_firestore/cloud_firestore.dart';

/// Date Proposal Model
class DateProposal {
  final String id;
  final String proposerId;
  final String details;
  final DateTime date;
  final String place;
  final DateTime timestamp;
  final String status; // pending, accepted, rejected

  DateProposal({
    required this.id,
    required this.proposerId,
    required this.details,
    required this.date,
    required this.place,
    DateTime? timestamp,
    this.status = 'pending',
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create DateProposal from Firestore document
  factory DateProposal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DateProposal(
      id: doc.id,
      proposerId: data['proposerId'] ?? '',
      details: data['details'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      place: data['place'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  /// Convert DateProposal to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'proposerId': proposerId,
      'details': details,
      'date': Timestamp.fromDate(date),
      'place': place,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  /// Copy with method
  DateProposal copyWith({
    String? id,
    String? proposerId,
    String? details,
    DateTime? date,
    String? place,
    DateTime? timestamp,
    String? status,
  }) {
    return DateProposal(
      id: id ?? this.id,
      proposerId: proposerId ?? this.proposerId,
      details: details ?? this.details,
      date: date ?? this.date,
      place: place ?? this.place,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
