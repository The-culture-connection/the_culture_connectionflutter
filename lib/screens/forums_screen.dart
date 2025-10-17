import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forum_chat_screen.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({super.key});

  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  List<Forum> _forums = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showCreateForum = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchForums();
  }

  Future<void> _fetchForums() async {
    try {
      _db
          .collection('Forums')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _forums = snapshot.docs.map((doc) {
              final data = doc.data();
              return Forum(
                id: doc.id,
                title: data['title'] ?? 'Untitled Forum',
                timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
              );
            }).toList();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
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
                image: AssetImage('assets/EventImage.png'),
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
                    'FORUMS',
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
                          : _forums.isEmpty
                              ? _buildEmptyState()
                              : _buildForumsList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _showCreateForum ? _buildCreateForumSheet() : null,
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
            'assets/CC_PrimaryLogo_SilverPurple.png',
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No forums yet. Create the first one!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showCreateForum = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFFF7E00),
                    width: 2,
                  ),
                ),
              ),
              child: const Text(
                'CREATE FORUM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Matches-StrikeRough',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumsList() {
    return Column(
      children: [
        // Create Forum Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showCreateForum = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFFF7E00),
                    width: 2,
                  ),
                ),
              ),
              child: const Text(
                'CREATE FORUM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Matches-StrikeRough',
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
              final forum = _forums[index];
              return _buildForumCard(forum);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForumCard(Forum forum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumChatScreen(forum: forum),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Color(0xFFFF7E00),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Text(
                  forum.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForumSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create New Forum',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Forum Title',
              labelStyle: TextStyle(color: Colors.grey),
              hintText: 'Enter forum title',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFF404040),
            ),
            onChanged: (value) {
              // Store the value for creating the forum
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCreateForum = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createForum,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createForum() async {
    // This would need a proper TextEditingController to get the title
    // For now, we'll create a forum with a default title
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final forumData = {
        'title': 'New Forum',
        'createdBy': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db.collection('Forums').add(forumData);
      
      setState(() {
        _showCreateForum = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Forum created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating forum: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class Forum {
  final String id;
  final String title;
  final Timestamp timestamp;

  Forum({
    required this.id,
    required this.title,
    required this.timestamp,
  });
}
