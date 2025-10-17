import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/search/user_search_screen.dart';
import '../screens/business/black_business_screen.dart';
import '../screens/forums/forums_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/connections/todays_matches_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_preview_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/events/events_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthRoute = state.matchedLocation == '/signin' || 
                         state.matchedLocation == '/register';
      
      // If not logged in and not on auth route, redirect to signin
      if (user == null && !isAuthRoute) {
        return '/signin';
      }
      
      // If logged in and on auth route, redirect to discover
      if (user != null && isAuthRoute) {
        return '/discover';
      }
      
      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/discover',
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/discover',
        name: 'discover',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: '/directory',
        name: 'directory',
        builder: (context, state) => const BlackBusinessScreen(),
      ),
      GoRoute(
        path: '/forums',
        name: 'forums',
        builder: (context, state) => const ForumsScreen(),
        routes: [
          GoRoute(
            path: ':postId',
            name: 'forum-post',
            builder: (context, state) {
              final postId = state.pathParameters['postId']!;
              return Scaffold(
                appBar: AppBar(title: const Text('Forum Post')),
                body: Center(child: Text('Forum Post: $postId')),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
        routes: [
          GoRoute(
            path: ':threadId',
            name: 'chat-detail',
            builder: (context, state) {
              final threadId = state.pathParameters['threadId']!;
              final otherUserName = state.uri.queryParameters['name'] ?? 'Chat';
              return ChatDetailScreen(
                chatRoomId: threadId,
                otherUserName: otherUserName,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/matches',
        name: 'matches',
        builder: (context, state) => const TodaysMatchesScreen(),
      ),
      GoRoute(
        path: '/profile/:uid',
        name: 'profile',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final currentUser = FirebaseAuth.instance.currentUser;
          
          // If viewing own profile, show profile screen
          if (currentUser?.uid == uid) {
            return const MainNavigationScreen(initialIndex: 3);
          }
          
          // Otherwise show public profile view
          return ProfilePreviewScreen(userId: uid);
        },
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Settings - Coming Soon')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
