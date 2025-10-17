/// Represents a business entity with all relevant information for the Culture Connection app.
/// 
/// This class contains all the necessary data about a business including contact information,
/// location details, ratings, and other attributes that help users discover and connect with
/// local businesses in their community.
class Business {
  /// Unique identifier for the business
  final String id;
  
  /// Name of the business
  final String name;
  
  /// Category or type of business (e.g., "Restaurant", "Beauty & Wellness")
  final String category;
  
  /// Physical address of the business
  final String address;
  
  /// Operating hours of the business
  final String hours;
  
  /// Contact phone number
  final String phone;
  
  /// Budget level indicator (e.g., "$", "$$", "$$$")
  final String budget;
  
  /// Description of the business and its services
  final String description;
  
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
  
  /// Distance from user's location in meters
  final double? distance;
  
  /// Yelp profile URL for the business
  final String? yelpURL;
  
  /// Latitude coordinate of the business location
  final double? latitude;
  
  /// Longitude coordinate of the business location
  final double? longitude;

  /// Creates a new Business instance.
  /// 
  /// [id], [name], [category], [address], [hours], [phone], [budget], 
  /// [description], and [isOnline] are required parameters.
  /// All other parameters are optional and can be null.
  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.hours,
    required this.phone,
    required this.budget,
    required this.description,
    required this.isOnline,
    this.rating,
    this.reviewCount,
    this.imageURL,
    this.website,
    this.distance,
    this.yelpURL,
    this.latitude,
    this.longitude,
  });

  /// Returns a user-friendly display address, showing "No Address" if empty.
  String get displayAddress => address.isEmpty ? "No Address" : address;
  
  /// Returns a user-friendly display hours, showing "No Hours" if empty.
  String get displayHours => hours.isEmpty ? "No Hours" : hours;
  
  /// Returns a user-friendly display phone number, showing "No Phone Number" if empty.
  String get displayPhone => phone.isEmpty ? "No Phone Number" : phone;
  
  /// Returns a user-friendly display description, showing "No Description" if empty.
  String get displayDescription => description.isEmpty ? "No Description" : description;

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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      hours: json['hours'] ?? '',
      phone: json['phone'] ?? '',
      budget: json['budget'] ?? '',
      description: json['description'] ?? '',
      isOnline: json['isOnline'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      imageURL: json['imageURL'],
      website: json['website'],
      distance: json['distance']?.toDouble(),
      yelpURL: json['yelpURL'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
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
      'name': name,
      'category': category,
      'address': address,
      'hours': hours,
      'phone': phone,
      'budget': budget,
      'description': description,
      'isOnline': isOnline,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageURL': imageURL,
      'website': website,
      'distance': distance,
      'yelpURL': yelpURL,
      'latitude': latitude,
      'longitude': longitude,
    };
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