import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/connection_request.dart';
import '../../services/chat_service.dart';
import 'connection_user_profile_detail_view.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  
  List<ConnectionRequestWithProfile> _connectionRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConnectionRequests();
  }

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
                  "CONNECTION REQUESTS",
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 28,
                    color: const Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Main Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF7E00),
            ),
            SizedBox(height: 16),
            Text(
              "Loading connection requests...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Error: $_errorMessage",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchConnectionRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7E00),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    
    if (_connectionRequests.isEmpty) {
      return const Center(
        child: Text(
          "No connection requests available.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _connectionRequests.length,
      itemBuilder: (context, index) {
        final connection = _connectionRequests[index];
        return _buildConnectionRequestItem(connection);
      },
    );
  }

  Widget _buildConnectionRequestItem(ConnectionRequestWithProfile connection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConnectionUserProfileDetailView(
                  profile: connection.profile,
                  connectionRequestId: connection.request.id ?? '',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 25,
                  backgroundImage: connection.profile.photoURL != null
                      ? NetworkImage(connection.profile.photoURL!)
                      : null,
                  child: connection.profile.photoURL == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.profile.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Connection requested on ${_formatDate(connection.request.timestamp)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _fetchConnectionRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          _errorMessage = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      final snapshot = await _db
          .collection("Connects")
          .where("toUserId", isEqualTo: currentUserId)
          .get();

      final requests = snapshot.docs.map((doc) {
        return ConnectionRequest.fromMap(doc.data(), doc.id);
      }).toList();

      if (requests.isEmpty) {
        setState(() {
          _connectionRequests = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch profiles for all requests
      final userIds = requests.map((r) => r.fromUserId).toList();
      final profiles = await _fetchProfiles(userIds);

      final connectionRequests = requests.map((request) {
        final profile = profiles[request.fromUserId];
        if (profile == null) return null;
        
        return ConnectionRequestWithProfile(
          request: request,
          profile: profile,
        );
      }).where((item) => item != null).cast<ConnectionRequestWithProfile>().toList();

      setState(() {
        _connectionRequests = connectionRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, ConnectionUserProfile>> _fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final Map<String, ConnectionUserProfile> profiles = {};
    
    // Firestore allows a maximum of 10 items in an `in` query
    const chunkSize = 10;
    for (int i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      
      final snapshot = await _db
          .collection("Profiles")
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final profile = ConnectionUserProfile.fromMap(doc.data(), doc.id);
        profiles[profile.id] = profile;
      }
    }

    return profiles;
  }
}
