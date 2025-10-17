import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../services/events_service.dart';
import '../widgets/event_card.dart';

/// EventsScreen - Equivalent to iOS LocalEventsView.swift
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsService _eventsService = EventsService();
  final TextEditingController _searchController = TextEditingController();
  
  // Location state
  bool _useCurrentLocation = true;
  String _customCity = '';
  Position? _currentPosition;
  
  // Search and filter state
  String _searchText = '';
  EventSource? _selectedSource;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupEventListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setupEventListeners() {
    // Listen to events service changes
    _eventsService.addListener(() {
      if (mounted) {
        setState(() {
          _isLoading = _eventsService.isLoading;
          _errorMessage = _eventsService.errorMessage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Tamearaimage-2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                _buildHeader(),
                
                // Location and refresh controls
                _buildLocationControls(),
                
                // Search and filters (only show if events exist)
                if (_eventsService.events.isNotEmpty) _buildSearchAndFilters(),
                
                // Events List
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Back button and title row
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF7E00),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        color: Color(0xFFFF7E00),
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFFFF7E00),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Title
              const Text(
                'Local Events',
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 32,
                  color: Color(0xFFFF7E00),
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Events indicator with cache status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF7E00),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _eventsService.isUsingCache ? Icons.archive : Icons.calendar_today,
                  color: const Color(0xFFFF7E00),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  _eventsService.isUsingCache ? 'Real Events (Cached)' : 'Real Local Events',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Location info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Events Near You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (_useCurrentLocation) ...[
                  if (_currentPosition != null)
                    const Text(
                      'Using your location',
                      style: TextStyle(
                        color: Color(0xFFFF7E00),
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      'Location not available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ] else ...[
                  if (_customCity.isNotEmpty)
                    Text(
                      'Searching near: $_customCity',
                      style: const TextStyle(
                        color: Color(0xFFFF7E00),
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      'Custom location selected',
                      style: TextStyle(
                        color: Color(0xFFFF7E00),
                        fontSize: 12,
                      ),
                    ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Location Change Button
          GestureDetector(
            onTap: _showLocationPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7E00).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFFFF7E00),
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'CHANGE',
                    style: TextStyle(
                      color: Color(0xFFFF7E00),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Use Current Location Button (when custom city is selected)
          if (!_useCurrentLocation) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _useCurrentLocation = true;
                  _customCity = '';
                });
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7E00),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'CURRENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Refresh button
          if (_eventsService.isUsingCache) ...[
            GestureDetector(
              onTap: _clearCacheAndRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7E00),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'REFRESH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1d1d1e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7E00),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search events, organizers...',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                      _performIntelligentSearch(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Source filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EventSource.values.map((source) {
                final isSelected = _selectedSource == source;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSource = isSelected ? null : source;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF7E00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF7E00),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSourceIcon(source),
                            color: isSelected ? Colors.white : const Color(0xFFFF7E00),
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            source.displayName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFFF7E00),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Results count
          if (_searchText.isNotEmpty || _selectedSource != null) ...[
            const SizedBox(height: 8),
            Text(
              'Showing ${_getFilteredEvents().length} of ${_eventsService.events.length} events',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_isLoading) {
      return _buildLoadingState();
    } else if (_eventsService.events.isEmpty) {
      return _buildEmptyState();
    } else if (_getFilteredEvents().isEmpty) {
      return _buildNoResultsState();
    } else {
      return _buildEventsListContent();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 50,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7E00),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'TRY AGAIN',
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFFF7E00),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Searching for events...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.grey,
            size: 50,
          ),
          const SizedBox(height: 16),
          const Text(
            'No real events found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No Black-owned business events found in your area. Try adjusting your location or search criteria.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7E00),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'SEARCH AGAIN',
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.search_off,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 24),
          const Text(
            'No matching events',
            style: TextStyle(
              fontFamily: 'Matches-StrikeRough',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_searchText.isNotEmpty) ...[
            Text(
              "No events found for '$_searchText' in your area. Try different keywords or browse popular categories below.",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Text(
              'Try different search terms or filters',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 40),
          
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchText = '';
                      _selectedSource = null;
                      _searchController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'CLEAR FILTERS',
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _performSearch,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7E00),
                    side: const BorderSide(
                      color: Color(0xFFFF7E00),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'REFRESH EVENTS',
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListContent() {
    final filteredEvents = _getFilteredEvents();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return EventCard(
          event: event,
          onTap: () => _openEventUrl(event),
        );
      },
    );
  }

  List<Event> _getFilteredEvents() {
    var filtered = _eventsService.events;
    
    // Filter by source
    if (_selectedSource != null) {
      filtered = filtered.where((event) => event.source == _selectedSource).toList();
    }
    
    // Sort by relevance score (if available) or by date
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  IconData _getSourceIcon(EventSource source) {
    switch (source) {
      case EventSource.ticketmaster:
        return Icons.calendar_today;
    }
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _performSearch();
    } catch (e) {
      print('Error getting location: $e');
      // Still perform search without location
      _performSearch();
    }
  }

  void _performSearch() {
    if (_useCurrentLocation && _currentPosition != null) {
      _eventsService.searchEvents(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: 25,
        limit: 25,
      );
    } else if (!_useCurrentLocation && _customCity.isNotEmpty) {
      _eventsService.searchEvents(
        location: _customCity,
        radius: 25,
        limit: 25,
      );
    }
  }

  void _performIntelligentSearch(String query) {
    if (query.isEmpty) {
      _performSearch();
      return;
    }
    
    // Debounce search by 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchText == query) {
        if (_useCurrentLocation && _currentPosition != null) {
          _eventsService.searchEventsWithKeyword(
            keyword: query,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            radius: 25,
            limit: 50,
          );
        } else if (!_useCurrentLocation && _customCity.isNotEmpty) {
          _eventsService.searchEventsWithKeyword(
            keyword: query,
            location: _customCity,
            radius: 25,
            limit: 50,
          );
        }
      }
    });
  }

  void _clearCacheAndRefresh() {
    _eventsService.clearCache();
    _performSearch();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerView(
        onCitySelected: (city) {
          setState(() {
            _customCity = city;
            _useCurrentLocation = false;
          });
          _performSearch();
        },
      ),
    );
  }

  void _openEventUrl(Event event) {
    if (event.url != null && event.url!.isNotEmpty) {
      launchUrl(Uri.parse(event.url!));
    }
  }
}

// Location Picker Modal
class _LocationPickerView extends StatefulWidget {
  final Function(String) onCitySelected;

  const _LocationPickerView({required this.onCitySelected});

  @override
  State<_LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<_LocationPickerView> {
  final TextEditingController _cityController = TextEditingController();
  
  final List<String> _popularCities = [
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Houston, TX',
    'Phoenix, AZ',
    'Philadelphia, PA',
    'San Antonio, TX',
    'San Diego, CA',
    'Dallas, TX',
    'San Jose, CA',
    'Austin, TX',
    'Jacksonville, FL',
    'Fort Worth, TX',
    'Columbus, OH',
    'Charlotte, NC',
    'San Francisco, CA',
    'Indianapolis, IN',
    'Seattle, WA',
    'Denver, CO',
    'Washington, DC',
    'Boston, MA',
    'Miami, FL',
    'Atlanta, GA',
    'Detroit, MI',
    'Nashville, TN',
    'Portland, OR',
    'Las Vegas, NV',
    'Memphis, TN',
    'Louisville, KY',
    'Baltimore, MD',
    'Milwaukee, WI',
    'Albuquerque, NM',
    'Tucson, AZ',
    'Fresno, CA',
    'Sacramento, CA',
    'Mesa, AZ',
    'Kansas City, MO',
    'Long Beach, CA',
    'Colorado Springs, CO',
    'Raleigh, NC',
    'Virginia Beach, VA',
    'Omaha, NE',
    'Oakland, CA',
    'Minneapolis, MN',
    'Tulsa, OK',
    'Tampa, FL',
    'Arlington, TX',
    'New Orleans, LA',
    'Wichita, KS',
    'Cleveland, OH',
    'Bakersfield, CA',
    'Aurora, CO',
    'Anaheim, CA',
    'Honolulu, HI',
    'Santa Ana, CA',
    'Corpus Christi, TX',
    'Riverside, CA',
    'Lexington, KY',
    'Stockton, CA',
    'Henderson, NV',
    'Saint Paul, MN',
    'St. Louis, MO',
    'Fort Wayne, IN',
    'Jersey City, NJ',
    'Chandler, AZ',
    'Madison, WI',
    'Lubbock, TX',
    'Scottsdale, AZ',
    'Reno, NV',
    'Buffalo, NY',
    'Gilbert, AZ',
    'Glendale, AZ',
    'North Las Vegas, NV',
    'Winston-Salem, NC',
    'Chesapeake, VA',
    'Norfolk, VA',
    'Fremont, CA',
    'Garland, TX',
    'Irving, TX',
    'Hialeah, FL',
    'Richmond, VA',
    'Boise, ID',
    'Spokane, WA',
    'Baton Rouge, LA',
    'Tacoma, WA',
    'San Bernardino, CA',
    'Grand Rapids, MI',
    'Huntsville, AL',
    'Salt Lake City, UT',
    'Fayetteville, NC',
    'Yonkers, NY',
    'Amarillo, TX',
    'Glendale, CA',
    'Montgomery, AL',
    'Aurora, IL',
    'Akron, OH',
    'Little Rock, AR',
    'Moreno Valley, CA',
    'Shreveport, LA',
    'Mobile, AL',
    'Columbus, GA',
    'Huntington Beach, CA',
    'Grand Prairie, TX',
    'Tallahassee, FL',
    'Overland Park, KS',
    'Garden Grove, CA',
    'Vancouver, WA',
    'Chattanooga, TN',
    'Oceanside, CA',
    'Santa Rosa, CA',
    'Fort Lauderdale, FL',
    'Rancho Cucamonga, CA',
    'Port St. Lucie, FL',
    'Ontario, CA',
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  '📍 Select Location',
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 28,
                    color: Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a city to find events near you',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Custom City Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter City Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Cincinnati, OH',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF7E00),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF7E00),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF7E00),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _cityController.text.isNotEmpty
                          ? () {
                              widget.onCitySelected(_cityController.text);
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7E00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Popular Cities
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Popular Cities',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _popularCities.length,
                    itemBuilder: (context, index) {
                      final city = _popularCities[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onCitySelected(city);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFF7E00).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Cancel button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7E00),
                  side: const BorderSide(
                    color: Color(0xFFFF7E00),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}