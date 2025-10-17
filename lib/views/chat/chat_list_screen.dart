import 'package:flutter/material.dart';

/// Chat list screen
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: const Center(
        child: Text('Chat List - Coming Soon'),
      ),
    );
  }
}
