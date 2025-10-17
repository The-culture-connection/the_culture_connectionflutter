import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

/// ContentView - Equivalent to iOS ContentView.swift
/// Handles authentication state and navigation
class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7E00),
              ),
            ),
          );
        }
        
        // If user is logged in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User is authenticated, showing main app');
          return const MainScreen();
        }
        
        // If user is not logged in, show auth screen
        print('❌ User is not authenticated, showing auth screen');
        return const AuthScreen();
      },
    );
  }
}



