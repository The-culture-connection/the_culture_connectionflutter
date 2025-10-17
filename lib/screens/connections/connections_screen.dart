import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import 'mentorship_connections_screen.dart';
import 'networking_connections_screen.dart';
import 'romantic_connections_screen.dart';
import 'todays_matches_screen.dart';
import 'speed_mentoring_screen.dart';
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
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/Connectionsimage.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.deepPurple.withOpacity(0.9),
                        AppColors.purple700.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to Connections',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Build meaningful professional and personal relationships',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quick Match
                _buildConnectionCard(
                  title: "Today's Matches",
                  subtitle: 'See your daily personalized matches',
                  icon: Icons.favorite,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TodaysMatchesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Mentorship
                _buildConnectionCard(
                  title: 'Mentorship',
                  subtitle: 'Connect with mentors or mentees',
                  icon: Icons.school,
                  gradient: const LinearGradient(
                    colors: [AppColors.purple600, AppColors.purple800],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MentorshipConnectionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Networking
                _buildConnectionCard(
                  title: 'Professional Networking',
                  subtitle: 'Expand your professional network',
                  icon: Icons.business_center,
                  gradient: const LinearGradient(
                    colors: [AppColors.orange600, AppColors.orange800],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NetworkingConnectionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Romantic
                _buildConnectionCard(
                  title: 'Romantic Connections',
                  subtitle: 'Find meaningful relationships',
                  icon: Icons.favorite_border,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RomanticConnectionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Speed Mentoring
                _buildConnectionCard(
                  title: 'Speed Mentoring',
                  subtitle: 'Quick 5-minute connections',
                  icon: Icons.flash_on,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SpeedMentoringScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // User Search
                _buildConnectionCard(
                  title: 'Search Users',
                  subtitle: 'Find specific people by skills and experience',
                  icon: Icons.person_search,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
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

  Widget _buildConnectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
