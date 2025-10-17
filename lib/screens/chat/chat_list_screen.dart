import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_room.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view chats'),
        ),
      );
    }

    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: firestoreService.streamUserChatRooms(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.electricOrange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start connecting with people!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserId = chatRoom.getOtherParticipantId(userId);

              return _ChatRoomTile(
                chatRoom: chatRoom,
                otherUserId: otherUserId,
                currentUserId: userId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoom chatRoom;
  final String otherUserId;
  final String currentUserId;

  const _ChatRoomTile({
    required this.chatRoom,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return FutureBuilder<UserProfile?>(
      future: firestoreService.getUserProfile(otherUserId),
      builder: (context, snapshot) {
        final otherUser = snapshot.data;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.deepPurple,
            backgroundImage: otherUser?.photoURL != null
                ? NetworkImage(otherUser!.photoURL!)
                : null,
            child: otherUser?.photoURL == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            otherUser?.fullName ?? 'Loading...',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            chatRoom.lastMessage ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chatRoom.lastMessageTimestamp != null)
                Text(
                  timeago.format(chatRoom.lastMessageTimestamp!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              const SizedBox(height: 4),
              if (chatRoom.getUnreadCount(currentUserId) > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.electricOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chatRoom.getUnreadCount(currentUserId)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  chatRoomId: chatRoom.id,
                  otherUser: otherUser,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
