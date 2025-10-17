import 'package:cloud_firestore/cloud_firestore.dart';

/// Event Model
class Event {
  final String id;
  final String header;
  final String details;
  final DateTime date;
  final String place;
  final String? imageUrl;
  final String? category;
  final List<String> attendees;
  final String? organizerId;
  
  Event({
    required this.id,
    required this.header,
    required this.details,
    required this.date,
    required this.place,
    this.imageUrl,
    this.category,
    this.attendees = const [],
    this.organizerId,
  });

  /// Create from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      header: data['Header'] ?? '',
      details: data['Details'] ?? '',
      date: (data['Date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: data['Place'] ?? '',
      imageUrl: data['imageUrl'],
      category: data['category'],
      attendees: List<String>.from(data['attendees'] ?? []),
      organizerId: data['organizerId'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'Header': header,
      'Details': details,
      'Date': Timestamp.fromDate(date),
      'Place': place,
      'imageUrl': imageUrl,
      'category': category,
      'attendees': attendees,
      'organizerId': organizerId,
    };
  }

  /// Check if user is attending
  bool isUserAttending(String userId) {
    return attendees.contains(userId);
  }

  /// Get attendee count
  int get attendeeCount => attendees.length;

  Event copyWith({
    String? header,
    String? details,
    DateTime? date,
    String? place,
    String? imageUrl,
    String? category,
    List<String>? attendees,
  }) {
    return Event(
      id: id,
      header: header ?? this.header,
      details: details ?? this.details,
      date: date ?? this.date,
      place: place ?? this.place,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      attendees: attendees ?? this.attendees,
      organizerId: organizerId,
    );
  }
}
