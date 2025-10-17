import 'package:flutter/material.dart';
import '../services/notification_permission_handler.dart';
import '../services/notification_service.dart';

/// NotificationSettingsScreen - Allows users to manage notification settings
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationPermissionHandler _permissionHandler = NotificationPermissionHandler();
  
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    try {
      final enabled = await _permissionHandler.areNotificationsEnabled();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error checking notification status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleNotifications() async {
    if (_notificationsEnabled) {
      // Open app settings to disable notifications
      await _permissionHandler.openNotificationSettings();
    } else {
      // Request permission
      setState(() {
        _isLoading = true;
      });

      final granted = await _permissionHandler.requestPermissionWithDialog(context);
      
      if (mounted) {
        setState(() {
          _notificationsEnabled = granted;
          _isLoading = false;
        });

        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Notifications enabled!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Notifications disabled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7E00),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Status Card
                  _buildStatusCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Types
                  _buildNotificationTypes(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _notificationsEnabled ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _notificationsEnabled ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: _notificationsEnabled ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _notificationsEnabled ? 'Notifications Enabled' : 'Notifications Disabled',
                  style: TextStyle(
                    color: _notificationsEnabled ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'You\'ll receive notifications about connections, messages, and matches.'
                      : 'You won\'t receive any notifications. Enable them to stay connected!',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOTIFICATION TYPES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        _buildNotificationType(
          icon: Icons.people,
          title: 'Connection Requests',
          description: 'When someone wants to connect with you',
        ),
        _buildNotificationType(
          icon: Icons.message,
          title: 'Messages',
          description: 'New messages from your matches',
        ),
        _buildNotificationType(
          icon: Icons.event,
          title: 'Meeting Proposals',
          description: 'When someone proposes a meeting',
        ),
        _buildNotificationType(
          icon: Icons.favorite,
          title: 'New Matches',
          description: 'When you get matched with someone',
        ),
        _buildNotificationType(
          icon: Icons.article,
          title: 'Community Posts',
          description: 'New posts from the community',
        ),
      ],
    );
  }

  Widget _buildNotificationType({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF7E00),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _toggleNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: _notificationsEnabled ? Colors.red : const Color(0xFFFF7E00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _permissionHandler.openNotificationSettings(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF7E00),
                side: const BorderSide(color: Color(0xFFFF7E00)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Open System Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}


