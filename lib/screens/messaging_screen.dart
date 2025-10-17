import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_room.dart';
import 'chat_detail_screen.dart';
import 'connection_requests_screen.dart';

/// MessagingScreen - Equivalent to iOS ChatView.swift
class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, int> _unreadCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    super.dispose();
  }

  Future<void> _fetchChatRooms() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _errorMessage = "User not logged in.";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      _db.collection("ChatRooms")
          .where("participants", arrayContains: currentUser.uid)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.docs.isEmpty) {
          if (mounted) {
            setState(() {
              _chatRooms = [];
              _isLoading = false;
            });
          }
          return;
        }

        List<ChatRoom> fetchedChatRooms = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final participants = data["participants"] as List<dynamic>? ?? [];
          
          if (participants.length != 2) continue;
          
          final otherUserId = participants.firstWhere(
            (id) => id != currentUser.uid,
            orElse: () => "",
          );
          
          if (otherUserId.isEmpty) continue;

          // Fetch other user's profile
          final otherUserDoc = await _db.collection("Profiles").doc(otherUserId).get();
          final otherUserData = otherUserDoc.data();
          final otherUserName = otherUserData?["Full Name"] as String? ?? "Unknown";
          final profileImageURL = otherUserData?["profilePhotoURL"] as String?;

          final chatRoom = ChatRoom(
            id: doc.id,
            participants: participants.cast<String>(),
            lastMessage: data["lastMessage"] as String? ?? "No messages yet",
            lastMessageTimestamp: data["lastMessageTimestamp"] as Timestamp? ?? Timestamp.now(),
            lastMessageSenderId: data["lastMessageSenderId"] as String? ?? "",
            otherParticipantName: otherUserName,
            otherParticipantProfileImage: profileImageURL,
          );

          fetchedChatRooms.add(chatRoom);
          
          // Calculate unread count
          _calculateUnreadCount(chatRoom.id, currentUser.uid);
        }

        if (mounted) {
          setState(() {
            _chatRooms = fetchedChatRooms
                .where((room) => room.id.isNotEmpty)
                .toList()
              ..sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to fetch chat rooms.";
          _isLoading = false;
        });
      }
    }
  }

  void _calculateUnreadCount(String chatRoomId, String currentUserId) {
    _db.collection("ChatRooms")
        .doc(chatRoomId)
        .collection("Messages")
        .where("senderId", isNotEqualTo: currentUserId)
        .where("timestamp", isGreaterThan: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ))
        .get()
        .then((snapshot) {
      if (mounted) {
        setState(() {
          _unreadCounts[chatRoomId] = snapshot.docs.length;
        });
      }
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}";
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
                image: AssetImage('assets/Tamearaimage.png'),
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
                // Logo and Title Section
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/CC_PrimaryLogo_SilverPurple.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Title
                      const Text(
                        'Inbox',
                        style: TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 28,
                          color: Color(0xFFFF7E00),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Chat Rooms List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                "Error: $_errorMessage",
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : _chatRooms.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No open chatrooms",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Start connecting with people to see your conversations here",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _chatRooms.length,
                                  itemBuilder: (context, index) {
                                    final chatRoom = _chatRooms[index];
                                    return _buildChatRoomItem(chatRoom);
                                  },
                                ),
                ),
                
                // Connection Requests Banner
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "CONNECTION REQUESTS",
                        style: TextStyle(
                          color: Color(0xFFFF7E00),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectionRequestsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7E00),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "REVIEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomItem(ChatRoom chatRoom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to chat detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(chatRoom: chatRoom),
            ),
          );
        },
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 25,
              backgroundImage: chatRoom.otherParticipantProfileImage != null
                  ? NetworkImage(chatRoom.otherParticipantProfileImage!)
                  : null,
              child: chatRoom.otherParticipantProfileImage == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            
            const SizedBox(width: 12),
            
            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatRoom.otherParticipantName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Timestamp and Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(chatRoom.lastMessageTimestamp),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (_unreadCounts[chatRoom.id] != null && _unreadCounts[chatRoom.id]! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7E00),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${_unreadCounts[chatRoom.id]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}