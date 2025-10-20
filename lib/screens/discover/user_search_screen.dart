import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:culture_connection/services/chat_service.dart';
import 'package:culture_connection/screens/chat/other_user_profile_view.dart';
import 'package:culture_connection/models/chat_room.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/Tamearaimage-3.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_left, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
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
                        width: 80,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      
                      const Spacer(),
                      
                      // Invisible spacer to balance layout
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                
                // Title
                Text(
                  "SEARCH USERS",
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 28,
                    color: const Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                    ),
                    child: TextField(
                      onChanged: _performSearch,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search users by name...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter-VariableFont_slnt,wght',
                        ),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search Results
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF7E00),
            ),
            SizedBox(height: 20),
            Text(
              "Searching...",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchText.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Search for Users",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter a name to find people to connect with",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_search,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "No users found",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try a different search term",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_searchResults[index]);
      },
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 30,
            backgroundImage: user.photoURL.isNotEmpty
                ? NetworkImage(user.photoURL)
                : null,
            child: user.photoURL.isEmpty
                ? const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 30,
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (user.jobTitle.isNotEmpty)
                  Text(
                    user.jobTitle,
                    style: TextStyle(
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                if (user.major.isNotEmpty)
                  Text(
                    user.major,
                    style: TextStyle(
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          
          // Connect Button
          ElevatedButton(
            onPressed: () => _connectWithUser(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7E00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Connect",
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String searchText) async {
    setState(() {
      _searchText = searchText;
      _isLoading = true;
    });

    if (searchText.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await _db
          .collection('Profiles')
          .where('Full Name', isGreaterThanOrEqualTo: searchText)
          .where('Full Name', isLessThanOrEqualTo: '$searchText\uf8ff')
          .limit(10)
          .get();

      setState(() {
        _searchResults = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return UserProfile.fromFirestore(doc);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _connectWithUser(UserProfile user) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Create a connection request
      await _db.collection('Connects').add({
        'fromUserId': currentUserId,
        'toUserId': user.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create a chat room
      await _chatService.createChatRoom(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection request sent to ${user.fullName}"),
            backgroundColor: const Color(0xFFFF7E00),
          ),
        );
      }
    } catch (e) {
      print('Error connecting with user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error connecting with user: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String photoURL;
  final String jobTitle;
  final String major;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.photoURL,
    required this.jobTitle,
    required this.major,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      fullName: data['Full Name'] ?? '',
      photoURL: data['photoURL'] ?? '',
      jobTitle: data['Job Title'] ?? '',
      major: data['Major'] ?? '',
    );
  }
}
