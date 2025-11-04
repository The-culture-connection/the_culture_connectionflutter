import 'dart:io';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firestore_service.dart';

/// Firebase Messaging Service for push notifications
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();
  static bool _isInitialized = false;
  static StreamSubscription<String>? _tokenRefreshSubscription;

  /// Initialize messaging
  Future<void> initialize() async {
    // Prevent multiple full initializations, but allow token retrieval attempts
    final isFirstInit = !_isInitialized;
    
    if (isFirstInit) {
      // Optional but helpful
      await _messaging.setAutoInitEnabled(true);
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Set up token refresh listener FIRST (so it catches tokens when they become available)
      // Only set up once to avoid duplicate listeners
      if (_tokenRefreshSubscription == null) {
        _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) async {
          print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
          print('🔄 Full token length: ${newToken.length}');
          // Update token in Firestore and subscribe to general topic
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            print('🔄 Saving token to Firestore for user: $currentUser.uid');
            await _saveTokenToFirestore(currentUser.uid, newToken);
          } else {
            print('⚠️ No current user when token refreshed, will save on next login');
          }
        }, onError: (error) {
          print('❌ Error in token refresh listener: $error');
        }, onDone: () {
          print('⚠️ Token refresh listener completed (unexpected)');
        });
        print('✅ Token refresh listener set up and active');
      } else {
        print('✅ Token refresh listener already active');
      }
      
      // Request permission (this will also trigger APNS registration on iOS)
      final settings = await requestPermission();
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Mark as initialized
      _isInitialized = true;
    } else {
      print('⚠️ MessagingService already initialized, attempting to get token if available...');
    }
    
    // Always try to get token (even if already initialized) - it might be available now
    // On iOS, check APNS token first
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        print('⚠️ APNS token not available yet');
        if (isFirstInit) {
          // Only wait on first init
          await _waitForAPNSToken();
        }
      } else {
        print('✅ APNS token available');
      }
    }
    
    // Get FCM token (this requires APNS token to be set first on iOS)
    final token = await _getTokenWithRetry(maxRetries: 2);
    if (token != null) {
      print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
      // Save token if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _saveTokenToFirestore(currentUser.uid, token);
      }
      // Subscribe to general topic when permission is granted and token exists
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        try {
          await subscribeToTopic('general');
          print('✅ Subscribed to general topic');
        } catch (e) {
          print('⚠️ Error subscribing to general topic: $e');
          // Retry subscription once after a short delay
          Future.delayed(const Duration(seconds: 2), () async {
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
      print('⚠️ FCM token not available yet - will be saved automatically when available');
      if (Platform.isIOS) {
        print('⚠️ Note: On iOS, APNS token must be set first. Testing on simulator will fail.');
        print('⚠️ The token refresh listener will save it when APNS becomes available.');
        
        // Schedule a retry after 5 seconds if token still isn't available
        // This helps catch cases where APNS becomes available after initialization
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          Future.delayed(const Duration(seconds: 5), () async {
            print('🔄 Retrying FCM token retrieval after delay...');
            final retryToken = await _getTokenWithRetry(maxRetries: 1);
            if (retryToken != null) {
              print('✅ FCM Token obtained on retry: ${retryToken.substring(0, 20)}...');
              await _saveTokenToFirestore(currentUser.uid, retryToken);
            } else {
              print('⚠️ FCM token still not available - will be saved via token refresh listener');
            }
          });
        }
      }
      // Token refresh listener will handle saving when token becomes available
    }
  }
  
  /// Save token to Firestore and subscribe to general topic
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestoreService.updateUserProfile(userId, {'fcmToken': token});
      print('✅ FCM token saved to Firestore for user: $userId');
      
      // Subscribe to general topic
      try {
        await subscribeToTopic('general');
        print('✅ Subscribed to general topic');
      } catch (e) {
        print('⚠️ Error subscribing to general topic: $e');
        // Retry subscription
        Future.delayed(const Duration(seconds: 3), () async {
          try {
            await subscribeToTopic('general');
            print('✅ Successfully subscribed to general topic on retry');
          } catch (retryError) {
            print('❌ Failed to subscribe to general topic: $retryError');
          }
        });
      }
    } catch (e) {
      print('❌ Error saving FCM token to Firestore: $e');
    }
  }
  
  /// Wait for APNS token with shorter timeout (max 10 seconds)
  Future<void> _waitForAPNSToken() async {
    String? apns;
    int tries = 0;
    const delayMs = 500;
    const maxTries = 20; // 20 * 500ms = 10 seconds max
    
    print('⏳ Waiting for APNS token...');
    
    while (apns == null && tries < maxTries) {
      apns = await _messaging.getAPNSToken();
      if (apns == null) {
        await Future.delayed(const Duration(milliseconds: delayMs));
      }
      tries++;
    }
    
    if (apns != null) {
      print('✅ APNS Token obtained');
    } else {
      print('⚠️ APNS token not available after 10s (might be simulator or still initializing)');
      print('⚠️ FCM token will be saved automatically when APNS becomes available');
      print('⚠️ Note: On physical device, APNS should be available within a few seconds');
    }
  }
  
  /// Get token with minimal retry logic (only 1 retry to avoid long waits)
  Future<String?> _getTokenWithRetry({int maxRetries = 2}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final token = await getToken();
        if (token != null) {
          return token;
        }
        // Only retry once with a short delay
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        // Only log error on first attempt, don't spam
        if (i == 0) {
          print('⚠️ Error getting FCM token: $e');
        }
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
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
      // On iOS, check for APNS token (but don't spam logs)
      if (Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          // Only log once per attempt to avoid spam
          // Don't print here - let the caller handle logging
        }
      }
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      // Only log the error message, not the full stack trace
      final errorMessage = e.toString();
      if (errorMessage.contains('apns-token-not-set')) {
        // Don't spam - this is expected on simulator or when APNS isn't ready
        return null;
      }
      print('Error getting FCM token: $errorMessage');
      return null;
    }
  }

  /// Update FCM token in Firestore (only if not already saved during initialization)
  Future<void> updateUserToken(String userId) async {
    // Try to get token with minimal retry (only if initialize() didn't already get it)
    final token = await _getTokenWithRetry(maxRetries: 1);
    if (token != null) {
      try {
        await _firestoreService.updateUserProfile(userId, {'fcmToken': token});
        print('✅ FCM token saved to Firestore for user: $userId');
        
        // Subscribe to general topic when token is updated
        try {
          await subscribeToTopic('general');
          print('✅ Subscribed to general topic');
        } catch (e) {
          print('⚠️ Error subscribing to general topic: $e');
          // Retry subscription once after a short delay
          Future.delayed(const Duration(seconds: 2), () async {
            try {
              await subscribeToTopic('general');
              print('✅ Successfully subscribed to general topic on retry');
            } catch (retryError) {
              print('❌ Still failed to subscribe to general topic: $retryError');
            }
          });
        }
      } catch (e) {
        print('❌ Error updating user token in Firestore: $e');
      }
    } else {
      print('⚠️ FCM token not available yet for user $userId');
      print('⚠️ Token will be saved automatically when it becomes available (via onTokenRefresh)');
      // The onTokenRefresh listener will handle saving the token when it becomes available
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
