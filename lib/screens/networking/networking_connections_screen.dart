import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/user_profile.dart';
import '../../services/rsvp_service.dart';
import '../../constants/app_colors.dart';
import '../mentoring/profile_card_view.dart';

class NetworkingConnectionsScreen extends StatefulWidget {
  const NetworkingConnectionsScreen({super.key});

  @override
  State<NetworkingConnectionsScreen> createState() => _NetworkingConnectionsScreenState();
}

class _NetworkingConnectionsScreenState extends State<NetworkingConnectionsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RSVPService _rsvpService = RSVPService();
  
  List<UserProfile> _profiles = [];
  int _currentIndex = 0;
  UserProfile? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/EventImage.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button and Logo
                _buildHeader(),
                
                // Title
                _buildTitle(),
                
                // Main Content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Logo
          Image.asset(
            'assets/CC_PrimaryLogo_SilverPurple.png',
            width: 120,
            height: 60,
            fit: BoxFit.contain,
          ),
          
          const Spacer(),
          
          // Invisible spacer to balance layout
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'NETWORKING',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF7E00),
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7E00)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading connections...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    if (_profiles.isEmpty) {
      return _buildNoProfilesView();
    }
    
    if (_currentIndex < _profiles.length) {
      return ProfileCardView(
        profile: _profiles[_currentIndex],
        onConnect: () => _handleConnectAction(_profiles[_currentIndex]),
        onPass: _handlePassAction,
      );
    }
    
    return _buildNoMoreProfilesView();
  }

  Widget _buildNoProfilesView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Icon
            const Icon(
              Icons.people,
              size: 80,
              color: Color(0xFFFF7E00),
            ),
            
            const SizedBox(height: 24),
            
            // Main message
            const Column(
              children: [
                Text(
                  'No Networking Connections Found',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'No networking connections match your current preferences.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Suggestions
            _buildSuggestions(),
            
            const SizedBox(height: 24),
            
            // Back button
            _buildBackButton(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMoreProfilesView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Icon
            const Icon(
              Icons.people,
              size: 80,
              color: Color(0xFFFF7E00),
            ),
            
            const SizedBox(height: 24),
            
            // Main message
            const Column(
              children: [
                Text(
                  'No More Connections Available',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'You\'ve seen all available networking connections in your area!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Suggestions
            _buildSuggestions(),
            
            const SizedBox(height: 24),
            
            // Back button
            _buildBackButton(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Try These Suggestions:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF7E00),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSuggestionRow(
          icon: Icons.calendar_today,
          title: 'Expand Age Range',
          description: 'Consider connecting with people outside your current age range',
        ),
        
        _buildSuggestionRow(
          icon: Icons.people,
          title: 'Broaden Gender Preferences',
          description: 'Set preferences to \'Everyone\' to see more profiles',
        ),
        
        _buildSuggestionRow(
          icon: Icons.business,
          title: 'Adjust Industry Filter',
          description: 'Turn off \'Match by Industry\' to see diverse professionals',
        ),
        
        _buildSuggestionRow(
          icon: Icons.refresh,
          title: 'Check Back Later',
          description: 'New users join daily - try again tomorrow!',
        ),
      ],
    );
  }

  Widget _buildSuggestionRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF7E00).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF7E00),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Back to Main Menu',
          style: TextStyle(
            color: Color(0xFFFF7E00),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCurrentUserPreferences() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated.';
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await _db.collection('Profiles').doc(user.uid).get();
      if (!doc.exists) {
        setState(() {
          _errorMessage = 'No user preferences found.';
          _isLoading = false;
        });
        return;
      }

      try {
        _currentUser = UserProfile.fromFirestore(doc);
        print('✅ Current user loaded successfully: ${_currentUser!.fullName}');
        await _fetchNetworkingConnections(_currentUser!);
      } catch (e) {
        print('❌ Error creating UserProfile: $e');
        print('❌ Document data: ${doc.data()}');
        rethrow;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching preferences: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNetworkingConnections(UserProfile user) async {
    try {
      final currentUserId = _auth.currentUser!.uid;
      
      // Get excluded users
      final userActionsDoc = await _db.collection('UserActions').doc(currentUserId).get();
      final userActionsData = userActionsDoc.data() ?? {};
      
      final blockedUsers = List<String>.from(userActionsData['blockedUsers'] ?? []);
      final passedUsers = List<String>.from(userActionsData['passedUsers'] ?? []);
      final connectedUsers = List<String>.from(userActionsData['connectedUsers'] ?? []);
      
      final excludedUserIDs = [...blockedUsers, ...passedUsers, ...connectedUsers]
          .where((id) => id.isNotEmpty)
          .toList();

      // Build query
      Query query = _db.collection('Profiles');
      
      // Age filter
      final minAge = user.minAgeSeeking ?? 18;
      final maxAge = user.maxAgeSeeking ?? 100;
      query = query
          .where('Age', isGreaterThanOrEqualTo: minAge)
          .where('Age', isLessThanOrEqualTo: maxAge);
      
      // Gender filter
      if (user.genderPreferences != 'Everyone') {
        query = query.where('Gender Identity', isEqualTo: user.genderPreferences);
      }
      
      // Industry filter
      if (user.matchByIndustry && user.industry.isNotEmpty) {
        query = query.where('Industry', isEqualTo: user.industry);
      }
      
      // Exclude users
      if (excludedUserIDs.isNotEmpty && excludedUserIDs.length <= 10) {
        query = query.where(FieldPath.documentId, whereNotIn: excludedUserIDs);
      }
      
      final snapshot = await query.get();
      final profiles = <UserProfile>[];
      
      for (final doc in snapshot.docs) {
        // Skip current user
        if (doc.id == currentUserId) continue;
        
        // Skip excluded users
        if (excludedUserIDs.contains(doc.id)) continue;
        
        try {
          final profile = UserProfile.fromFirestore(doc);
          profiles.add(profile);
        } catch (e) {
          print('❌ Error creating profile for user ${doc.id}: $e');
          print('❌ Document data: ${doc.data()}');
          // Skip this profile and continue
        }
      }
      
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
      
      print('✅ Networking profiles loaded: ${profiles.length} profiles');
      if (profiles.isEmpty) {
        print('⚠️ No networking profiles found. This might be due to:');
        print('   - No users matching criteria');
        print('   - Age/gender filters too restrictive');
        print('   - All users already blocked/passed/connected');
        print('   - Type mismatch errors in profile creation');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching networking connections: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConnectAction(UserProfile profile) async {
    // Move to next profile immediately (like iOS)
    if (_currentIndex < _profiles.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _currentIndex++;
      });
    }
    
    // Handle connection request in background (don't wait for result)
    _rsvpService.sendConnectionRequest(userId: profile.id).then((result) {
      print('✅ Connection result: $result');
      // Connection handled in background, no UI updates needed
    }).catchError((e) {
      print('❌ Connection error: $e');
      // Error handled in background, no UI updates needed
    });
  }

  Future<void> _handlePassAction() async {
    if (_currentIndex < _profiles.length) {
      final passedProfile = _profiles[_currentIndex];
      
      // Move to next profile immediately (like iOS)
      if (_currentIndex < _profiles.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        setState(() {
          _currentIndex++;
        });
      }
      
      // Record pass in background (don't wait for result)
      final currentUserId = _auth.currentUser!.uid;
      _db.collection('UserActions').doc(currentUserId).set({
        'passedUsers': FieldValue.arrayUnion([passedProfile.id])
      }, SetOptions(merge: true)).then((_) {
        print('✅ Pass recorded for user: ${passedProfile.id}');
      }).catchError((e) {
        print('❌ Error recording pass: $e');
      });
    }
  }
}
