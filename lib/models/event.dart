import 'package:cloud_firestore/cloud_firestore.dart';

/// Event model for calendar events and Ticketmaster events
class Event {
  final String id;
  final String title;
  final String header;
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
  final String? imageUrl;
  final List<String> attendees;
  final String? organizerId;
  final bool isFree;

  const Event({
    required this.id,
    required this.title,
    required this.header,
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
    this.imageUrl,
    this.attendees = const [],
    this.organizerId,
    this.isFree = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      header: json['header'] ?? json['title'] ?? '',
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
      imageUrl: json['imageUrl'],
      attendees: List<String>.from(json['attendees'] ?? []),
      organizerId: json['organizerId'],
      isFree: json['isFree'] ?? false,
    );
  }

  /// Create from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? data['Header'] ?? '',
      header: data['header'] ?? data['Header'] ?? '',
      details: data['details'] ?? data['Details'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? 
            (data['Date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      place: data['place'] ?? data['Place'] ?? '',
      url: data['url'],
      status: data['status'],
      category: data['category'],
      organizer: data['organizer'],
      price: data['price'],
      distance: data['distance']?.toDouble(),
      source: EventSource.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => EventSource.ticketmaster,
      ),
      searchRelevanceScore: data['searchRelevanceScore']?.toDouble(),
      imageUrl: data['imageUrl'],
      attendees: List<String>.from(data['attendees'] ?? []),
      organizerId: data['organizerId'],
      isFree: data['isFree'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'header': header,
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
      'imageUrl': imageUrl,
      'attendees': attendees,
      'organizerId': organizerId,
      'isFree': isFree,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'Header': header,
      'Details': details,
      'Date': Timestamp.fromDate(date),
      'Place': place,
      'url': url,
      'status': status,
      'category': category,
      'organizer': organizer,
      'price': price,
      'distance': distance,
      'source': source.name,
      'searchRelevanceScore': searchRelevanceScore,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'organizerId': organizerId,
      'isFree': isFree,
    };
  }

  /// Check if user is attending
  bool isUserAttending(String userId) {
    return attendees.contains(userId);
  }

  /// Get attendee count
  int get attendeeCount => attendees.length;

  // Getters for display properties
  String get description => details;
  
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

  Event copyWith({
    String? title,
    String? header,
    String? details,
    DateTime? date,
    String? place,
    String? url,
    String? status,
    String? category,
    String? organizer,
    String? price,
    double? distance,
    EventSource? source,
    double? searchRelevanceScore,
    String? imageUrl,
    List<String>? attendees,
    String? organizerId,
    bool? isFree,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      header: header ?? this.header,
      details: details ?? this.details,
      date: date ?? this.date,
      place: place ?? this.place,
      url: url ?? this.url,
      status: status ?? this.status,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      source: source ?? this.source,
      searchRelevanceScore: searchRelevanceScore ?? this.searchRelevanceScore,
      imageUrl: imageUrl ?? this.imageUrl,
      attendees: attendees ?? this.attendees,
      organizerId: organizerId ?? this.organizerId,
      isFree: isFree ?? this.isFree,
    );
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