import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth_screen.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/connections_screen.dart';
import '../screens/messaging_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/events_screen.dart';

/// App Router Configuration
class AppRouter {
  static const String rootPath = '/';
  static const String authPath = '/auth';
  static const String loginPath = '/login';
  static const String registrationPath = '/registration';
  static const String registrationTwoPath = '/registration-two';
  static const String mainPath = '/main';
  static const String connectionsPath = '/connections';
  static const String messagingPath = '/messaging';
  static const String discoverPath = '/discover';
  static const String profilePath = '/profile';
  static const String userSearchPath = '/user-search';
  static const String blackBusinessPath = '/black-business';
  static const String forumsPath = '/forums';
  static const String chatDetailPath = '/chat-detail';
  static const String connectionRequestsPath = '/connection-requests';
  static const String termsPath = '/terms';
  static const String passwordResetPath = '/password-reset';
  static const String newsfeedPath = '/newsfeed';
  static const String eventsPath = '/events';
  static const String mentorshipPath = '/mentorship';
  static const String networkingPath = '/networking';
  static const String todaysMatchesPath = '/todays-matches';

  static final GoRouter router = GoRouter(
    initialLocation: rootPath,
    routes: [
      GoRoute(
        path: rootPath,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: authPath,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registrationPath,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: registrationTwoPath,
        builder: (context, state) => const RegistrationScreen(), // TODO: Create RegistrationTwoScreen
      ),
      GoRoute(
        path: mainPath,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: connectionsPath,
        builder: (context, state) => const ConnectionsScreen(),
      ),
      GoRoute(
        path: messagingPath,
        builder: (context, state) => const MessagingScreen(),
      ),
      GoRoute(
        path: discoverPath,
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: userSearchPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('User Search - Coming Soon')),
        ),
      ),
      GoRoute(
        path: blackBusinessPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Black Business - Coming Soon')),
        ),
      ),
      GoRoute(
        path: forumsPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forums - Coming Soon')),
        ),
      ),
      GoRoute(
        path: chatDetailPath,
        builder: (context, state) {
          final chatRoom = state.extra;
          return Scaffold(
            body: Center(
              child: Text('Chat Detail - Coming Soon\nChatRoom: $chatRoom'),
            ),
          );
        },
      ),
      GoRoute(
        path: connectionRequestsPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Connection Requests - Coming Soon')),
        ),
      ),
      GoRoute(
        path: termsPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Terms and Conditions - Coming Soon')),
        ),
      ),
      GoRoute(
        path: passwordResetPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Password Reset - Coming Soon')),
        ),
      ),
      GoRoute(
        path: newsfeedPath,
        builder: (context, state) {
          final connectionRequestId = state.extra as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
          return NewsFeedScreen(connectionRequestId: connectionRequestId);
        },
      ),
      GoRoute(
        path: eventsPath,
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: mentorshipPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Mentorship - Coming Soon')),
        ),
      ),
      GoRoute(
        path: networkingPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Networking - Coming Soon')),
        ),
      ),
      GoRoute(
        path: todaysMatchesPath,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Today\'s Matches - Coming Soon')),
        ),
      ),
    ],
  );
}