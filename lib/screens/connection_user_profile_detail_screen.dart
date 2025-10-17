import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'connection_requests_screen.dart';

class ConnectionUserProfileDetailScreen extends StatefulWidget {
  final ConnectionUserProfile profile;
  final String connectionRequestId;

  const ConnectionUserProfileDetailScreen({
    super.key,
    required this.profile,
    required this.connectionRequestId,
  });

  @override
  State<ConnectionUserProfileDetailScreen> createState() => _ConnectionUserProfileDetailScreenState();
}

class _ConnectionUserProfileDetailScreenState extends State<ConnectionUserProfileDetailScreen> {
  bool _isLoading = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/EventImage.png'),
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
                // Header
                _buildHeader(),
                
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7E00),
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ),
                
                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF7E00),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: widget.profile.photoURL != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.profile.photoURL!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Profile Details Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Name
                              Text(
                                widget.profile.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Basic Info
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoColumn('Age', '${widget.profile.age}'),
                                  _buildInfoColumn('Job Title', widget.profile.jobTitle),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Action Buttons
                        Column(
                          children: [
                            // Connect Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleConnect,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFFF7E00),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFFF7E00),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'CONNECT',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Matches-StrikeRough',
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Dismiss Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleDismiss,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'DISMISS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Matches-StrikeRough',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Logo
          Image.asset(
            'assets/images/CC_PrimaryLogo_SilverPurple.png',
            width: 120,
            height: 60,
          ),
          
          const Spacer(),
          
          // Invisible spacer to balance the layout
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleConnect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        _showError('User not logged in');
        return;
      }

      // Create participants list (sorted for consistency)
      final participants = [currentUserId, widget.profile.id]..sort();

      // Create a chat room
      final chatRoomData = {
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
      };

      await _db.collection('ChatRooms').add(chatRoomData);
      print('Chat room created successfully between ${participants[0]} and ${participants[1]}');

      // Delete the connection request
      await _deleteConnectionRequest();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection accepted! Chat room created.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error creating chat room: $e');
      _showError('Failed to create chat room: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDismiss() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _deleteConnectionRequest();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request dismissed'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error dismissing connection request: $e');
      _showError('Failed to dismiss connection request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteConnectionRequest() async {
    await _db.collection('Connects').doc(widget.connectionRequestId).delete();
    print('Connection request deleted successfully');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


