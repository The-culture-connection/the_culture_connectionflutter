import 'package:cloud_firestore/cloud_firestore.dart';

/// EventRSVP model - Equivalent to iOS EventRSVP.swift
class EventRSVP {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final String eventLocation;
  final String eventAddress;
  final double eventLatitude;
  final double eventLongitude;
  final String eventOrganizer;
  final String eventCategory;
  final String eventSource;
  final String eventUrl;
  final String eventImageURL;
  final bool eventIsFree;
  final String eventPrice;
  final List<String> rsvpUsers;
  final int rsvpCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userId;

  const EventRSVP({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventLocation,
    required this.eventAddress,
    required this.eventLatitude,
    required this.eventLongitude,
    required this.eventOrganizer,
    required this.eventCategory,
    required this.eventSource,
    required this.eventUrl,
    required this.eventImageURL,
    required this.eventIsFree,
    required this.eventPrice,
    required this.rsvpUsers,
    required this.rsvpCount,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userId,
  });

  /// Create EventRSVP from Firestore data
  factory EventRSVP.fromFirestore(Map<String, dynamic> data, String documentId) {
    return EventRSVP(
      id: documentId,
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      eventStartDate: (data['eventStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventEndDate: (data['eventEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventLocation: data['eventLocation'] ?? '',
      eventAddress: data['eventAddress'] ?? '',
      eventLatitude: (data['eventLatitude'] ?? 0.0).toDouble(),
      eventLongitude: (data['eventLongitude'] ?? 0.0).toDouble(),
      eventOrganizer: data['eventOrganizer'] ?? '',
      eventCategory: data['eventCategory'] ?? '',
      eventSource: data['eventSource'] ?? '',
      eventUrl: data['eventUrl'] ?? '',
      eventImageURL: data['eventImageURL'] ?? '',
      eventIsFree: data['eventIsFree'] ?? false,
      eventPrice: data['eventPrice'] ?? '',
      rsvpUsers: List<String>.from(data['rsvpUsers'] ?? []),
      rsvpCount: data['rsvpCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['userName'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'eventStartDate': eventStartDate,
      'eventEndDate': eventEndDate,
      'eventLocation': eventLocation,
      'eventAddress': eventAddress,
      'eventLatitude': eventLatitude,
      'eventLongitude': eventLongitude,
      'eventOrganizer': eventOrganizer,
      'eventCategory': eventCategory,
      'eventSource': eventSource,
      'eventUrl': eventUrl,
      'eventImageURL': eventImageURL,
      'eventIsFree': eventIsFree,
      'eventPrice': eventPrice,
      'rsvpUsers': rsvpUsers,
      'rsvpCount': rsvpCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userName': userName,
      'userId': userId,
    };
  }

  /// Get time ago display
  String get timeAgoDisplay {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}


