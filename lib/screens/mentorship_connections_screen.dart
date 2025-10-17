import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/universal_connection_service.dart';
import '../services/optimized_data_service.dart';
import '../services/performance_service.dart';

/// MentorshipConnectionsScreen - Matches iOS MentorshipConnectionsView design
class MentorshipConnectionsScreen extends StatefulWidget {
  const MentorshipConnectionsScreen({super.key});

  @override
  State<MentorshipConnectionsScreen> createState() => _MentorshipConnectionsScreenState();
}

class _MentorshipConnectionsScreenState extends State<MentorshipConnectionsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMentorshipProfiles();
  }

  Future<void> _loadMentorshipProfiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Get current user's preferences with caching
      final currentUserData = await _getCurrentUserPreferences(currentUserId);
      if (currentUserData == null) return;

      final minAge = currentUserData['minageseeking'] ?? 18;
      final maxAge = currentUserData['maxageseeking'] ?? 50;
      final genderPrefs = currentUserData['Gender Preferences'] ?? 'Everyone';

      // Use optimized data service
      final profiles = await OptimizedDataService.getProfilesOptimized(
        collection: 'Profiles',
        connectionPreference: 'Mentor',
        minAge: minAge,
        maxAge: maxAge,
        genderPrefs: genderPrefs,
        limit: 50,
      );

      // Filter out current user
      final filteredProfiles = profiles.where((profile) => profile.id != currentUserId).toList();

      setState(() {
        _profiles = filteredProfiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading mentorship profiles: $e');
    }
  }

  Future<Map<String, dynamic>?> _getCurrentUserPreferences(String userId) async {
    return await PerformanceService.getCachedOrCompute(
      'user_preferences_$userId',
      () async {
        final doc = await _db.collection('Profiles').doc(userId).get();
        return doc.exists ? doc.data() : null;
      },
      cacheExpiry: const Duration(minutes: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mentorship',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7E00),
              ),
            )
          : _profiles.isEmpty
              ? const Center(
                  child: Text(
                    'No mentorship profiles found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )
              : _buildProfileCard(_profiles[_currentIndex]),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Three-Dot Menu (iOS style)
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 24,
                  ),
                  color: const Color(0xFF2A2A2A),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Block User', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Report User', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'block') {
                      _handleBlock(profile.id);
                    } else if (value == 'report') {
                      _handleReport(profile.id);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Profile Photo - Clean and prominent like iOS
          Container(
            width: 300,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.withOpacity(0.3),
            ),
            child: profile.photoURL.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      profile.photoURL,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderPhoto();
                      },
                    ),
                  )
                : _buildPlaceholderPhoto(),
          ),
          
          // Profile Info Section - Clean layout like iOS
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Name - Large title like iOS
                Text(
                  profile.fullname,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Job Title and Age - iOS style
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (profile.jobTitle.isNotEmpty) ...[
                      Text(
                        profile.jobTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (profile.age > 0) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${profile.age}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ] else if (profile.age > 0) ...[
                      Text(
                        '${profile.age}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Experience Level and Industry - iOS style
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (profile.experienceLevel.isNotEmpty) ...[
                      Text(
                        'Level: ${profile.experienceLevel}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (profile.industry.isNotEmpty) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          profile.industry,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ] else if (profile.industry.isNotEmpty) ...[
                      Text(
                        profile.industry,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Skills Section - Like iOS with pill-shaped tags
                if (profile.skills.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSkillsTags(profile.skills),
                  const SizedBox(height: 16),
                ],
                
                // Action Buttons - iOS style
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handlePass(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pass',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleConnect(profile.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSkillsTags(String skills) {
    final skillsList = skills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).take(6).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skillsList.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          skill,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      )).toList(),
    );
  }

  void _handlePass() {
    setState(() {
      _currentIndex++;
    });
  }

  Future<void> _handleConnect(String userId) async {
    try {
      await UniversalConnectionService.sendConnectionRequest(
        toUserId: userId,
        context: 'mentorship',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request sent!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _currentIndex++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleBlock(String userId) {
    // TODO: Implement block functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User blocked'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleReport(String userId) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User reported'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
