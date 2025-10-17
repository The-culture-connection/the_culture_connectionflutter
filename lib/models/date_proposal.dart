import 'package:cloud_firestore/cloud_firestore.dart';

/// Date Proposal Model
class DateProposal {
  final String id;
  final String proposerId;
  final String receiverId;
  final String details;
  final DateTime date;
  final String place;
  final DateTime timestamp;
  final String status; // 'pending', 'accepted', 'declined', 'cancelled'

  DateProposal({
    required this.id,
    required this.proposerId,
    required this.receiverId,
    required this.details,
    required this.date,
    required this.place,
    required this.timestamp,
    this.status = 'pending',
  });

  /// Create from Firestore document
  factory DateProposal.fromFirestore(DocumentSnapshot doc, String receiverId) {
    final data = doc.data() as Map<String, dynamic>;
    return DateProposal(
      id: doc.id,
      proposerId: data['proposerId'] ?? '',
      receiverId: receiverId,
      details: data['details'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: data['place'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  /// Convert to Firestore document
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

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCancelled => status == 'cancelled';

  DateProposal copyWith({
    String? details,
    DateTime? date,
    String? place,
    String? status,
  }) {
    return DateProposal(
      id: id,
      proposerId: proposerId,
      receiverId: receiverId,
      details: details ?? this.details,
      date: date ?? this.date,
      place: place ?? this.place,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}
