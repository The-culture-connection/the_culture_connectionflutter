import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/forum.dart';
import '../../services/firestore_service.dart';

class ForumsScreen extends ConsumerWidget {
  const ForumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'FORUMS',
          style: TextStyle(
            fontFamily: 'InterTight',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1d1d1e),
        elevation: 0,
      ),
      body: Column(
        children: [
          // CREATE FORUM button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                _showCreateForumDialog(context, ref);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricOrange,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'CREATE FORUM',
                    style: TextStyle(
                      color: AppColors.electricOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterTight',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Forums list
          Expanded(
            child: StreamBuilder<List<Forum>>(
              stream: firestoreService.streamForums(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.electricOrange),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final forums = snapshot.data ?? [];

                if (forums.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No forums yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create the first forum',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: forums.length,
                  itemBuilder: (context, index) {
                    return _buildForumTile(context, forums[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumTile(BuildContext context, Forum forum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.deepPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.electricOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.forum,
            color: AppColors.electricOrange,
            size: 24,
          ),
        ),
        title: Text(
          forum.forumName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: forum.forumDescription != null
            ? Text(
                forum.forumDescription!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: () {
          // Navigate to forum detail (implement later)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${forum.forumName}...'),
              backgroundColor: AppColors.deepPurple,
            ),
          );
        },
      ),
    );
  }

  void _showCreateForumDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2e),
        title: const Text(
          'Create New Forum',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Forum Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.electricOrange),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.electricOrange),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a forum name'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final userId = ref.read(currentUserIdProvider);
              if (userId == null) return;

              final firestoreService = ref.read(firestoreServiceProvider);

              try {
                final forum = Forum(
                  forumId: '', // Will be set by Firestore
                  forumName: nameController.text.trim(),
                  forumDescription: descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim(),
                  createdBy: userId,
                  createdAt: DateTime.now(),
                  memberCount: 1,
                  postCount: 0,
                );

                await firestoreService.createForum(forum);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forum created successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricOrange,
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
