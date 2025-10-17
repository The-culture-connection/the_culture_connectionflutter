import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_router.dart';
import 'connections_screen.dart';
import 'messaging_screen.dart';
import 'discover_screen.dart';
import 'edit_profile_screen.dart';
import 'newsfeed_screen.dart';
import 'events_screen.dart';

/// MainScreen - Equivalent to iOS MainTabView.swift
/// Main tab view with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ConnectionsScreen(),
    const MessagingScreen(),
    const DiscoverScreen(),
    const EditProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1d1d1e),
          border: Border(
            top: BorderSide(
              color: Colors.white24,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF685BC6),
          unselectedItemColor: Colors.white70,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 24),
              activeIcon: Icon(Icons.people, size: 24),
              label: 'Connections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 24),
              activeIcon: Icon(Icons.chat_bubble, size: 24),
              label: 'Messaging',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined, size: 24),
              activeIcon: Icon(Icons.newspaper, size: 24),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }
}