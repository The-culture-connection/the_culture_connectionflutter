import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Profiles')
            .doc(user.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            _profileData = doc.data();
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No profile data found';
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile: $e';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7E00)),
              ),
            )
          : _profileData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Failed to load profile',
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E00),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d2d2e),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF685BC6), width: 1),
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFFF7E00),
                              backgroundImage: _profileData!['photoURL'] != null
                                  ? NetworkImage(_profileData!['photoURL'])
                                  : null,
                              child: _profileData!['photoURL'] == null
                                  ? Text(
                                      _getInitials(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // Name and Email
                            Text(
                              _profileData!['Full Name'] ?? 'No Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profileData!['email'] ?? 'No Email',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Profile Information
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d2d2e),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF685BC6), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Bio
                            if (_profileData!['Bio'] != null && _profileData!['Bio'].toString().isNotEmpty) ...[
                              _buildInfoRow('Bio', _profileData!['Bio'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Age
                            if (_profileData!['Age'] != null) ...[
                              _buildInfoRow('Age', _profileData!['Age'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Job Title
                            if (_profileData!['Job Title'] != null && _profileData!['Job Title'].toString().isNotEmpty) ...[
                              _buildInfoRow('Job Title', _profileData!['Job Title'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Industry
                            if (_profileData!['Industry'] != null && _profileData!['Industry'].toString().isNotEmpty) ...[
                              _buildInfoRow('Industry', _profileData!['Industry'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // University
                            if (_profileData!['University'] != null && _profileData!['University'].toString().isNotEmpty) ...[
                              _buildInfoRow('University', _profileData!['University'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Major
                            if (_profileData!['Major'] != null && _profileData!['Major'].toString().isNotEmpty) ...[
                              _buildInfoRow('Major', _profileData!['Major'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Experience Level
                            if (_profileData!['Experience Level'] != null && _profileData!['Experience Level'].toString().isNotEmpty) ...[
                              _buildInfoRow('Experience Level', _profileData!['Experience Level'].toString()),
                              const SizedBox(height: 12),
                            ],
                            
                            // Skills
                            if (_profileData!['Skills'] != null && _profileData!['Skills'].toString().isNotEmpty) ...[
                              const Text(
                                'Skills',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _profileData!['Skills'].toString().split(', ').map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF7E00),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      skill.trim(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7E00),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _handleSignOut,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign Out',
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
    );
  }

  String _getInitials() {
    final fullName = _profileData?['Full Name'] ?? '';
    if (fullName.isEmpty) return 'U';
    
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return names[0][0].toUpperCase();
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigation will be handled by ContentView auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
