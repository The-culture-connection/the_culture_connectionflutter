import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Notification service for handling push notifications
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize notification service
  static Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // If permission granted, subscribe to general topic and get token
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✅ Notification permission granted');
        }

        // Subscribe to general topic for all users
        await subscribeToTopic('general');
        if (kDebugMode) {
          print('✅ Subscribed to general topic');
        }

        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToDatabase(token);
          if (kDebugMode) {
            print('✅ FCM token saved: ${token.substring(0, 20)}...');
          }
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          await _saveTokenToDatabase(newToken);
          // Re-subscribe to general topic on token refresh
          await subscribeToTopic('general');
        });
      } else {
        if (kDebugMode) {
          print('❌ Notification permission denied or not determined');
        }
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle initial message (app opened from notification)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  /// Save FCM token to database
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Save to both 'users' and 'Profiles' collections for compatibility
        await Future.wait([
          _db.collection('users').doc(user.uid).set({
            'fcmToken': token,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)),
          _db.collection('Profiles').doc(user.uid).set({
            'fcmToken': token,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)),
        ]);
        if (kDebugMode) {
          print('✅ Token saved to Firestore');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
    }
    
    // You can show a local notification or update UI here
    // For now, we'll just log it
  }

  /// Handle notification taps
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
    }
    
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      final type = data['type'];
      switch (type) {
        case 'connection_request':
          // Navigate to connection requests
          break;
        case 'new_message':
          // Navigate to chat
          break;
        case 'new_match':
          // Navigate to today's matches
          break;
        default:
          // Navigate to main screen
          break;
      }
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }

  /// Get current token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking notification settings: $e');
      }
      return false;
    }
  }

  /// Update notification settings
  static Future<void> updateNotificationSettings({
    bool? connectionRequests,
    bool? newMessages,
    bool? newMatches,
    bool? general,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final settings = <String, dynamic>{};
        
        if (connectionRequests != null) {
          settings['connectionRequests'] = connectionRequests;
        }
        if (newMessages != null) {
          settings['newMessages'] = newMessages;
        }
        if (newMatches != null) {
          settings['newMatches'] = newMatches;
        }
        if (general != null) {
          settings['general'] = general;
        }
        
        settings['lastUpdated'] = FieldValue.serverTimestamp();
        
        await _db.collection('users').doc(user.uid).set({
          'notificationSettings': settings,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification settings: $e');
      }
    }
  }

  /// Get notification settings
  static Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data()?['notificationSettings'] as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notification settings: $e');
      }
      return null;
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

