import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';
import '../models/chat_room.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const OtherUserProfileScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserProfile();
  }

  Future<void> _fetchOtherUserProfile() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not logged in';
            _isLoading = false;
          });
        }
        return;
      }

      final otherParticipantId = widget.chatRoom.participants
          .firstWhere((id) => id != currentUserId);

      final doc = await _db.collection('Profiles').doc(otherParticipantId).get();
      
      if (!doc.exists) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Profile not found';
            _isLoading = false;
          });
        }
        return;
      }

      final data = doc.data()!;
      data['UserId'] = doc.id;
      
      if (mounted) {
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFFFF7E00),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7E00),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _userProfile != null
                  ? _buildProfileContent()
                  : const Center(
                      child: Text(
                        'Profile not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
    );
  }

  Widget _buildProfileContent() {
    final profile = _userProfile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(profile),
          const SizedBox(height: 20),
          
          // Bio Section
          if (profile.bio.isNotEmpty) ...[
            _buildSection(
              title: 'About',
              child: Text(
                profile.bio,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Professional Info
          if (profile.jobTitle.isNotEmpty || profile.industry.isNotEmpty) ...[
            _buildSection(
              title: 'Professional',
              child: Column(
                children: [
                  if (profile.jobTitle.isNotEmpty)
                    _buildInfoRow('Job:', profile.jobTitle),
                  if (profile.industry.isNotEmpty)
                    _buildInfoRow('Industry:', profile.industry),
                  if (profile.experienceLevel.isNotEmpty)
                    _buildInfoRow('Level:', profile.experienceLevel),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Skills Section
          if (profile.skills.isNotEmpty) ...[
            _buildSection(
              title: 'Skills',
              child: _buildSkillsGrid(profile.skills),
            ),
            const SizedBox(height: 20),
          ],
          
          // Interests Section
          if (profile.interests.isNotEmpty) ...[
            _buildSection(
              title: 'Interests',
              child: Text(
                profile.interests,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Goals Section
          if (profile.networkinggoal.isNotEmpty) ...[
            _buildSection(
              title: 'Goals',
              child: Text(
                profile.networkinggoal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF7E00),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: profile.photoURL.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profile.photoURL,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            profile.fullname,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Matches-StrikeRough',
            ),
          ),
          const SizedBox(height: 16),
          
          // Basic Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (profile.age > 0) ...[
                _buildInfoColumn('Age', '${profile.age}'),
                const SizedBox(width: 20),
              ],
              if (profile.jobTitle.isNotEmpty) ...[
                _buildInfoColumn('Job Title', profile.jobTitle),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Matches-StrikeRough',
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid(String skills) {
    final skillsList = skills
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .take(6)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skillsList.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF7E00).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          skill,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      )).toList(),
    );
  }
}


