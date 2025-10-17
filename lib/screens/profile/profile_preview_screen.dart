import 'package:flutter/material.dart';

class ProfilePreviewScreen extends StatelessWidget {
  final String userId;
  const ProfilePreviewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(child: Text('Profile Preview - User ID: $userId')),
    );
  }
}
