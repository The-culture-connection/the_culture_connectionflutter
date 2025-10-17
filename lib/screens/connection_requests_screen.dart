import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'connection_user_profile_detail_screen.dart';
import '../services/notification_triggers.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  List<ConnectionRequestWithProfile> _connectionRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchConnectionRequests();
  }

  Future<void> _fetchConnectionRequests() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not logged in';
            _isLoading = false;
          });
        }
        return;
      }

      print('Current User ID: $currentUserId');

      final snapshot = await _db
          .collection('Connects')
          .where('toUserId', isEqualTo: currentUserId)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _connectionRequests = [];
            _isLoading = false;
          });
        }
        return;
      }

      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        return ConnectionRequest(
          id: doc.id,
          fromUserId: data['fromUserId'] ?? '',
          toUserId: data['toUserId'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final userIds = requests.map((request) => request.fromUserId).toList();
      print('Fetched User IDs: $userIds');

      final profiles = await _fetchProfiles(userIds);
      
      if (mounted) {
        setState(() {
          _connectionRequests = requests.map((request) {
            final profile = profiles[request.fromUserId];
            return ConnectionRequestWithProfile(
              request: request,
              profile: profile ?? ConnectionUserProfile(
                id: request.fromUserId,
                fullName: 'Unknown',
                age: 0,
                jobTitle: 'N/A',
                photoURL: null,
              ),
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching connection requests: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, ConnectionUserProfile>> _fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final profiles = <String, ConnectionUserProfile>{};
    
    // Firestore allows a maximum of 10 items in an `in` query
    final chunks = _chunkList(userIds, 10);
    
    for (final chunk in chunks) {
      try {
        final snapshot = await _db
            .collection('Profiles')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final profile = ConnectionUserProfile(
            id: doc.id,
            fullName: data['Full Name'] as String? ?? 'Unknown',
            age: data['Age'] as int? ?? 0,
            jobTitle: data['Job Title'] as String? ?? 'N/A',
            photoURL: data['photoURL'] as String?,
          );
          profiles[profile.id] = profile;
        }
      } catch (e) {
        print('Error fetching profile chunk: $e');
      }
    }

    return profiles;
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
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
                    'CONNECTION REQUESTS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7E00),
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF7E00),
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                'Error: $_errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : _connectionRequests.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No connection requests available.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: _connectionRequests.length,
                                  itemBuilder: (context, index) {
                                    final connection = _connectionRequests[index];
                                    return _buildConnectionRequestCard(connection);
                                  },
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

  Widget _buildConnectionRequestCard(ConnectionRequestWithProfile connection) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectionUserProfileDetailScreen(
              profile: connection.profile,
              connectionRequestId: connection.request.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: connection.profile.photoURL != null
                  ? CachedNetworkImage(
                      imageUrl: connection.profile.photoURL!,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connection.profile.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connection requested on ${_formatDate(connection.request.timestamp)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Inter',
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ConnectionRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;

  ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
  });
}

class ConnectionUserProfile {
  final String id;
  final String fullName;
  final int age;
  final String jobTitle;
  final String? photoURL;

  ConnectionUserProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.jobTitle,
    this.photoURL,
  });
}

class ConnectionRequestWithProfile {
  final ConnectionRequest request;
  final ConnectionUserProfile profile;

  ConnectionRequestWithProfile({
    required this.request,
    required this.profile,
  });
}
