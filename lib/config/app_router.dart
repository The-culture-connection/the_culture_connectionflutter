import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/search/user_search_screen.dart';
import '../screens/business/black_business_screen.dart';
import '../screens/forums/forums_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/todays_matches_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_preview_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/events/events_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/signin',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/signin',
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
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/matches',
        name: 'matches',
        builder: (context, state) => const TodaysMatchesScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/signin'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
