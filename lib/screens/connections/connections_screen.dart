import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import 'todays_matches_screen.dart';
import '../events/events_screen.dart';
import '../discover/discover_screen.dart';
import '../search/user_search_screen.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        title: const Text(
          'CONNECTIONS',
          style: TextStyle(
            fontFamily: 'InterTight',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1d1d1e),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/Connectionsimage.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // EVENTS Card (smaller, at top)
                _buildSmallCard(
                  title: 'EVENTS',
                  icon: Icons.event,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EventsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // NEWSFEED Card (smaller, with post preview style)
                _buildSmallCard(
                  title: 'NEWSFEED',
                  subtitle: 'Created this app',
                  icon: Icons.article,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // FIND A MENTOR (large button)
                _buildLargeButton(
                  title: 'FIND A MENTOR',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // GROW YOUR NETWORK (large button)
                _buildLargeButton(
                  title: 'GROW YOUR NETWORK',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // TODAY'S MATCHES (large button)
                _buildLargeButton(
                  title: 'TODAY\'S MATCHES',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TodaysMatchesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2e).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.electricOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.electricOrange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.electricOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterTight',
                      letterSpacing: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.electricOrange,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.electricOrange,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.electricOrange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'InterTight',
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
