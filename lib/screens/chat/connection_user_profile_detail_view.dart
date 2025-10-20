import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/connection_request.dart';
import '../../services/chat_service.dart';

class ConnectionUserProfileDetailView extends StatefulWidget {
  final ConnectionUserProfile profile;
  final String connectionRequestId;

  const ConnectionUserProfileDetailView({
    super.key,
    required this.profile,
    required this.connectionRequestId,
  });

  @override
  State<ConnectionUserProfileDetailView> createState() => _ConnectionUserProfileDetailViewState();
}

class _ConnectionUserProfileDetailViewState extends State<ConnectionUserProfileDetailView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/EventImage.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button and Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "BACK",
                                style: TextStyle(
                                  fontFamily: 'Matches-StrikeRough',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Logo
                      Image.asset(
                        'assets/CC_PrimaryLogo_SilverPurple.png',
                        height: 60,
                        width: 120,
                      ),
                      
                      const Spacer(),
                      
                      // Invisible spacer to balance the layout
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                
                // Title
                Text(
                  "PROFILE",
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 28,
                    color: const Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Image
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.profile.photoURL != null
                              ? NetworkImage(widget.profile.photoURL!)
                              : null,
                          child: widget.profile.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 60,
                                )
                              : null,
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
                              Text(
                                widget.profile.fullName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        "Age",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${widget.profile.age}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  Column(
                                    children: [
                                      const Text(
                                        "Job Title",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.profile.jobTitle,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
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
                                onPressed: _handleConnect,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFFF7E00),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "CONNECT",
                                  style: TextStyle(
                                    fontFamily: 'Matches-StrikeRough',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Dismiss Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleDismiss,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "DISMISS",
                                  style: TextStyle(
                                    fontFamily: 'Matches-StrikeRough',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
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

  Future<void> _handleConnect() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        _showErrorSnackBar("User not logged in");
        return;
      }

      // Create a chat room
      final chatRoomId = await _chatService.createChatRoom(widget.profile.id);
      
      // Delete the connection request
      await _db.collection("Connects").doc(widget.connectionRequestId).delete();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection accepted! Chat room created."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Error creating connection: $e");
    }
  }

  Future<void> _handleDismiss() async {
    try {
      // Delete the connection request without creating a chat room
      await _db.collection("Connects").doc(widget.connectionRequestId).delete();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection request dismissed"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Error dismissing request: $e");
    }
  }

  void _showErrorSnackBar(String message) {
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
