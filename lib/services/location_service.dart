import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      if (_currentPosition != null) {
        _currentAddress = await _getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      return _currentPosition;
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  // Get address from coordinates
  Future<String?> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Get distance in miles
  double getDistanceInMiles(double lat1, double lon1, double lat2, double lon2) {
    final distanceInMeters = calculateDistance(lat1, lon1, lat2, lon2);
    return distanceInMeters * 0.000621371; // Convert meters to miles
  }

  // Check if location is within radius
  bool isWithinRadius(
    double userLat,
    double userLon,
    double targetLat,
    double targetLon,
    double radiusInMiles,
  ) {
    final distance = getDistanceInMiles(userLat, userLon, targetLat, targetLon);
    return distance <= radiusInMiles;
  }

  // Get formatted distance string
  String getFormattedDistance(double lat1, double lon1, double lat2, double lon2) {
    final distance = getDistanceInMiles(lat1, lon1, lat2, lon2);
    if (distance < 1) {
      return '${(distance * 5280).toStringAsFixed(0)} ft'; // Convert to feet
    } else {
      return '${distance.toStringAsFixed(1)} mi';
    }
  }

  // Listen to location changes
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Stop location updates
  void stopLocationUpdates() {
    // Geolocator doesn't have a direct stop method, but the stream will stop when disposed
  }
}