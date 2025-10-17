import 'package:flutter/material.dart';

/// Discover/news feed screen
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: const Center(
        child: Text('Discover Feed - Coming Soon'),
      ),
    );
  }
}
