import 'package:cloud_firestore/cloud_firestore.dart';

/// Business Model (for Yelp/black-owned businesses)
class Business {
  final String id;
  final String? name;
  final String? phone;
  final String? website;
  final Map<String, dynamic>? location;
  final List<String>? categories;
  final double? rating;
  final int? reviewCount;
  final String? price;
  final bool? isClosed;
  final List<String>? hours;
  final DateTime? pulledAt;
  final String? cityKey;

  Business({
    required this.id,
    this.name,
    this.phone,
    this.website,
    this.location,
    this.categories,
    this.rating,
    this.reviewCount,
    this.price,
    this.isClosed,
    this.hours,
    this.pulledAt,
    this.cityKey,
  });

  /// Create Business from Firestore document
  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      id: doc.id,
      name: data['name'],
      phone: data['phone'],
      website: data['website'],
      location: data['location'] as Map<String, dynamic>?,
      categories: data['categories'] != null
          ? List<String>.from(data['categories'])
          : null,
      rating: data['rating']?.toDouble(),
      reviewCount: data['review_count'],
      price: data['price'],
      isClosed: data['is_closed'],
      hours: data['hours'] != null ? List<String>.from(data['hours']) : null,
      pulledAt: (data['pulled_at'] as Timestamp?)?.toDate(),
      cityKey: data['cityKey'],
    );
  }

  /// Convert Business to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'website': website,
      'location': location,
      'categories': categories,
      'rating': rating,
      'review_count': reviewCount,
      'price': price,
      'is_closed': isClosed,
      'hours': hours,
      'pulled_at': pulledAt != null ? Timestamp.fromDate(pulledAt!) : null,
      'cityKey': cityKey,
    };
  }

  /// Copy with method
  Business copyWith({
    String? id,
    String? name,
    String? phone,
    String? website,
    Map<String, dynamic>? location,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    String? price,
    bool? isClosed,
    List<String>? hours,
    DateTime? pulledAt,
    String? cityKey,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      price: price ?? this.price,
      isClosed: isClosed ?? this.isClosed,
      hours: hours ?? this.hours,
      pulledAt: pulledAt ?? this.pulledAt,
      cityKey: cityKey ?? this.cityKey,
    );
  }
}
