import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// NotificationPermissionHandler - Handles notification permissions without blocking UI
class NotificationPermissionHandler {
  static final NotificationPermissionHandler _instance = NotificationPermissionHandler._internal();
  factory NotificationPermissionHandler() => _instance;
  NotificationPermissionHandler._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request notification permission with user-friendly dialog
  Future<bool> requestPermissionWithDialog(BuildContext context) async {
    try {
      // Check if permission is already granted
      final currentStatus = await _messaging.getNotificationSettings();
      if (currentStatus.authorizationStatus == AuthorizationStatus.authorized) {
        return true;
      }

      // Show custom permission dialog
      final shouldRequest = await _showPermissionDialog(context);
      if (!shouldRequest) {
        return false;
      }

      // Request permission with timeout
      NotificationSettings settings;
      try {
        settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        ).timeout(const Duration(seconds: 15));
      } on TimeoutException {
        print('⚠️ Notification permission request timed out');
        return false;
      }

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Show custom permission dialog
  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.notifications,
                color: Color(0xFFFF7E00),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Enable Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          content: const Text(
            'Stay connected with your community! Get notified about:\n\n'
            '• New connection requests\n'
            '• Messages from your matches\n'
            '• Meeting proposals\n'
            '• Weekly matches\n'
            '• Community posts',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Not Now',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7E00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error checking notification status: $e');
      return false;
    }
  }

  /// Open app settings for notification permissions
  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('❌ Error opening app settings: $e');
    }
  }

  /// Request permission silently (without dialog)
  Future<bool> requestPermissionSilently() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error requesting permission silently: $e');
      return false;
    }
  }

  /// Simple push permission request method to avoid version clashes
  Future<bool> requestPushPermission(FirebaseMessaging messaging) async {
    try {
      NotificationSettings settings;
      try {
        settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        ).timeout(const Duration(seconds: 15));
      } on TimeoutException {
        print('⚠️ Notification permission request timed out');
        return false;
      }

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }
}
