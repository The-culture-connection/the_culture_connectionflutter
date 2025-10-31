import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a business entity with all relevant information for the Culture Connection app.
/// 
/// This class contains all the necessary data about a business including contact information,
/// location details, ratings, and other attributes that help users discover and connect with
/// local businesses in their community.
class Business {
  /// Unique identifier for the business
  final String id;
  final String businessId;
  
  /// Name of the business
  final String name;
  final String businessName;
  
  /// Category or type of business (e.g., "Restaurant", "Beauty & Wellness")
  final String category;
  final String businessCategory;
  
  /// Physical address of the business
  final String address;
  final String? businessAddress;
  
  /// Operating hours of the business
  final String hours;
  
  /// Contact phone number
  final String phone;
  final String? businessPhone;
  
  /// Budget level indicator (e.g., "$", "$$", "$$$")
  final String budget;
  
  /// Description of the business and its services
  final String description;
  final String? businessDescription;
  
  /// Whether the business operates online only
  final bool isOnline;
  
  /// Average customer rating (0.0 to 5.0)
  final double? rating;
  
  /// Number of reviews received
  final int? reviewCount;
  
  /// URL to the business's main image
  final String? imageURL;
  
  /// Business website URL
  final String? website;
  final String? businessWebsite;
  
  /// Distance from user's location in meters
  final double? distance;
  
  /// Yelp profile URL for the business
  final String? yelpURL;
  
  /// Latitude coordinate of the business location
  final double? latitude;
  
  /// Longitude coordinate of the business location
  final double? longitude;
  
  /// Owner user ID
  final String? ownerUserId;
  
  /// Business email
  final String? businessEmail;
  
  /// Creation timestamp
  final DateTime? createdAt;

  /// Creates a new Business instance.
  /// 
  /// [id], [name], [category], [address], [hours], [phone], [budget], 
  /// [description], and [isOnline] are required parameters.
  /// All other parameters are optional and can be null.
  const Business({
    required this.id,
    this.businessId = '',
    required this.name,
    this.businessName = '',
    required this.category,
    this.businessCategory = '',
    required this.address,
    this.businessAddress,
    required this.hours,
    required this.phone,
    this.businessPhone,
    required this.budget,
    required this.description,
    this.businessDescription,
    required this.isOnline,
    this.rating,
    this.reviewCount,
    this.imageURL,
    this.website,
    this.businessWebsite,
    this.distance,
    this.yelpURL,
    this.latitude,
    this.longitude,
    this.ownerUserId,
    this.businessEmail,
    this.createdAt,
  });

  /// Returns a user-friendly display address, showing "No Address" if empty.
  String get displayAddress => address.isNotEmpty ? address : (businessAddress ?? "No Address");
  
  /// Returns a user-friendly display hours, showing "No Hours" if empty.
  String get displayHours => hours.isNotEmpty ? hours : "No Hours";
  
  /// Returns a user-friendly display phone number, showing "No Phone Number" if empty.
  String get displayPhone => phone.isNotEmpty ? phone : (businessPhone ?? "No Phone Number");
  
  /// Returns a user-friendly display description, showing "No Description" if empty.
  String get displayDescription => description.isNotEmpty ? description : (businessDescription ?? "No Description");

  /// Returns the distance converted from meters to miles for display.
  /// Returns null if distance is not available.
  String? get displayDistance {
    if (distance == null) return null;
    final miles = distance! * 0.000621371; // Convert meters to miles
    return "${miles.toStringAsFixed(1)} mi";
  }

  /// Creates a Business instance from a JSON map.
  /// 
  /// This factory constructor handles the conversion from JSON data (typically from
  /// a database or API) to a Business object. All fields are safely handled with
  /// null coalescing operators to provide default values.
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? json['businessId'] ?? '',
      businessId: json['businessId'] ?? json['id'] ?? '',
      name: json['name'] ?? json['businessName'] ?? '',
      businessName: json['businessName'] ?? json['name'] ?? '',
      category: json['category'] ?? json['businessCategory'] ?? '',
      businessCategory: json['businessCategory'] ?? json['category'] ?? '',
      address: json['address'] ?? json['businessAddress'] ?? '',
      businessAddress: json['businessAddress'] ?? json['address'],
      hours: json['hours'] ?? '',
      phone: json['phone'] ?? json['businessPhone'] ?? '',
      businessPhone: json['businessPhone'] ?? json['phone'],
      budget: json['budget'] ?? '',
      description: json['description'] ?? json['businessDescription'] ?? '',
      businessDescription: json['businessDescription'] ?? json['description'],
      isOnline: json['isOnline'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      imageURL: json['imageURL'],
      website: json['website'] ?? json['businessWebsite'],
      businessWebsite: json['businessWebsite'] ?? json['website'],
      distance: json['distance']?.toDouble(),
      yelpURL: json['yelpURL'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      ownerUserId: json['ownerUserId'],
      businessEmail: json['businessEmail'],
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] != null 
              ? DateTime.parse(json['createdAt'])
              : null,
    );
  }

  /// Create from Firestore document
  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      id: doc.id,
      businessId: doc.id,
      name: data['name'] ?? data['businessName'] ?? '',
      businessName: data['businessName'] ?? data['name'] ?? '',
      category: data['category'] ?? data['businessCategory'] ?? '',
      businessCategory: data['businessCategory'] ?? data['category'] ?? '',
      address: data['address'] ?? data['businessAddress'] ?? '',
      businessAddress: data['businessAddress'] ?? data['address'],
      hours: data['hours'] ?? '',
      phone: data['phone'] ?? data['businessPhone'] ?? '',
      businessPhone: data['businessPhone'] ?? data['phone'],
      budget: data['budget'] ?? '',
      description: data['description'] ?? data['businessDescription'] ?? data['Description'] ?? '',
      businessDescription: data['description'] ?? data['businessDescription'] ?? data['Description'] ?? '',
      isOnline: data['isOnline'] ?? false,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
      imageURL: data['imageURL'],
      website: data['website'] ?? data['businessWebsite'],
      businessWebsite: data['businessWebsite'] ?? data['website'],
      distance: data['distance']?.toDouble(),
      yelpURL: data['yelpURL'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      ownerUserId: data['ownerUserId'],
      businessEmail: data['businessEmail'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create Business from Firestore data structure
  factory Business.fromFirestoreJson(Map<String, dynamic> data) {
    // Parse categories array to get the first category
    String category = 'Other';
    if (data['categories'] != null && data['categories'] is List && (data['categories'] as List).isNotEmpty) {
      category = (data['categories'] as List).first.toString();
    }
    
    // Parse hours array to create a readable string
    String hours = '';
    if (data['hours'] != null && data['hours'] is List && (data['hours'] as List).isNotEmpty) {
      final hoursList = data['hours'] as List;
      if (hoursList.isNotEmpty && hoursList.first is Map) {
        final firstHours = hoursList.first as Map<String, dynamic>;
        if (firstHours['open'] != null && firstHours['open'] is List) {
          final openHours = firstHours['open'] as List;
          if (openHours.isNotEmpty) {
            final dayHours = openHours.first as Map<String, dynamic>;
            final start = dayHours['start']?.toString() ?? '';
            final end = dayHours['end']?.toString() ?? '';
            if (start.isNotEmpty && end.isNotEmpty) {
              hours = '${_formatTime(start)} - ${_formatTime(end)}';
            }
          }
        }
      }
    }
    
    // Get coordinates from location object
    double? latitude;
    double? longitude;
    if (data['location'] != null && data['location'] is Map) {
      final location = data['location'] as Map<String, dynamic>;
      if (location['coordinates'] != null && location['coordinates'] is Map) {
        final coords = location['coordinates'] as Map<String, dynamic>;
        latitude = coords['latitude']?.toDouble();
        longitude = coords['longitude']?.toDouble();
      }
    }
    
    return Business(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      category: category,
      address: data['address'] ?? '',
      hours: hours,
      phone: data['phone'] ?? '',
      budget: _getPriceLevel(data['price']),
      description: data['description'] ?? '',
      isOnline: data['is_closed'] != true,
      rating: data['rating']?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] ?? 0,
      imageURL: null, // Not available in your structure
      website: data['website'],
      distance: null, // Will be calculated by service
      yelpURL: null, // Not available in your structure
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _getPriceLevel(dynamic price) {
    if (price == null) return '\$';
    if (price is String) return price;
    if (price is int) {
      return '\$' * price; // Convert number to $ symbols
    }
    return '\$';
  }

  static String _formatTime(String timeString) {
    if (timeString.length >= 4) {
      final hours = int.tryParse(timeString.substring(0, 2)) ?? 0;
      final minutes = int.tryParse(timeString.substring(2, 4)) ?? 0;
      final period = hours >= 12 ? 'PM' : 'AM';
      final displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
      return '$displayHours:${minutes.toString().padLeft(2, '0')} $period';
    }
    return timeString;
  }

  /// Converts the Business instance to a JSON map.
  /// 
  /// This method is used for serializing the Business object to JSON format,
  /// typically for storage in a database or transmission over an API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'businessName': businessName,
      'category': category,
      'businessCategory': businessCategory,
      'address': address,
      'businessAddress': businessAddress,
      'hours': hours,
      'phone': phone,
      'businessPhone': businessPhone,
      'budget': budget,
      'description': description,
      'businessDescription': businessDescription,
      'isOnline': isOnline,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageURL': imageURL,
      'website': website,
      'businessWebsite': businessWebsite,
      'distance': distance,
      'yelpURL': yelpURL,
      'latitude': latitude,
      'longitude': longitude,
      'ownerUserId': ownerUserId,
      'businessEmail': businessEmail,
      'createdAt': createdAt,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'businessName': businessName,
      'category': category,
      'businessCategory': businessCategory,
      'address': address,
      'businessAddress': businessAddress,
      'hours': hours,
      'phone': phone,
      'businessPhone': businessPhone,
      'budget': budget,
      'description': description,
      'businessDescription': businessDescription,
      'isOnline': isOnline,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageURL': imageURL,
      'website': website,
      'businessWebsite': businessWebsite,
      'distance': distance,
      'yelpURL': yelpURL,
      'latitude': latitude,
      'longitude': longitude,
      'ownerUserId': ownerUserId,
      'businessEmail': businessEmail,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  Business copyWith({
    String? id,
    String? businessId,
    String? name,
    String? businessName,
    String? category,
    String? businessCategory,
    String? address,
    String? businessAddress,
    String? hours,
    String? phone,
    String? businessPhone,
    String? budget,
    String? description,
    String? businessDescription,
    bool? isOnline,
    double? rating,
    int? reviewCount,
    String? imageURL,
    String? website,
    String? businessWebsite,
    double? distance,
    String? yelpURL,
    double? latitude,
    double? longitude,
    String? ownerUserId,
    String? businessEmail,
    DateTime? createdAt,
  }) {
    return Business(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      businessCategory: businessCategory ?? this.businessCategory,
      address: address ?? this.address,
      businessAddress: businessAddress ?? this.businessAddress,
      hours: hours ?? this.hours,
      phone: phone ?? this.phone,
      businessPhone: businessPhone ?? this.businessPhone,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      businessDescription: businessDescription ?? this.businessDescription,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageURL: imageURL ?? this.imageURL,
      website: website ?? this.website,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      distance: distance ?? this.distance,
      yelpURL: yelpURL ?? this.yelpURL,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      businessEmail: businessEmail ?? this.businessEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Mock data for testing and development purposes.
  /// 
  /// This static getter provides a list of sample Business objects that can be used
  /// for testing the UI components and functionality without requiring real data.
  static List<Business> get mockBusinesses => [
    const Business(
      id: "1",
      name: "Power Academy",
      category: "Education & Coaching",
      address: "7074 Harrison Ave #2, Cincinnati, OH 45247",
      hours: "Book Consultation",
      phone: "(513) 268-7215",
      budget: "\$",
      description: "To emPOWER students with the mental, physical, emotional, and spiritual tools to navigate life's challenges",
      isOnline: false,
      rating: 4.5,
      reviewCount: 12,
      imageURL: null,
      website: null,
      distance: 2.3,
      yelpURL: "https://www.yelp.com/biz/power-academy-cincinnati",
      latitude: 39.1031,
      longitude: -84.5120,
    ),
    const Business(
      id: "2",
      name: "Unknown Business",
      category: "Other",
      address: "",
      hours: "",
      phone: "",
      budget: "\$\$",
      description: "",
      isOnline: true,
      rating: null,
      reviewCount: null,
      imageURL: null,
      website: null,
      distance: null,
      yelpURL: null,
      latitude: null,
      longitude: null,
    ),
    const Business(
      id: "3",
      name: "Black Excellence Salon",
      category: "Beauty & Wellness",
      address: "1234 Main St, Cincinnati, OH 45202",
      hours: "Mon-Fri: 9AM-7PM, Sat: 10AM-5PM",
      phone: "(513) 555-0123",
      budget: "\$\$",
      description: "Professional hair styling and beauty services for all hair types",
      isOnline: false,
      rating: 4.8,
      reviewCount: 45,
      imageURL: null,
      website: null,
      distance: 1.2,
      yelpURL: "https://www.yelp.com/biz/black-excellence-salon-cincinnati",
      latitude: 39.1234,
      longitude: -84.5678,
    ),
    const Business(
      id: "4",
      name: "Soul Food Kitchen",
      category: "Restaurant",
      address: "5678 Oak Ave, Cincinnati, OH 45206",
      hours: "Tue-Sun: 11AM-10PM",
      phone: "(513) 555-0456",
      budget: "\$\$",
      description: "Authentic soul food with a modern twist. Family-owned since 1995.",
      isOnline: true,
      rating: 4.6,
      reviewCount: 89,
      imageURL: null,
      website: null,
      distance: 3.1,
      yelpURL: "https://www.yelp.com/biz/soul-food-kitchen-cincinnati",
      latitude: 39.2345,
      longitude: -84.6789,
    ),
  ];
}