import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/universal_connection_service.dart';

/// UserProfileScreen - Shows user profile with connection options
class UserProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String connectionRequestId;

  const UserProfileScreen({
    super.key,
    required this.userProfile,
    required this.connectionRequestId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Photo
            CircleAvatar(
              radius: 80,
              backgroundColor: const Color(0xFFFF7E00).withOpacity(0.1),
              child: widget.userProfile.photoURL.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        widget.userProfile.photoURL,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialsAvatar();
                        },
                      ),
                    )
                  : _buildInitialsAvatar(),
            ),
            
            const SizedBox(height: 20),
            
            // Name and Age
            Text(
              widget.userProfile.fullname,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Age: ${widget.userProfile.age}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bio
            if (widget.userProfile.bio.isNotEmpty) ...[
              const Text(
                'Bio:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.userProfile.bio,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            
            // Job Title
            if (widget.userProfile.jobTitle.isNotEmpty) ...[
              Text(
                'Job Title: ${widget.userProfile.jobTitle}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Major
            if (widget.userProfile.major.isNotEmpty) ...[
              Text(
                'Major: ${widget.userProfile.major}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Greek Organization
            if (widget.userProfile.greekOrganization.isNotEmpty) ...[
              Text(
                'Greek Organization: ${widget.userProfile.greekOrganization}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Skills
            if (widget.userProfile.skills.isNotEmpty) ...[
              const Text(
                'Skills:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.userProfile.skills,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            
            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnecting ? null : _handleConnect,
                icon: _isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.person_add, size: 18),
                label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Text(
      widget.userProfile.initials,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF7E00),
      ),
    );
  }

  Future<void> _handleConnect() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await UniversalConnectionService.sendConnectionRequest(
        toUserId: widget.userProfile.id,
        context: 'profile',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request sent!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }
}
