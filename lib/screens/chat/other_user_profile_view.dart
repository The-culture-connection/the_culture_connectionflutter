import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_room.dart';
import '../../models/user_profile.dart';

class OtherUserProfileView extends StatefulWidget {
  final ChatRoom chatRoom;

  const OtherUserProfileView({
    super.key,
    required this.chatRoom,
  });

  @override
  State<OtherUserProfileView> createState() => _OtherUserProfileViewState();
}

class _OtherUserProfileViewState extends State<OtherUserProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF7E00),
            ),
            SizedBox(height: 16),
            Text(
              "Loading Profile...",
              style: TextStyle(color: Colors.white),
            ),
          ],
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
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Error: $_errorMessage",
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(
        child: Text(
          "Profile not found",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _userProfile!.photoURL.isNotEmpty
                      ? NetworkImage(_userProfile!.photoURL)
                      : null,
                  child: _userProfile!.photoURL.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 60,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Name and Basic Info
                Text(
                  _userProfile!.fullName,
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_userProfile!.age > 0) ...[
                      Column(
                        children: [
                          const Text(
                            "Age",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_userProfile!.age}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (_userProfile!.jobTitle.isNotEmpty) ...[
                      Column(
                        children: [
                          const Text(
                            "Job Title",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userProfile!.jobTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Bio Section
          if (_userProfile!.bio.isNotEmpty) ...[
            _buildInfoCard(
              title: "About",
              content: _userProfile!.bio,
            ),
            const SizedBox(height: 20),
          ],
          
          // Professional Info
          if (_userProfile!.jobTitle.isNotEmpty || _userProfile!.industry.isNotEmpty) ...[
            _buildInfoCard(
              title: "Professional",
              children: [
                if (_userProfile!.jobTitle.isNotEmpty)
                  _buildInfoRow("Job:", _userProfile!.jobTitle),
                if (_userProfile!.industry.isNotEmpty)
                  _buildInfoRow("Industry:", _userProfile!.industry),
                if (_userProfile!.experienceLevel.isNotEmpty)
                  _buildInfoRow("Level:", _userProfile!.experienceLevel),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Skills Section
          if (_userProfile!.skills.isNotEmpty) ...[
            _buildInfoCard(
              title: "Skills",
              children: [
                _buildSkillsGrid(_userProfile!.skills),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Interests Section
          if (_userProfile!.interests.isNotEmpty) ...[
            _buildInfoCard(
              title: "Interests",
              content: _userProfile!.interests,
            ),
            const SizedBox(height: 20),
          ],
          
          // Goals Section
          if (_userProfile!.networkingGoal.isNotEmpty) ...[
            _buildInfoCard(
              title: "Goals",
              content: _userProfile!.networkingGoal,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Matches-StrikeRough',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
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
      children: skillsList.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7E00).withOpacity(0.2),
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
        );
      }).toList(),
    );
  }

  Future<void> _fetchOtherUserProfile() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          _errorMessage = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      final otherParticipantId = widget.chatRoom.participants
          .firstWhere((id) => id != currentUserId);

      final doc = await _db.collection("Profiles").doc(otherParticipantId).get();
      
      if (!doc.exists) {
        setState(() {
          _errorMessage = "Profile not found";
          _isLoading = false;
        });
        return;
      }

      final profile = UserProfile.fromFirestore(doc);
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
