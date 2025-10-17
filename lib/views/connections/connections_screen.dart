import 'package:flutter/material.dart';
import 'package:culture_connection/views/connections/mentorship_connections_screen.dart';
import 'package:culture_connection/views/connections/networking_connections_screen.dart';
import 'package:culture_connection/views/connections/romantic_connections_screen.dart';
import 'package:culture_connection/views/search/user_search_screen.dart';

/// Connections hub screen
class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ConnectionCard(
              title: 'Mentorship',
              icon: Icons.school,
              description: 'Find mentors or mentees',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MentorshipConnectionsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _ConnectionCard(
              title: 'Networking',
              icon: Icons.business_center,
              description: 'Professional connections',
              color: Colors.orange,
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
            _ConnectionCard(
              title: 'Romantic',
              icon: Icons.favorite,
              description: 'Find meaningful relationships',
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RomanticConnectionsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ConnectionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
