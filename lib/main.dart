import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:culture_connection/firebase_options.dart';
import 'package:culture_connection/services/auth_service.dart';
import 'package:culture_connection/services/firestore_service.dart';
import 'package:culture_connection/utils/app_theme.dart';
import 'package:culture_connection/views/auth/login_screen.dart';
import 'package:culture_connection/views/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CultureConnectionApp());
}

class CultureConnectionApp extends StatelessWidget {
  const CultureConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culture Connection',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

/// Auth wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder(
            future: FirestoreService().getUserProfile(snapshot.data!.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // User has completed profile
              if (profileSnapshot.hasData && profileSnapshot.data != null) {
                return const MainTabScreen();
              }

              // User needs to complete profile (shouldn't happen with new registration)
              // For now, sign them out and make them register again
              authService.signOut();
              return const LoginScreen();
            },
          );
        }

        // User is not signed in
        return const LoginScreen();
      },
    );
  }
}
