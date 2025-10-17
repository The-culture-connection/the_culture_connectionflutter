import 'package:flutter/material.dart';
import 'package:culture_connection/models/post.dart';
import 'package:culture_connection/models/user_profile.dart';
import 'package:culture_connection/services/firestore_service.dart';
import 'package:culture_connection/views/discover/create_post_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

/// News feed screen
class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
      ),
      body: StreamBuilder<List<Post>>(
        stream: firestoreService.getPostsFeed(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Be the first to share something!'),
                ],
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return _PostCard(post: posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  UserProfile? _author;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final author = await _firestoreService.getUserProfile(widget.post.userId);
    if (mounted) {
      setState(() => _author = author);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: _author?.photoURL.isNotEmpty == true
                  ? CachedNetworkImageProvider(_author!.photoURL)
                  : null,
              child: _author?.photoURL.isEmpty == true
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(_author?.fullName ?? 'Loading...'),
            subtitle: Text(
              DateFormat('MMM d, yyyy').format(widget.post.timestamp),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show post options
              },
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(widget.post.description),
              ],
            ),
          ),

          // Post Image
          if (widget.post.postPhotoURL != null &&
              widget.post.postPhotoURL!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CachedNetworkImage(
                imageUrl: widget.post.postPhotoURL!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

          // Post Type Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Chip(
              label: Text(widget.post.type),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}
