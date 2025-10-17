import 'package:cloud_firestore/cloud_firestore.dart';

<<<<<<< HEAD
/// Event model for calendar events and Ticketmaster events
class Event {
  final String id;
  final String title;
  final String details;
  final DateTime date;
  final String place;
  final String? url;
  final String? status;
  final String? category;
  final String? organizer;
  final String? price;
  final double? distance;
  final EventSource source;
  final double? searchRelevanceScore;

  const Event({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    required this.place,
    this.url,
    this.status,
    this.category,
    this.organizer,
    this.price,
    this.distance,
    this.source = EventSource.ticketmaster,
    this.searchRelevanceScore,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      place: json['place'] ?? '',
      url: json['url'],
      status: json['status'],
      category: json['category'],
      organizer: json['organizer'],
      price: json['price'],
      distance: json['distance']?.toDouble(),
      source: EventSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => EventSource.ticketmaster,
      ),
      searchRelevanceScore: json['searchRelevanceScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'date': date,
      'place': place,
      'url': url,
      'status': status,
      'category': category,
      'organizer': organizer,
      'price': price,
      'distance': distance,
      'source': source.name,
      'searchRelevanceScore': searchRelevanceScore,
    };
  }

  // Getters for display properties
  String get description => details;
  
  bool get isFree => price == null || price!.toLowerCase().contains('free');
  
  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    
    if (eventDay == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else {
      return '${_formatDate(date)}, ${_formatTime(date)}';
    }
  }
  
  String get displayLocation => place.isNotEmpty ? place : 'Location TBD';
  
  String? get displayDistance {
    if (distance == null) return null;
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m away';
    } else {
      return '${distance!.toStringAsFixed(1)}km away';
    }
  }
  
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay == today;
  }
  
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay == tomorrow;
  }
  
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// Event source enum
enum EventSource {
  ticketmaster;

  String get displayName {
    switch (this) {
      case EventSource.ticketmaster:
        return 'Ticketmaster Events';
    }
  }

  String get icon {
    switch (this) {
      case EventSource.ticketmaster:
        return 'calendar';
    }
  }
}
=======
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
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
