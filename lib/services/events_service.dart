import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/event.dart';

/// EventsService - Equivalent to iOS EventsService.swift
class EventsService extends ChangeNotifier {
  // Your deployed function URL (from iOS version)
  static const String _baseUrl = 'https://ticketmastersearch-z66sdcydda-uc.a.run.app';
  
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingCache = false;
  
  // Cache management
  final Map<String, List<Event>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 24);
  static const Duration _searchCacheExpiration = Duration(hours: 1);

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingCache => _isUsingCache;

  /// Search events using coordinates
  Future<void> searchEvents({
    double? latitude,
    double? longitude,
    String? location,
    int radius = 25,
    int limit = 25,
  }) async {
    // Create cache key based on location
    final cacheKey = _createCacheKey(latitude, longitude, location, radius);
    
    // Check cache first
    if (_isCacheValid(cacheKey)) {
      _events = _cache[cacheKey]!;
      _isUsingCache = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      print('🎯 Events Cache Hit: Found ${_events.length} cached events');
      return;
    }
    
    print('🔍 Events Cache Miss: Fetching fresh data from Ticketmaster API');
    _isUsingCache = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final events = await _fetchTicketmasterEvents(
        latitude: latitude,
        longitude: longitude,
        location: location,
        radius: radius,
        size: limit,
      );
      
      // Cache the results
      _cache[cacheKey] = events;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      _events = events;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      
      if (events.isEmpty) {
        print('⚠️ No real events found from Ticketmaster API');
      } else {
        print('📦 Cached ${events.length} real events for 24 hours');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Error fetching events: $e');
    }
  }

  /// Search events with keyword
  Future<void> searchEventsWithKeyword({
    required String keyword,
    double? latitude,
    double? longitude,
    String? location,
    int radius = 25,
    int limit = 50,
  }) async {
    print('🔍 Intelligent search for: \'$keyword\'');
    
    // Create cache key that includes the keyword
    final cacheKey = _createSearchCacheKey(keyword, latitude, longitude, location, radius);
    
    // Check cache first
    if (_isSearchCacheValid(cacheKey)) {
      _events = _cache[cacheKey]!;
      _isUsingCache = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      print('🎯 Search Cache Hit: Found ${_events.length} cached events for \'$keyword\'');
      return;
    }
    
    print('🔍 Search Cache Miss: Fetching fresh data from Ticketmaster API for \'$keyword\'');
    _isUsingCache = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final events = await _fetchTicketmasterEventsWithKeyword(
        keyword: keyword,
        latitude: latitude,
        longitude: longitude,
        location: location,
        radius: radius,
        size: limit,
      );
      
      // Cache the search results
      _cache[cacheKey] = events;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      _events = events;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      
      if (events.isEmpty) {
        print('⚠️ No events found for keyword: \'$keyword\'');
      } else {
        print('📦 Cached ${events.length} events for keyword \'$keyword\' for 1 hour');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Error fetching events with keyword: $e');
    }
  }

  /// Clear all cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('🗑️ Events cache cleared');
  }

  /// Fetch events from Ticketmaster API
  Future<List<Event>> _fetchTicketmasterEvents({
    double? latitude,
    double? longitude,
    String? location,
    int radius = 25,
    int size = 25,
  }) async {
    print('🔍 Fetching events from Ticketmaster API...');
    
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        if (latitude != null && longitude != null) ...{
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radius.toString(),
        } else if (location != null) ...{
          'city': location,
        },
        'size': size.toString(),
      },
    );
    
    print('📍 API URL: $uri');
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final events = _parseTicketmasterEvents(data);
      print('🔍 Ticketmaster API returned ${events.length} events');
      return events;
    } else {
      throw Exception('Failed to fetch events: ${response.statusCode}');
    }
  }

  /// Fetch events with keyword from Ticketmaster API
  Future<List<Event>> _fetchTicketmasterEventsWithKeyword({
    required String keyword,
    double? latitude,
    double? longitude,
    String? location,
    int radius = 25,
    int size = 50,
  }) async {
    print('🔍 Fetching events from Ticketmaster API with keyword: \'$keyword\'...');
    
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        if (latitude != null && longitude != null) ...{
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radius.toString(),
        } else if (location != null) ...{
          'city': location,
        },
        'size': size.toString(),
        'keyword': keyword,
      },
    );
    
    print('📍 API URL: $uri');
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final events = _parseTicketmasterEvents(data);
      print('🔍 Ticketmaster API returned ${events.length} events for keyword \'$keyword\'');
      return events;
    } else {
      throw Exception('Failed to fetch events: ${response.statusCode}');
    }
  }

  /// Parse Ticketmaster API response
  List<Event> _parseTicketmasterEvents(Map<String, dynamic> data) {
    final List<Event> events = [];
    
    if (data['events'] != null) {
      final List<dynamic> eventList = data['events'];
      
      for (final eventData in eventList) {
        try {
          final event = Event(
            id: eventData['id'] ?? '',
            title: eventData['title'] ?? 'Untitled Event',
            details: eventData['description'] ?? 'Ticketmaster Event',
            date: _parseEventDate(eventData['startsAt']),
            place: _parseEventLocation(eventData),
            url: eventData['url'],
            category: 'Entertainment',
            organizer: 'Ticketmaster',
            source: EventSource.ticketmaster,
            searchRelevanceScore: _calculateRelevanceScore(eventData),
          );
          
          events.add(event);
        } catch (e) {
          print('⚠️ Could not parse event: $e');
        }
      }
    }
    
    return events;
  }

  /// Parse event date from Ticketmaster response
  DateTime _parseEventDate(String? startsAt) {
    if (startsAt == null) return DateTime.now();
    
    try {
      // Try ISO 8601 parsing
      return DateTime.parse(startsAt);
    } catch (e) {
      print('⚠️ Could not parse date: $startsAt');
      return DateTime.now();
    }
  }

  /// Parse event location from Ticketmaster response
  String _parseEventLocation(Map<String, dynamic> eventData) {
    final venue = eventData['venue'];
    if (venue != null) {
      return venue.toString();
    }
    
    final address = eventData['address'];
    if (address != null) {
      return address.toString();
    }
    
    return 'Location TBA';
  }

  /// Calculate relevance score for search results
  double _calculateRelevanceScore(Map<String, dynamic> eventData) {
    // Simple relevance scoring based on title and description
    final title = (eventData['title'] ?? '').toString().toLowerCase();
    final description = (eventData['description'] ?? '').toString().toLowerCase();
    
    // Base score
    double score = 1.0;
    
    // Boost score for events happening soon
    final date = _parseEventDate(eventData['startsAt']);
    final now = DateTime.now();
    final daysUntilEvent = date.difference(now).inDays;
    
    if (daysUntilEvent <= 7) {
      score += 0.5;
    } else if (daysUntilEvent <= 30) {
      score += 0.3;
    }
    
    return score;
  }

  /// Create cache key for regular searches
  String _createCacheKey(double? latitude, double? longitude, String? location, int radius) {
    if (latitude != null && longitude != null) {
      return 'events_cache_lat_${latitude}_lng_${longitude}_r_$radius';
    } else {
      return 'events_cache_location_${location ?? 'default'}_r_$radius';
    }
  }

  /// Create cache key for search queries
  String _createSearchCacheKey(String keyword, double? latitude, double? longitude, String? location, int radius) {
    if (latitude != null && longitude != null) {
      return 'events_search_${keyword}_lat_${latitude}_lng_${longitude}_r_$radius';
    } else {
      return 'events_search_${keyword}_location_${location ?? 'default'}_r_$radius';
    }
  }

  /// Check if cache is valid for regular searches
  bool _isCacheValid(String cacheKey) {
    if (!_cache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Check if cache is valid for search queries
  bool _isSearchCacheValid(String cacheKey) {
    if (!_cache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _searchCacheExpiration;
  }
}