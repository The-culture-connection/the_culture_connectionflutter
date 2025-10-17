import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// PostSwipeView - Equivalent to iOS PostSwipeView.swift
class PostSwipeView extends StatefulWidget {
  final String userId;
  final String connectionRequestId;

  const PostSwipeView({
    super.key,
    required this.userId,
    required this.connectionRequestId,
  });

  @override
  State<PostSwipeView> createState() => _PostSwipeViewState();
}

class _PostSwipeViewState extends State<PostSwipeView> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isConnecting = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

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
                image: AssetImage('assets/EventImage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay for better text readability
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFFF7E00),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Profile...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _userProfile != null
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            // Logo and Title Section
                            Container(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  // Logo
                                  Image.asset(
                                    'assets/CC_PrimaryLogo_SilverPurple.png',
                                    height: 60,
                                    width: 120,
                                  ),
                                  
                                  const SizedBox(height: 15),
                                  
                                  // Title
                                  const Text(
                                    'PROFILE',
                                    style: TextStyle(
                                      fontFamily: 'Matches-StrikeRough',
                                      fontSize: 28,
                                      color: Color(0xFFFF7E00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Profile Content Card
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Photo
                                  Center(
                                    child: CircleAvatar(
                                      radius: 75,
                                      backgroundColor: Colors.grey.withOpacity(0.3),
                                      backgroundImage: _userProfile!['photoURL'] != null
                                          ? NetworkImage(_userProfile!['photoURL'])
                                          : null,
                                      child: _userProfile!['photoURL'] == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 75,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Name
                                  Text(
                                    _userProfile!['Full Name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Age
                                  Text(
                                    'Age: ${_userProfile!['Age'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // College
                                  if (_userProfile!['University'] != null) ...[
                                    Text(
                                      'College: ${_userProfile!['University']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  
                                  // Major
                                  if (_userProfile!['Major'] != null) ...[
                                    Text(
                                      'Major: ${_userProfile!['Major']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  
                                  // Job Title
                                  if (_userProfile!['Job Title'] != null) ...[
                                    Text(
                                      'Job Title: ${_userProfile!['Job Title']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  
                                  // Bio
                                  if (_userProfile!['Bio'] != null && 
                                      _userProfile!['Bio'].toString().isNotEmpty) ...[
                                    const Text(
                                      'Bio:',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userProfile!['Bio'],
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // More Options Button
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Implement more options (block/report)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('More options coming soon'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFF7E00),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Text(
                                        'MORE OPTIONS',
                                        style: TextStyle(
                                          fontFamily: 'Matches-StrikeRough',
                                          fontSize: 16,
                                          letterSpacing: 1.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Connect and Pass buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isConnecting ? null : _handleConnect,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: _isConnecting 
                                                  ? Colors.grey.withOpacity(0.8)
                                                  : Colors.black.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFFF7E00),
                                                width: 2,
                                              ),
                                            ),
                                            child: _isConnecting
                                                ? const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        color: Color(0xFFFF7E00),
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'CONNECT',
                                                    style: TextStyle(
                                                      fontFamily: 'Matches-StrikeRough',
                                                      fontSize: 16,
                                                      letterSpacing: 1.0,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFFF7E00),
                                                width: 2,
                                              ),
                                            ),
                                            child: const Text(
                                              'PASS',
                                              style: TextStyle(
                                                fontFamily: 'Matches-StrikeRough',
                                                fontSize: 16,
                                                letterSpacing: 1.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 100), // Space for navigation
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Profile not found!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserProfile() async {
    try {
      final doc = await _db.collection('Profiles').doc(widget.userId).get();
      
      if (doc.exists) {
        setState(() {
          _userProfile = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConnect() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Call Firebase function
      final callable = _functions.httpsCallable('handleUserConnection');
      final result = await callable.call({
        'fromUserId': currentUserId,
        'toUserId': widget.userId,
        'connectionRequestId': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        if (data['isMatch'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Match! You are now connected!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Connection request sent!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        // Navigate back
        Navigator.of(context).pop();
      } else {
        throw Exception(data['message'] ?? 'Connection failed');
      }

    } catch (e) {
      print('Error in connection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
}
