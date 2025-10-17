import 'package:cloud_firestore/cloud_firestore.dart';

/// Event Model
class Event {
  final String id;
  final String header;
  final String details;
  final DateTime date;
  final String place;

  Event({
    required this.id,
    required this.header,
    required this.details,
    required this.date,
    required this.place,
  });

  /// Create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      header: data['Header'] ?? '',
      details: data['Details'] ?? '',
      date: (data['Date'] as Timestamp).toDate(),
      place: data['Place'] ?? '',
    );
  }

  /// Convert Event to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'Header': header,
      'Details': details,
      'Date': Timestamp.fromDate(date),
      'Place': place,
    };
  }

  /// Copy with method
  Event copyWith({
    String? id,
    String? header,
    String? details,
    DateTime? date,
    String? place,
  }) {
    return Event(
      id: id ?? this.id,
      header: header ?? this.header,
      details: details ?? this.details,
      date: date ?? this.date,
      place: place ?? this.place,
    );
  }
}
