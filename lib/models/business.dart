import 'package:cloud_firestore/cloud_firestore.dart';

/// Business Model (Black-owned businesses)
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
  
  // Computed properties
  String? get address => location?['address'];
  double? get latitude => location?['latitude'];
  double? get longitude => location?['longitude'];

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

  /// Create from Firestore document
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
      hours: data['hours'] != null 
          ? List<String>.from(data['hours']) 
          : null,
      pulledAt: (data['pulled_at'] as Timestamp?)?.toDate(),
      cityKey: data['cityKey'],
    );
  }

  /// Convert to Firestore document
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

  /// Check if business is open now
  bool get isOpenNow {
    // TODO: Implement hours logic
    return isClosed == false;
  }

  /// Get formatted price level
  String get priceLevel {
    if (price == null) return 'N/A';
    return price!;
  }

  /// Get rating stars
  String get ratingStars {
    if (rating == null) return '☆☆☆☆☆';
    final stars = (rating! / 1).round();
    return '★' * stars + '☆' * (5 - stars);
  }
}
