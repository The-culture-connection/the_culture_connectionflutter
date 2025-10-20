import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/event.dart';
import 'events/events_screen.dart';
import 'newsfeed_screen.dart'; // NewsFeedScreen import
import 'mentorship_connections_screen.dart';
import 'networking_connections_screen.dart';
import 'todays_matches_screen.dart';
import 'voting_screen.dart';
import 'admin_voting_results_screen.dart';

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
      backgroundColor: const Color(0xFF1D1D1E),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Tamearaimage-2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              children: [
                const SizedBox(height: 50),
                
                // Logo Section
                Image.asset(
                  'assets/CC_PrimaryLogo_SilverPurple.png',
                  height: 80,
                  width: 280,
                ),
                
                const SizedBox(height: 30),
                
                // Title Section
                const Text(
                  'CONNECTIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: 'Matches-StrikeRough',
                  ),
                ),
                
                const SizedBox(height: 30),
                  
                // Content Cards Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Events and Newsfeed Cards - Square layout
                      Row(
                        children: [
                          // Events Card
                          Expanded(
                            child: _buildSquareCard(
                              icon: Icons.calendar_today,
                              iconColor: const Color(0xFFFF7E00),
                              title: 'EVENTS',
                              content: _nearestEvent != null
                                  ? _nearestEvent!.title
                                  : 'Nearest event',
                              subtitle: _nearestEvent != null
                                  ? _formatDate(_nearestEvent!.date)
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EventsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Newsfeed Card
                          Expanded(
                            child: _buildSquareCard(
                              icon: Icons.article,
                              iconColor: const Color(0xFFFF7E00),
                              title: 'NEWSFEED',
                              content: _latestPost != null
                                  ? _latestPost!.title
                                  : 'Created this app',
                              subtitle: _latestPost != null
                                  ? _formatRelativeTime(_latestPost!.timestamp)
                                  : '26 days, 16 hr',
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
                      
                      const SizedBox(height: 24),
                      
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
                          
                          const SizedBox(height: 16),
                          
                          // LIVE VOTING Button
                          _buildActionButton(
                            text: "LIVE VOTING",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VotingScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0, // Makes it square
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF7E00),
              width: 1.5,
            ),
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: 'Matches-StrikeRough',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: iconColor,
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
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
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ],
              
              const Spacer(),
            ],
          ),
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
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7E00),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
            fontFamily: 'Matches-StrikeRough',
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
              header: data["header"] as String? ?? data["title"] as String? ?? '',
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