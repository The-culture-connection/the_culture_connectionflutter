import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';
import '../services/universal_connection_service.dart';
import '../services/optimized_data_service.dart';
import '../services/performance_service.dart';

/// TodaysMatchesScreen - Equivalent to iOS TodaysMatchesView.swift
class TodaysMatchesScreen extends StatefulWidget {
  const TodaysMatchesScreen({super.key});

  @override
  State<TodaysMatchesScreen> createState() => _TodaysMatchesScreenState();
}

class _TodaysMatchesScreenState extends State<TodaysMatchesScreen> {
  List<UserProfile> _oldMatches = [];
  List<UserProfile> _newMatches = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedTab = 'all'; // 'all', 'old', 'new'

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadTodaysMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF7E00)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Today\'s Matches',
          style: TextStyle(
            color: Color(0xFFFF7E00),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('all', 'All Matches'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('old', 'Traditional'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('new', 'Skill-Based'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7E00) : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7E00),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodaysMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentMatches = _getCurrentMatches();
    
    if (currentMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_outline,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new matches!',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTodaysMatches(),
      color: const Color(0xFFFF7E00),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: currentMatches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(currentMatches[index]);
        },
      ),
    );
  }

  List<UserProfile> _getCurrentMatches() {
    switch (_selectedTab) {
      case 'old':
        return _oldMatches;
      case 'new':
        return _newMatches;
      case 'all':
      default:
        return [..._oldMatches, ..._newMatches];
    }
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 'old':
        return 'No traditional matches found';
      case 'new':
        return 'No skill-based matches found';
      case 'all':
      default:
        return 'No matches found today';
    }
  }

  Widget _buildMatchCard(UserProfile match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFFF7E00).withOpacity(0.1),
                  child: match.photoURL.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: match.photoURL,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(
                              color: Color(0xFFFF7E00),
                            ),
                            errorWidget: (context, url, error) => Text(
                              match.initials,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7E00),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          match.initials,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7E00),
                          ),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.fullname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${match.age}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Match indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MATCH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bio
            if (match.bio.isNotEmpty) ...[
              Text(
                match.bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            
            // Job Title and Industry
            if (match.jobTitle.isNotEmpty) ...[
              Text(
                match.jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF7E00),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (match.industry.isNotEmpty) ...[
              Text(
                match.industry,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Skills
            if (match.skills.isNotEmpty) ...[
              const Text(
                'Skills:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                match.skills,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleViewProfile(match),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF7E00),
                      side: const BorderSide(color: Color(0xFFFF7E00)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleConnect(match),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7E00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadTodaysMatches() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'You must be logged in to view matches';
          _isLoading = false;
        });
        return;
      }

      // Use optimized data service for both match types
      final results = await Future.wait([
        OptimizedDataService.getMatchesOptimized(
          currentUserId: currentUser.uid,
          isTraditional: true,
        ),
        OptimizedDataService.getMatchesOptimized(
          currentUserId: currentUser.uid,
          isTraditional: false,
        ),
      ]);

      setState(() {
        _oldMatches = results[0];
        _newMatches = results[1];
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load matches: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOldMatches(String currentUserId) async {
    try {
      // Get traditional matches from Firestore
      final matchesSnapshot = await _db
          .collection('matches')
          .where('user1Id', isEqualTo: currentUserId)
          .get();

      final matches2Snapshot = await _db
          .collection('matches')
          .where('user2Id', isEqualTo: currentUserId)
          .get();

      final allMatches = <String>[];
      
      // Collect all match user IDs
      for (final doc in matchesSnapshot.docs) {
        final data = doc.data();
        final user2Id = data['user2Id'] as String?;
        if (user2Id != null) allMatches.add(user2Id);
      }
      
      for (final doc in matches2Snapshot.docs) {
        final data = doc.data();
        final user1Id = data['user1Id'] as String?;
        if (user1Id != null) allMatches.add(user1Id);
      }

      // Get user profiles for old matches
      final profiles = <UserProfile>[];
      for (final userId in allMatches) {
        try {
          final userDoc = await _db.collection('Profiles').doc(userId).get();
          if (userDoc.exists) {
            final profile = UserProfile.fromJson(userDoc.data()! as Map<String, dynamic>);
            profiles.add(profile);
          }
        } catch (e) {
          print('Error loading profile for $userId: $e');
        }
      }

      _oldMatches = profiles;
    } catch (e) {
      print('Error loading old matches: $e');
      _oldMatches = [];
    }
  }

  Future<void> _loadNewMatches(String currentUserId) async {
    try {
      // Get skill-based matches from SkillMatches collection
      final skillMatchesDoc = await _db
          .collection('SkillMatches')
          .doc(currentUserId)
          .get();

      if (!skillMatchesDoc.exists) {
        _newMatches = [];
        return;
      }

      final data = skillMatchesDoc.data()!;
      final matches = data['matches'] as List<dynamic>? ?? [];
      
      final profiles = <UserProfile>[];
      for (final match in matches) {
        try {
          final userId = match['userId'] as String?;
          if (userId != null) {
            final userDoc = await _db.collection('Profiles').doc(userId).get();
            if (userDoc.exists) {
              final profile = UserProfile.fromJson(userDoc.data()! as Map<String, dynamic>);
              profiles.add(profile);
            }
          }
        } catch (e) {
          print('Error loading skill match profile: $e');
        }
      }

      _newMatches = profiles;
    } catch (e) {
      print('Error loading new matches: $e');
      _newMatches = [];
    }
  }

  void _handleViewProfile(UserProfile match) {
    // TODO: Navigate to user profile detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing profile of ${match.fullname}'),
        backgroundColor: const Color(0xFFFF7E00),
      ),
    );
  }

  Future<void> _handleConnect(UserProfile match) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF7E00),
          ),
        ),
      );

      // Send connection request
      final result = await UniversalConnectionService.sendConnectionRequest(
        toUserId: match.id,
        context: 'todays_matches',
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isMatch ? Colors.green : Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );

    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
