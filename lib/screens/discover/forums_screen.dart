import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:culture_connection/screens/discover/forum_chat_screen.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({super.key});

  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Forum> _forums = [];
  bool _isLoading = true;
  bool _showCreateForum = false;

  @override
  void initState() {
    super.initState();
    _fetchForums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/EventImage.png',
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
                // Header with Back Button and Logo
                Padding(
                  padding: const EdgeInsets.all(20),
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
                              const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "BACK",
                                style: TextStyle(
                                  fontFamily: 'Matches-StrikeRough',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
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
                        width: 120,
                        height: 60,
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
                  "FORUMS",
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 28,
                    color: const Color(0xFFFF7E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Content
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
            SizedBox(height: 20),
            Text(
              "Loading forums...",
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

    if (_forums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.forum,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "No forums yet. Create the first one!",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _showCreateForum = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
                ),
              ),
              child: Text(
                "CREATE FORUM",
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Create Forum Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _showCreateForum = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
                ),
              ),
              child: Text(
                "CREATE FORUM",
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Forums List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _forums.length,
            itemBuilder: (context, index) {
              return _buildForumCard(_forums[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForumCard(Forum forum) {
    return Container(
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
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumChatScreen(forum: forum),
            ),
          );
        },
        child: Row(
          children: [
            // Forum Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.forum,
                color: Color(0xFFFF7E00),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Forum Title
            Expanded(
              child: Text(
                forum.title,
                style: TextStyle(
                  fontFamily: 'Inter-VariableFont_slnt,wght',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Chevron
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchForums() async {
    try {
      _db.collection('Forums')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _forums = snapshot.docs.map((doc) {
            final data = doc.data();
            return Forum(
              id: doc.id,
              title: data['title'] ?? 'Untitled Forum',
              timestamp: data['timestamp'],
            );
          }).toList();
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error fetching forums: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class Forum {
  final String id;
  final String title;
  final dynamic timestamp;

  Forum({
    required this.id,
    required this.title,
    required this.timestamp,
  });
}
