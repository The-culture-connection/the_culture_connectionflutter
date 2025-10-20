import 'package:cloud_firestore/cloud_firestore.dart';

class DateProposal {
  final String id;
  final String proposerId;
  final String details;
  final DateTime date;
  final String place;
  final DateTime timestamp;
  final String status; // "Pending", "Accepted", or "Declined"

  DateProposal({
    required this.id,
    required this.proposerId,
    required this.details,
    required this.date,
    required this.place,
    required this.timestamp,
    required this.status,
  });

  factory DateProposal.fromMap(Map<String, dynamic> data, String id) {
    return DateProposal(
      id: id,
      proposerId: data['proposerId'] ?? '',
      details: data['details'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: data['place'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }

  factory DateProposal.fromFirestore(DocumentSnapshot doc, String receiverId) {
    final data = doc.data() as Map<String, dynamic>;
    return DateProposal(
      id: doc.id,
      proposerId: data['proposerId'] ?? '',
      details: data['details'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: data['place'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'proposerId': proposerId,
      'details': details,
      'date': Timestamp.fromDate(date),
      'place': place,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

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
}