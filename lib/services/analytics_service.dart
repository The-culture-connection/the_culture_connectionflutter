import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> trackAppLaunch() async {
    await _analytics.logEvent(
      name: 'app_launch',
      parameters: <String, Object>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> trackUserSession() async {
    await _analytics.logEvent(
      name: 'user_session_start',
      parameters: <String, Object>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> trackUserSessionEnd() async {
    await _analytics.logEvent(
      name: 'user_session_end',
      parameters: <String, Object>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> trackProfileCreation({
    required String completionStep,
    required bool hasPhoto,
  }) async {
    await _analytics.logEvent(
      name: 'profile_creation',
      parameters: <String, Object>{
        'completion_step': completionStep,
        'has_photo': hasPhoto ? 'true' : 'false', // Convert boolean to string
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Note: parameters are non-nullable here to match your plugin version.
  Future<void> trackEvent(String eventName, Map<String, Object> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
