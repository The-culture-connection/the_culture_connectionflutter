import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../todays_matches_screen.dart';
import '../events/events_screen.dart';
import '../newsfeed_screen.dart';
import '../search/user_search_screen.dart';
import '../mentoring/mentoring_connections_screen.dart';
import '../networking/networking_connections_screen.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final String _connectionRequestId = DateTime.now().millisecondsSinceEpoch.toString();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Tamearaimage-2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              children: [
                const SizedBox(height: 50),
                
                // Logo Section
                Image.asset(
                  'assets/CC_PrimaryLogo_SilverPurple.png',
                  height: 80,
                  width: 280,
                ),
                
                const SizedBox(height: 30),
                
                // Title Section
                const Text(
                  'CONNECTIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: 'Matches-StrikeRough',
                  ),
                ),
                
                const SizedBox(height: 30),
                  
                // Content Cards Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Events and Newsfeed Cards - Square layout
                      Row(
                        children: [
                          // Events Card
                          Expanded(
                            child: _buildSquareCard(
                              icon: Icons.calendar_today,
                              iconColor: const Color(0xFFFF7E00),
                              title: 'EVENTS',
                              content: 'Nearest event',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EventsScreen()),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Newsfeed Card
                          Expanded(
                            child: _buildSquareCard(
                              icon: Icons.article,
                              iconColor: const Color(0xFFFF7E00),
                              title: 'NEWSFEED',
                              content: 'Whats going on',
                              subtitle: 'Recently',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsFeedScreen(
                                      connectionRequestId: _connectionRequestId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons Section
                      Column(
                        children: [
                          // FIND A MENTOR Button
                          _buildActionButton(
                            text: 'FIND A MENTOR',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MentoringConnectionsScreen(),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // GROW YOUR NETWORK Button
                          _buildActionButton(
                            text: 'GROW YOUR NETWORK',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NetworkingConnectionsScreen(),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // TODAY'S MATCHES Button
                          _buildActionButton(
                            text: "TODAY'S MATCHES",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TodaysMatchesScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0, // Makes it square
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF7E00),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: 'Matches-StrikeRough',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: iconColor,
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ],
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7E00),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
            fontFamily: 'Matches-StrikeRough',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
