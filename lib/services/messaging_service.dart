import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firestore_service.dart';

/// Firebase Messaging Service for push notifications
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  /// Initialize messaging
  Future<void> initialize() async {
    // Optional but helpful
    await _messaging.setAutoInitEnabled(true);
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Request permission (this will also trigger APNS registration on iOS)
    final settings = await requestPermission();
    
    // On iOS, wait for APNS token with longer timeout and better handling
    if (Platform.isIOS) {
      await _waitForAPNSToken();
    }
    
    // Get FCM token (this requires APNS token to be set first on iOS)
    final token = await _getTokenWithRetry();
    if (token != null) {
      print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
      // Subscribe to general topic when permission is granted and token exists
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        try {
          await subscribeToTopic('general');
          print('✅ Subscribed to general topic');
        } catch (e) {
          print('❌ Error subscribing to general topic: $e');
          // Retry subscription after a delay
          Future.delayed(const Duration(seconds: 5), () async {
            try {
              await subscribeToTopic('general');
              print('✅ Successfully subscribed to general topic on retry');
            } catch (retryError) {
              print('❌ Still failed to subscribe to general topic: $retryError');
            }
          });
        }
      } else {
        print('⚠️ Notification permission not granted - cannot subscribe to topic');
      }
    } else {
      print('⚠️ FCM token not available yet - will retry when token is available');
      print('⚠️ Note: On iOS, APNS token must be set first. Testing on simulator will fail.');
      // Set up a delayed retry for token retrieval
      _retryTokenRetrieval();
    }
    
    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      // Update token in Firestore and subscribe to general topic
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await updateUserToken(currentUser.uid);
      }
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  /// Wait for APNS token with exponential backoff
  Future<void> _waitForAPNSToken() async {
    String? apns;
    int tries = 0;
    int delayMs = 500;
    const maxTries = 100; // 30+ seconds total
    
    print('Waiting for APNS token...');
    
    while (apns == null && tries < maxTries) {
      apns = await _messaging.getAPNSToken();
      if (apns == null) {
        await Future.delayed(Duration(milliseconds: delayMs));
        // Exponential backoff: 500ms, 500ms, 1000ms, 1000ms, 1500ms, etc.
        if (tries > 0 && tries % 2 == 0) {
          delayMs = (delayMs * 1.5).round().clamp(500, 2000);
        }
      }
      tries++;
    }
    
    if (apns != null) {
      print('✅ APNS Token obtained: $apns');
    } else {
      print('⚠️ Warning: APNS token not available after waiting (might be simulator or APNS not configured)');
      print('⚠️ Note: FCM tokens require APNS on iOS. Testing on simulator will fail.');
      print('⚠️ For testing on physical device, ensure:');
      print('   1. App is running on a physical iOS device (not simulator)');
      print('   2. Push notifications capability is enabled in Xcode');
      print('   3. APNS certificates are configured in Firebase Console');
    }
  }
  
  /// Get token with retry logic
  Future<String?> _getTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final token = await getToken();
        if (token != null) {
          return token;
        }
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: 1 * (i + 1))); // 1s, 2s, 3s
        }
      } catch (e) {
        print('Error getting token (attempt ${i + 1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: 1 * (i + 1)));
        }
      }
    }
    return null;
  }
  
  /// Retry token retrieval after a delay
  void _retryTokenRetrieval() {
    Future.delayed(const Duration(seconds: 5), () async {
      print('🔄 Retrying FCM token retrieval...');
      final token = await _getTokenWithRetry();
      if (token != null) {
        print('✅ FCM Token obtained on retry: ${token.substring(0, 20)}...');
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await updateUserToken(currentUser.uid);
        }
        // Subscribe to general topic
        try {
          await subscribeToTopic('general');
          print('✅ Subscribed to general topic on retry');
        } catch (e) {
          print('❌ Error subscribing to general topic on retry: $e');
          // Try one more time after another delay
          Future.delayed(const Duration(seconds: 10), () async {
            try {
              await subscribeToTopic('general');
              print('✅ Successfully subscribed to general topic on second retry');
            } catch (secondError) {
              print('❌ Final subscription attempt failed: $secondError');
            }
          });
        }
      } else {
        print('⚠️ FCM token still not available on retry');
      }
    });
  }
  
  /// Request notification permission and return the result
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
    
    return settings;
  }

  /// Get FCM token (simplified - APNS waiting is handled during initialization)
  Future<String?> getToken() async {
    try {
      // On iOS, check for APNS token
      if (Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          print('⚠️ Warning: APNS token not available when getting FCM token');
          print('⚠️ This will likely fail on iOS. Ensure you are testing on a physical device.');
          // Still try to get FCM token - it might work in some cases
        } else {
          print('✅ APNS token verified before FCM token request');
        }
      }
      final token = await _messaging.getToken();
      if (token != null) {
        print('✅ FCM Token successfully obtained: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Update FCM token in Firestore
  Future<void> updateUserToken(String userId) async {
    final token = await getToken();
    if (token != null) {
      await _firestoreService.updateUserProfile(userId, {'fcmToken': token});
      // Subscribe to general topic when token is updated
      await subscribeToTopic('general');
      print('User subscribed to general topic');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.messageId}');
    
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'culture_connection_channel',
      'Culture Connection',
      channelDescription: 'Culture Connection notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    // Navigate to appropriate screen based on message data
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate to appropriate screen based on payload
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}
