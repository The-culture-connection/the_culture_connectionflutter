import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
// import '../services/performance_service.dart';
// import '../services/performance_monitor.dart';
import 'user_profile_screen.dart';
import 'user_post_view.dart';
import 'post_swipe_view.dart';

/// NewsFeedScreen - Equivalent to iOS PostView.swift
class NewsFeedScreen extends StatefulWidget {
  final String connectionRequestId;
  
  const NewsFeedScreen({
    super.key,
    required this.connectionRequestId,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  List<Post> _posts = [];
  bool _isFetched = false;
  String? _selectedTypeFilter;
  String? _expandedPostId;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
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
            child: Column(
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF7E00),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: Color(0xFFFF7E00),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFFFF7E00),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Logo and Title Section
                Container(
                  padding: const EdgeInsets.only(top: 20),
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
                        'NEWSFEED',
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
                
                // Filter Picker
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment<String?>(
                        value: null,
                        label: Text('All'),
                      ),
                      ButtonSegment<String?>(
                        value: 'service',
                        label: Text('Service'),
                      ),
                      ButtonSegment<String?>(
                        value: 'event',
                        label: Text('Event'),
                      ),
                      ButtonSegment<String?>(
                        value: 'academic achievements',
                        label: Text('Academic'),
                      ),
                      ButtonSegment<String?>(
                        value: 'conferences',
                        label: Text('Conferences'),
                      ),
                    ],
                    selected: {_selectedTypeFilter},
                    onSelectionChanged: (Set<String?> selection) {
                      setState(() {
                        _selectedTypeFilter = selection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFFF7E00);
                          }
                          return const Color(0xFF2A2A2A);
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return Colors.white;
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Posts List
                Expanded(
                  child: _filteredPosts.isEmpty
                      ? const Center(
                          child: Text(
                            'No posts yet. Create the first one!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _fetchPosts();
                          },
                          color: const Color(0xFFFF7E00),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = _filteredPosts[index];
                              return _buildPostCard(post);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPostView(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFFF7E00),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Post> get _filteredPosts {
    return _selectedTypeFilter == null
        ? _posts
        : _posts.where((post) => post.type == _selectedTypeFilter).toList();
  }

  Widget _buildPostCard(Post post) {
    final isExpanded = _expandedPostId == post.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7E00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  post.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedPostId = isExpanded ? null : post.id;
              });
            },
            child: Text(
              post.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          
          // Post Image
          if (post.postPhotoURL != null && post.postPhotoURL!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.postPhotoURL!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Timestamp
          Text(
            _formatRelativeTime(post.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // VIEW PROFILE Button
          if (post.userId != _auth.currentUser?.uid)
            GestureDetector(
              onTap: () => _navigateToPostSwipeView(post.userId),
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
                  'VIEW PROFILE',
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
        ],
      ),
    );
  }

  Future<void> _fetchPosts() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // await PerformanceMonitor.measure('fetch_posts', () async {
      // First get blocked users with caching
      final blockedUserIDs = await _getBlockedUsers(currentUserId);

      // Then fetch posts with optimization
      final posts = await _fetchPostsOptimized(blockedUserIDs);
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _isFetched = true;
        });
      }
    // });
  }

  Future<Set<String>> _getBlockedUsers(String userId) async {
    // return await PerformanceService.getCachedOrCompute(
    //   'blocked_users_$userId',
    //   () async {
        final snapshot = await _db.collection("Profiles").doc(userId).get();
        final blockedUsers = snapshot.data()?["blockedUsers"] as Map<String, dynamic>? ?? {};
        return blockedUsers.keys.toSet();
    //   },
    //   cacheExpiry: const Duration(minutes: 5),
    // );
  }

  Future<List<Post>> _fetchPostsOptimized(Set<String> blockedUserIDs) async {
    return await _fetchPostsCompute(blockedUserIDs);
  }

  static Future<List<Post>> _fetchPostsCompute(Set<String> blockedUserIDs) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("timestamp", descending: true)
          .limit(50) // Limit posts for performance
          .get();
      
      final List<Post> posts = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data["userId"] as String?;
        
        // Exclude posts from blocked users
        if (userId != null && !blockedUserIDs.contains(userId)) {
          final post = Post(
            id: doc.id,
            title: data["title"] as String? ?? '',
            description: data["description"] as String? ?? '',
            type: data["type"] as String? ?? '',
            userId: userId,
            postPhotoURL: data["postPhotoURL"] as String?,
            timestamp: (data["timestamp"] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
          posts.add(post);
        }
      }
      
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Navigate to PostSwipeView (user profile view)
  Future<void> _navigateToPostSwipeView(String userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostSwipeView(
          userId: userId,
          connectionRequestId: widget.connectionRequestId,
        ),
      ),
    );
  }

  /// Show user profile when post is tapped
  Future<void> _showUserProfile(String userId) async {
    try {
      // Fetch user profile data
      final userDoc = await _db.collection('Profiles').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final userProfile = UserProfile.fromJson(userData);
        
        // Navigate to user profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userProfile: userProfile,
              connectionRequestId: widget.connectionRequestId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User profile not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
