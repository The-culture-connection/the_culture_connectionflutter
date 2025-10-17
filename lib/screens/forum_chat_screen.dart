import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forums_screen.dart';

class ForumChatScreen extends StatefulWidget {
  final Forum forum;

  const ForumChatScreen({
    super.key,
    required this.forum,
  });

  @override
  State<ForumChatScreen> createState() => _ForumChatScreenState();
}

class _ForumChatScreenState extends State<ForumChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ForumMessage> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      _db
          .collection('Forums')
          .doc(widget.forum.id)
          .collection('Messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _messages = snapshot.docs.map((doc) {
              final data = doc.data();
              return ForumMessage(
                id: doc.id,
                senderId: data['senderId'] ?? '',
                text: data['text'] ?? '',
                timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
                senderName: data['senderName'] ?? 'Unknown',
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Get user's name from profile
      final userDoc = await _db.collection('Profiles').doc(currentUserId).get();
      final senderName = userDoc.data()?['Full Name'] ?? 'Unknown';

      final messageData = {
        'senderId': currentUserId,
        'senderName': senderName,
        'text': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('Forums')
          .doc(widget.forum.id)
          .collection('Messages')
          .add(messageData);

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.forum.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
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
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              'No messages yet. Start the conversation!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _buildMessageBubble(message);
                            },
                          ),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ForumMessage message) {
    final isCurrentUser = message.senderId == _auth.currentUser?.uid;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender Name
          Text(
            message.senderName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          
          // Message Bubble
          Align(
            alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? const Color(0xFFFF7E00).withOpacity(0.8)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Color(0xFF404040), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                filled: true,
                fillColor: Color(0xFF404040),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Color(0xFFFF7E00)),
          ),
        ],
      ),
    );
  }
}

class ForumMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final String senderName;

  ForumMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.senderName,
  });
}

