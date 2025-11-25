import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../utils/ultra_black_friday_navigation.dart';
import '../search/user_search_screen.dart';
import '../business/black_business_screen.dart';
import '../forums/forums_screen.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        title: const Text(
          'DISCOVER',
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
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SEARCH USERS
                _buildDiscoverCard(
                  context,
                  title: 'SEARCH USERS',
                  subtitle: 'Find people to connect with',
                  icon: Icons.person_search,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // GREEN BOOK
                _buildDiscoverCard(
                  context,
                  title: 'GREEN BOOK',
                  subtitle: 'Business directory',
                  icon: Icons.business,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BlackBusinessScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // FORUMS
                _buildDiscoverCard(
                  context,
                  title: 'FORUMS',
                  subtitle: 'Community discussions',
                  icon: Icons.forum,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForumsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // ULTRA BLACK FRIDAY
                _buildDiscoverCard(
                  context,
                  title: 'ULTRA BLACK FRIDAY',
                  subtitle: 'Exclusive deals & discounts',
                  icon: Icons.card_giftcard,
                  onTap: () {
                    print('🔘 ULTRA BLACK FRIDAY card tapped in Discover');
                    navigateToUltraBlackFriday(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2e).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.electricOrange.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricOrange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.electricOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.electricOrange,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.electricOrange,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.electricOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterTight',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.electricOrange,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
