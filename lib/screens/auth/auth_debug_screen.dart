import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';

class AuthDebugScreen extends ConsumerWidget {
  const AuthDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Auth State Provider', authState.when(
              data: (user) => 'User ID: ${user?.uid ?? 'null'}\nEmail: ${user?.email ?? 'null'}',
              loading: () => 'Loading...',
              error: (e, st) => 'Error: $e',
            )),
            const SizedBox(height: 16),
            _buildSection('Current User ID Provider', currentUserId ?? 'null'),
            const SizedBox(height: 16),
            _buildSection('Firebase Auth Current User', 
              currentUser != null 
                ? 'User ID: ${currentUser.uid}\nEmail: ${currentUser.email}'
                : 'null'
            ),
            const SizedBox(height: 16),
            _buildSection('Is Logged In?', currentUser != null ? 'YES ✅' : 'NO ❌'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepPurple.withOpacity(0.1),
        border: Border.all(color: AppColors.deepPurple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.electricOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
