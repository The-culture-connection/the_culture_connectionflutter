import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business.dart';

class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  factory BusinessService() => _instance;
  BusinessService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for businesses
  final Map<String, List<Business>> _cache = {};
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Search for Black-owned businesses from Firestore
  Future<List<Business>> searchBlackOwnedBusinesses({
    required double latitude,
    required double longitude,
    String? term,
    int radius = 10000, // 10km radius in meters
    int limit = 20,
  }) async {
    final cacheKey = '${latitude}_${longitude}_${term ?? ''}';
    
    // Check cache first
    if (_cache.containsKey(cacheKey) && _isCacheValid()) {
      return _cache[cacheKey]!;
    }

    try {
      // Get all city documents first
      final citiesSnapshot = await _firestore.collection('Businesses').get();
      List<Business> allBusinesses = [];
      
      // Iterate through each city document
      for (final cityDoc in citiesSnapshot.docs) {
        try {
          // Get businesses from the results subcollection
          Query query = _firestore
              .collection('Businesses')
              .doc(cityDoc.id)
              .collection('results')
              .where('isBlackOwned', isEqualTo: true);
          
          // Apply search term filter if provided
          if (term != null && term.isNotEmpty) {
            query = query.where('name', isGreaterThanOrEqualTo: term)
                       .where('name', isLessThan: '$term\uf8ff');
          }
          
          final resultsSnapshot = await query.get();
          final cityBusinesses = resultsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Business.fromFirestoreJson(data);
          }).toList();
          allBusinesses.addAll(cityBusinesses);
        } catch (e) {
          print('Error fetching businesses from city ${cityDoc.id}: $e');
          continue;
        }
      }
      
      // Filter by radius if needed
      final filteredBusinesses = allBusinesses.where((business) {
        if (business.latitude == null || business.longitude == null) return true;
        final distance = _calculateDistance(
          latitude, longitude, 
          business.latitude!, business.longitude!
        );
        return distance <= radius;
      }).toList();
      
      // Sort by distance and limit results
      filteredBusinesses.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });
      
      final limitedResults = filteredBusinesses.take(limit).toList();
      
      // Cache the results
      _cache[cacheKey] = limitedResults;
      _lastCacheTime = DateTime.now();
      
      return limitedResults;
    } catch (e) {
      print('Error fetching businesses from Firestore: $e');
      // Return mock data if Firestore fails
      return Business.mockBusinesses;
    }
  }

  // Parse Firestore documents to Business objects
  List<Business> _parseFirestoreBusinesses(List<QueryDocumentSnapshot> docs, double userLat, double userLon) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Calculate distance if coordinates are available
      double? distance;
      double? latitude;
      double? longitude;
      
      if (data['location'] != null && data['location'] is Map) {
        final location = data['location'] as Map<String, dynamic>;
        latitude = location['latitude']?.toDouble();
        longitude = location['longitude']?.toDouble();
        
        if (latitude != null && longitude != null) {
          distance = _calculateDistance(userLat, userLon, latitude, longitude);
        }
      }
      
      // Parse categories array to get the first category
      String category = 'Other';
      if (data['categories'] != null && data['categories'] is List && (data['categories'] as List).isNotEmpty) {
        category = (data['categories'] as List).first.toString();
      }
      
      return Business(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? '',
        category: category,
        address: data['address'] ?? '',
        hours: data['hours'] ?? '',
        phone: data['phone'] ?? '',
        budget: _getPriceLevel(data['price']),
        description: data['description'] ?? '',
        isOnline: data['is_closed'] == false,
        rating: data['rating']?.toDouble(),
        reviewCount: data['review_count'],
        imageURL: null, // Not available in your structure
        website: data['website'],
        distance: distance,
        yelpURL: null, // Not available in your structure
        latitude: latitude,
        longitude: longitude,
      );
    }).toList();
  }

  // Parse a single Firestore document to Business object
  Business _parseSingleFirestoreBusiness(DocumentSnapshot doc, double userLat, double userLon) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Calculate distance if coordinates are available
    double? distance;
    double? latitude;
    double? longitude;
    
    if (data['location'] != null && data['location'] is Map) {
      final location = data['location'] as Map<String, dynamic>;
      latitude = location['latitude']?.toDouble();
      longitude = location['longitude']?.toDouble();
      
      if (latitude != null && longitude != null) {
        distance = _calculateDistance(userLat, userLon, latitude, longitude);
      }
    }
    
    // Parse categories array to get the first category
    String category = 'Other';
    if (data['categories'] != null && data['categories'] is List && (data['categories'] as List).isNotEmpty) {
      category = (data['categories'] as List).first.toString();
    }
    
    return Business(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      category: category,
      address: data['address'] ?? '',
      hours: data['hours'] ?? '',
      phone: data['phone'] ?? '',
      budget: _getPriceLevel(data['price']),
      description: data['description'] ?? '',
      isOnline: data['is_closed'] == false,
      rating: data['rating']?.toDouble(),
      reviewCount: data['review_count'],
      imageURL: null, // Not available in your structure
      website: data['website'],
      distance: distance,
      yelpURL: null, // Not available in your structure
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Helper method to convert price level
  String _getPriceLevel(dynamic price) {
    if (price == null) return '\$';
    if (price is String) return price;
    if (price is int) {
      return '\$' * price; // Convert number to $ symbols
    }
    return '\$';
  }

  // Calculate distance between two coordinates in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * 
        cos(_degreesToRadians(lat1)) * 
        cos(_degreesToRadians(lat2));
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
    _lastCacheTime = null;
  }

  // Get businesses by category from Firestore
  Future<List<Business>> getBusinessesByCategory(String category, {
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    try {
      final citiesSnapshot = await _firestore.collection('Businesses').get();
      List<Business> allBusinesses = [];
      
      for (final cityDoc in citiesSnapshot.docs) {
        try {
          final resultsSnapshot = await _firestore
              .collection('Businesses')
              .doc(cityDoc.id)
              .collection('results')
              .where('isBlackOwned', isEqualTo: true)
              .where('categories', arrayContains: category)
              .limit(limit)
              .get();
          
          final cityBusinesses = resultsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Business.fromFirestoreJson(data);
          }).toList();
          allBusinesses.addAll(cityBusinesses);
        } catch (e) {
          print('Error fetching businesses by category from city ${cityDoc.id}: $e');
          continue;
        }
      }
      
      return allBusinesses;
    } catch (e) {
      print('Error fetching businesses by category: $e');
      return [];
    }
  }

  // Get business by ID from Firestore
  Future<Business?> getBusinessById(String id) async {
    try {
      final citiesSnapshot = await _firestore.collection('Businesses').get();
      
      for (final cityDoc in citiesSnapshot.docs) {
        try {
          final doc = await _firestore
              .collection('Businesses')
              .doc(cityDoc.id)
              .collection('results')
              .doc(id)
              .get();
          
          if (doc.exists) {
            return Business.fromFirestoreJson(doc.data()!);
          }
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching business by ID: $e');
      return null;
    }
  }

  // Get businesses by city from Firestore
  Future<List<Business>> getBusinessesByCity(String city, {
    required double latitude,
    required double longitude,
    int limit = 50,
  }) async {
    try {
      final resultsSnapshot = await _firestore
          .collection('Businesses')
          .doc(city)
          .collection('results')
          .where('isBlackOwned', isEqualTo: true)
          .limit(limit)
          .get();
      
      final businesses = resultsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Business.fromFirestoreJson(data);
      }).toList();
      
      return businesses;
    } catch (e) {
      print('Error fetching businesses by city: $e');
      return [];
    }
  }

  // Get all businesses from Firestore
  Future<List<Business>> getAllBusinesses({
    required double latitude,
    required double longitude,
    int limit = 50,
  }) async {
    try {
      final citiesSnapshot = await _firestore.collection('Businesses').get();
      List<Business> allBusinesses = [];
      
      for (final cityDoc in citiesSnapshot.docs) {
        try {
          final resultsSnapshot = await _firestore
              .collection('Businesses')
              .doc(cityDoc.id)
              .collection('results')
              .where('isBlackOwned', isEqualTo: true)
              .limit(limit)
              .get();
          
          final cityBusinesses = resultsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Business.fromFirestoreJson(data);
          }).toList();
          allBusinesses.addAll(cityBusinesses);
        } catch (e) {
          print('Error fetching all businesses from city ${cityDoc.id}: $e');
          continue;
        }
      }
      
      return allBusinesses;
    } catch (e) {
      print('Error fetching all businesses: $e');
      return [];
    }
  }
}