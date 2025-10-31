import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../constants/app_colors.dart';

class ProfileCardView extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onConnect;
  final VoidCallback onPass;

  const ProfileCardView({
    super.key,
    required this.profile,
    required this.onConnect,
    required this.onPass,
  });

  @override
  State<ProfileCardView> createState() => _ProfileCardViewState();
}

class _ProfileCardViewState extends State<ProfileCardView> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Profile Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Photo
                _buildProfilePhoto(),
                
                // Profile Info Section
                _buildProfileInfo(),
                
                // Skills Offering Section
                if (widget.profile.skillsOffering.isNotEmpty) _buildSkillsOfferingSection(),
                
                // Skills Seeking Section
                if (widget.profile.skillsSeeking.isNotEmpty) _buildSkillsSeekingSection(),
                
                // Skills Section (legacy - if old format exists)
                if (widget.profile.skills.isNotEmpty && 
                    widget.profile.skillsOffering.isEmpty && 
                    widget.profile.skillsSeeking.isEmpty) _buildSkillsSection(),
                
                // Swipe Indicator
                _buildSwipeIndicator(),
              ],
            ),
          ),
          
          // Detailed Information Section
          if (_showDetails) _buildDetailedInfo(),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }


  Widget _buildProfilePhoto() {
    return Container(
      width: 300,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.3),
      ),
      child: widget.profile.photoURL.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.profile.photoURL,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderPhoto(),
              ),
            )
          : _buildPlaceholderPhoto(),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.profile.initials,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          Text(
            widget.profile.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          
          const SizedBox(height: 8),
          
          // Job Title and Age
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.profile.jobTitle.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    widget.profile.jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.profile.age > 0) ...[
                  const Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.profile.age}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ] else if (widget.profile.age > 0) ...[
                Text(
                  '${widget.profile.age}',
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
          
          // Experience Level and Industry
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.profile.experienceLevel.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    'Level: ${widget.profile.experienceLevel}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.profile.industry.isNotEmpty) ...[
                  const Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.profile.industry,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ] else if (widget.profile.industry.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    widget.profile.industry,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsOfferingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFFFF7E00),
              ),
              const SizedBox(width: 6),
              const Text(
                'Skills Offering',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.skillsOffering.take(8).map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF7E00).withOpacity(0.3),
                  width: 1,
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSeekingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.search,
                size: 18,
                color: Color(0xFFFF7E00),
              ),
              const SizedBox(width: 6),
              const Text(
                'Skills Seeking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.skillsSeeking.take(8).map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF7E00).withOpacity(0.3),
                  width: 1,
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skillsArray = widget.profile.skills
        .split(',')
        .map((skill) => skill.trim().replaceAll('"', '').replaceAll('(', '').replaceAll(')', ''))
        .where((skill) => skill.isNotEmpty)
        .take(6)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skillsArray.map((skill) => Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showDetails ? 'Hide Details' : 'View Details',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF7E00),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: const Color(0xFFFF7E00),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bio Section
          if (widget.profile.bio.isNotEmpty)
            _buildDetailSection(
              title: 'About',
              content: widget.profile.bio,
              icon: Icons.person,
            ),
          
          // Professional Information
          if (widget.profile.jobTitle.isNotEmpty || 
              widget.profile.industry.isNotEmpty || 
              widget.profile.experienceLevel.isNotEmpty)
            _buildDetailSection(
              title: 'Professional',
              content: _buildProfessionalInfo(),
              icon: Icons.work,
            ),
          
          // Education Information
          if (widget.profile.major.isNotEmpty)
            _buildDetailSection(
              title: 'Education',
              content: 'Major: ${widget.profile.major}',
              icon: Icons.school,
            ),
          
          // Interests and Hobbies
          if (widget.profile.interests.isNotEmpty)
            _buildDetailSection(
              title: 'Interests',
              content: _cleanText(widget.profile.interests),
              icon: Icons.favorite,
            ),
          
          // Personality Traits
          if (widget.profile.personalityTraits.isNotEmpty)
            _buildDetailSection(
              title: 'Personality',
              content: _cleanText(widget.profile.personalityTraits),
              icon: Icons.star,
            ),
          
          // Goals
          if (widget.profile.networkingGoal.isNotEmpty)
            _buildDetailSection(
              title: 'Goals',
              content: 'Networking: ${widget.profile.networkingGoal}',
              icon: Icons.flag,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFFFF7E00),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Pass Button
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPass,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pass',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Connect Button
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Next Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // This will be handled by the parent view
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7E00),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Next Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildProfessionalInfo() {
    final info = <String>[];
    if (widget.profile.jobTitle.isNotEmpty) info.add('Job: ${widget.profile.jobTitle}');
    if (widget.profile.industry.isNotEmpty) info.add('Industry: ${widget.profile.industry}');
    if (widget.profile.experienceLevel.isNotEmpty) info.add('Level: ${widget.profile.experienceLevel}');
    return info.join('\n');
  }

  String _cleanText(String text) {
    return text
        .replaceAll('"', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();
  }

}
