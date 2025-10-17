class ApiConfig {
  // API Keys - Replace with your actual API keys
  static const String ticketmasterApiKey = 'YOUR_TICKETMASTER_API_KEY_HERE';
  
  // API URLs
  static const String ticketmasterBaseUrl = 'https://app.ticketmaster.com/discovery/v2/events.json';
  
  // Cache durations
  static const Duration businessCacheExpiry = Duration(hours: 24);
  static const Duration eventsCacheExpiry = Duration(hours: 1);
  
  // Search parameters
  static const int defaultSearchRadius = 10000; // 10km in meters
  static const int defaultEventRadius = 25; // 25 miles
  static const int defaultResultLimit = 20;
}
