import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/event.dart';
import 'events_screen.dart';
import 'newsfeed_screen.dart';
import 'mentorship_connections_screen.dart';
import 'networking_connections_screen.dart';
import 'todays_matches_screen.dart';

/// ConnectionsScreen - Equivalent to iOS ConnectionsView.swift
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  Post? _latestPost;
  Event? _nearestEvent;
  bool _isLoading = true;
  bool _showingTodaysMatches = false;
  final String _connectionRequestId = DateTime.now().millisecondsSinceEpoch.toString();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Tamearaimage-2.png'),
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
                const Spacer(),
                
                // Logo and Title Section
                Column(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/CC_PrimaryLogo_SilverPurple.png',
                      height: 60,
                      width: 220,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Content Cards Section
                    Column(
                      children: [
                        // Events and Newsfeed Cards
                        Row(
                          children: [
                            // Events Card
                            Expanded(
                              child: _buildContentCard(
                                icon: Icons.calendar_today,
                                iconColor: const Color(0xFF1d1d1e),
                                title: 'EVENTS',
                                content: _nearestEvent != null
                                    ? _nearestEvent!.title
                                    : 'Nearest event',
                                subtitle: _nearestEvent != null
                                    ? _formatDate(_nearestEvent!.date)
                                    : null,
                                buttonText: 'SEE ALL',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EventsScreen()),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Newsfeed Card
                            Expanded(
                              child: _buildContentCard(
                                icon: Icons.article,
                                iconColor: const Color(0xFFFF7E00),
                                title: 'NEWSFEED',
                                content: _latestPost != null
                                    ? _latestPost!.title
                                    : 'Latest post',
                                subtitle: _latestPost != null
                                    ? _formatRelativeTime(_latestPost!.timestamp)
                                    : null,
                                buttonText: 'OPEN',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsFeedScreen(
                                        connectionRequestId: _connectionRequestId,
                                      ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
                        
                        const SizedBox(height: 16),
                        
                        // Action Buttons Section
                        Column(
                          children: [
                            // FIND A MENTOR Button
                            _buildActionButton(
                              text: 'FIND A MENTOR',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MentorshipConnectionsScreen(),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // GROW YOUR NETWORK Button
                            _buildActionButton(
                              text: 'GROW YOUR NETWORK',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NetworkingConnectionsScreen(),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // TODAY'S MATCHES Button
                            _buildActionButton(
                              text: "TODAY'S MATCHES",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TodaysMatchesScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),
              ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
            Text(
                  title,
              style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            
              const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 20,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7E00),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Matches-StrikeRough',
            fontSize: 20,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _fetchLatestData() {
    _fetchLatestPost();
    _fetchNearestEvent();
  }

  void _fetchLatestPost() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // First get blocked users
    _db.collection("Profiles").doc(currentUserId).get().then((snapshot) {
      final blockedUsers = snapshot.data()?["blockedUsers"] as Map<String, dynamic>? ?? {};
      final blockedUserIDs = blockedUsers.keys.toSet();

      // Then fetch latest post
      _db.collection("posts")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data();

          final userId = data["userId"] as String?;
          if (userId != null && !blockedUserIDs.contains(userId)) {
            if (mounted) {
              setState(() {
                _latestPost = Post(
                  id: doc.id,
                  title: data["title"] as String? ?? '',
                  description: data["description"] as String? ?? '',
                  type: data["type"] as String? ?? '',
                  userId: userId,
                  postPhotoURL: data["postPhotoURL"] as String?,
                  timestamp: (data["timestamp"] as Timestamp?)?.toDate() ?? DateTime.now(),
                );
              });
            }
          }
        }
      });
    });
  }

  void _fetchNearestEvent() {
    final now = DateTime.now();

    _db.collection("events")
        .where("date", isGreaterThan: now)
        .orderBy("date", descending: false)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();

        if (mounted) {
          setState(() {
            _nearestEvent = Event(
              id: doc.id,
              title: data["title"] as String? ?? '',
              details: data["details"] as String? ?? '',
              date: (data["date"] as Timestamp?)?.toDate() ?? DateTime.now(),
              place: data["place"] as String? ?? '',
              url: data["url"] as String?,
            );
          });
        }
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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
}