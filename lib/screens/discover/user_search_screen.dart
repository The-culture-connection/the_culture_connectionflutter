import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culture_connection/models/user_profile.dart';
import 'package:culture_connection/models/connection.dart';
import 'package:culture_connection/constants/skills_categories.dart';
import 'package:culture_connection/constants/experience_levels.dart';
import 'package:culture_connection/constants/app_colors.dart';
import 'package:culture_connection/services/firestore_service.dart';
import 'package:culture_connection/services/auth_service.dart';
import 'package:culture_connection/services/chat_service.dart';
import 'package:culture_connection/services/rsvp_service.dart';
import 'package:culture_connection/screens/chat/chat_detail_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final RSVPService _rsvpService = RSVPService();
  
  // Search state
  String _nameSearch = '';
  String _selectedSkillsOfferingCategory = '';
  String _selectedSkillsSeekingCategory = '';
  String _selectedExperienceLevel = '';
  String _selectedPurpose = '';
  String _nameLogic = 'AND';
  String _skillsOfferingLogic = 'AND';
  String _skillsSeekingLogic = 'AND';
  String _experienceLogic = 'AND';
  String _purposeLogic = 'AND';
  String _overallLogic = 'AND'; // Overall search logic
  bool _isSearching = false;
  List<UserProfile> _searchResults = [];
  bool _hasSearched = false;
  bool _isSearchFormExpanded = true;

  // Available options
  final List<String> _experienceLevels = ExperienceLevels.all;
  final List<String> _purposes = [
    'Looking to Hire',
    'Starting a business',
    'Looking to get hired',
    'Networking',
    'Looking to invest in a start up',
  ];
  final List<String> _searchLogicOptions = ['AND', 'OR'];
  
  // Helper method to determine which category a skill belongs to
  String? _getCategoryForSkill(String skill) {
    for (var entry in SkillsCategories.categories.entries) {
      if (entry.value.contains(skill)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search People',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.deepPurple, AppColors.electricOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Perfect Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search by name, skill categories (offering & seeking), experience level, or purpose',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Form (collapsible)
            if (_isSearchFormExpanded)
              _buildSearchForm()
            else
              _buildCollapsedSearchForm(),
            
            const SizedBox(height: 24),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSearching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SEARCH PEOPLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Results
            if (_hasSearched) _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Search
          _buildSearchField(
            label: 'Name',
            hint: 'Enter person\'s name',
            value: _nameSearch,
            onChanged: (value) => setState(() => _nameSearch = value),
            icon: Icons.person,
          ),
          
          const SizedBox(height: 20),
          
          // Skills Offering Category
          _buildDropdownField(
            label: 'Skills other users are offering',
            hint: 'What skills they can offer',
            value: _selectedSkillsOfferingCategory,
            items: SkillsCategories.getCategoryNames(),
            onChanged: (value) => setState(() => _selectedSkillsOfferingCategory = value ?? ''),
            icon: Icons.psychology,
          ),
          
          if (_selectedSkillsOfferingCategory.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLogicSelector('Skills Offering Logic', _skillsOfferingLogic, (value) => setState(() => _skillsOfferingLogic = value ?? 'AND')),
          ],
          
          const SizedBox(height: 20),
          
          // Skills Seeking Category
          _buildDropdownField(
            label: 'Skills other users are looking for',
            hint: 'What skills they are looking for',
            value: _selectedSkillsSeekingCategory,
            items: SkillsCategories.getCategoryNames(),
            onChanged: (value) => setState(() => _selectedSkillsSeekingCategory = value ?? ''),
            icon: Icons.search,
          ),
          
          if (_selectedSkillsSeekingCategory.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLogicSelector('Skills Seeking Logic', _skillsSeekingLogic, (value) => setState(() => _skillsSeekingLogic = value ?? 'AND')),
          ],
          
          const SizedBox(height: 20),
          
          // Overall Search Logic
          _buildDropdownField(
            label: 'Overall Search Logic',
            hint: 'How to combine all criteria',
            value: _overallLogic,
            items: _searchLogicOptions,
            onChanged: (value) => setState(() => _overallLogic = value ?? 'AND'),
            icon: Icons.tune,
          ),
          
          const SizedBox(height: 8),
          
          // Search Logic Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.electricOrange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _overallLogic == 'AND' 
                        ? 'All criteria must match (Name AND Skills AND Experience AND Purpose)'
                        : 'Any criteria can match (Name OR Skills OR Experience OR Purpose)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Experience Level
          _buildDropdownField(
            label: 'Experience Level',
            hint: 'Select experience level',
            value: _selectedExperienceLevel,
            items: _experienceLevels,
            onChanged: (value) => setState(() => _selectedExperienceLevel = value ?? ''),
            icon: Icons.trending_up,
          ),
          
          if (_selectedExperienceLevel.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLogicSelector('Experience Logic', _experienceLogic, (value) => setState(() => _experienceLogic = value ?? 'AND')),
          ],
          
          const SizedBox(height: 20),
          
          // Purpose
          _buildDropdownField(
            label: 'Purpose',
            hint: 'Select what they\'re looking for',
            value: _selectedPurpose,
            items: _purposes,
            onChanged: (value) => setState(() => _selectedPurpose = value ?? ''),
            icon: Icons.flag,
          ),
          
          if (_selectedPurpose.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLogicSelector('Purpose Logic', _purposeLogic, (value) => setState(() => _purposeLogic = value ?? 'AND')),
          ],
          
          const SizedBox(height: 16),
          
          // Clear Filters Button
          if (_nameSearch.isNotEmpty || _selectedSkillsOfferingCategory.isNotEmpty || _selectedSkillsSeekingCategory.isNotEmpty || _selectedExperienceLevel.isNotEmpty || _selectedPurpose.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, color: AppColors.electricOrange),
              label: const Text(
                'Clear All Filters',
                style: TextStyle(color: AppColors.electricOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: AppColors.electricOrange),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.electricOrange, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: AppColors.electricOrange),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: const Color(0xFF1d1d1e),
            style: const TextStyle(color: Colors.white),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${_searchResults.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        ..._searchResults.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Profile Photo
          CircleAvatar(
            radius: 30,
            backgroundImage: user.photoURL.isNotEmpty
                ? NetworkImage(user.photoURL)
                : null,
            child: user.photoURL.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                
                if (user.experienceLevel.isNotEmpty) ...[
                  Text(
                    user.experienceLevel,
                    style: TextStyle(
                      color: AppColors.electricOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                if (user.skillsOffering.isNotEmpty) ...[
                  Text(
                    'Offers: ${user.skillsOffering.take(3).join(', ')}${user.skillsOffering.length > 3 ? '...' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                ],
                
                if (user.skillsSeeking.isNotEmpty) ...[
                  Text(
                    'Seeks: ${user.skillsSeeking.take(3).join(', ')}${user.skillsSeeking.length > 3 ? '...' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                ],
                
                if (user.purposes.isNotEmpty) ...[
                  Text(
                    'Purpose: ${user.purposes.take(2).join(', ')}${user.purposes.length > 2 ? '...' : ''}',
                    style: TextStyle(
                      color: AppColors.electricOrange.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          
          // Connect Button
          ElevatedButton(
            onPressed: () => _connectWithUser(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearchForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Search summary
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.electricOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildSearchSummary(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isSearchFormExpanded = true),
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.electricOrange,
                  size: 20,
                ),
                tooltip: 'Edit search criteria',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Search Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.electricOrange,
                    side: const BorderSide(color: AppColors.electricOrange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildSearchSummary() {
    List<String> criteria = [];
    
    if (_nameSearch.isNotEmpty) {
      criteria.add('Name: "$_nameSearch"');
    }
    if (_selectedSkillsOfferingCategory.isNotEmpty) {
      criteria.add('Offering: ${_selectedSkillsOfferingCategory.replaceAll('🔧', '').replaceAll('📢', '').replaceAll('💼', '').replaceAll('🧩', '').replaceAll('💡', '').replaceAll('🎨', '').replaceAll('🧘🏽‍♀️', '').replaceAll('🏫', '').replaceAll('🏠', '').trim()}');
    }
    if (_selectedSkillsSeekingCategory.isNotEmpty) {
      criteria.add('Seeking: ${_selectedSkillsSeekingCategory.replaceAll('🔧', '').replaceAll('📢', '').replaceAll('💼', '').replaceAll('🧩', '').replaceAll('💡', '').replaceAll('🎨', '').replaceAll('🧘🏽‍♀️', '').replaceAll('🏫', '').replaceAll('🏠', '').trim()}');
    }
    if (_selectedExperienceLevel.isNotEmpty) {
      criteria.add('Level: $_selectedExperienceLevel');
    }
    if (_selectedPurpose.isNotEmpty) {
      criteria.add('Purpose: $_selectedPurpose');
    }
    
    if (criteria.isEmpty) {
      return 'No search criteria set';
    }
    
    return 'Searching: ${criteria.join(', ')}';
  }

  Widget _buildLogicSelector(String label, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            color: AppColors.electricOrange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
              dropdownColor: const Color(0xFF1d1d1e),
              items: _searchLogicOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _nameSearch = '';
      _selectedSkillsOfferingCategory = '';
      _selectedSkillsSeekingCategory = '';
      _selectedExperienceLevel = '';
      _selectedPurpose = '';
      _nameLogic = 'AND';
      _skillsOfferingLogic = 'AND';
      _skillsSeekingLogic = 'AND';
      _experienceLogic = 'AND';
      _purposeLogic = 'AND';
      _overallLogic = 'AND';
      _searchResults = [];
      _hasSearched = false;
      _isSearchFormExpanded = true; // Expand form when clearing
    });
  }

  Future<void> _performSearch() async {
    if (_nameSearch.isEmpty && _selectedSkillsOfferingCategory.isEmpty && _selectedSkillsSeekingCategory.isEmpty && _selectedExperienceLevel.isEmpty && _selectedPurpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one search criteria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Get all user profiles
      final profiles = await _firestoreService.getAllUsers();
      
      // Filter profiles based on search criteria
      List<UserProfile> matches = profiles.where((profile) {
        List<bool> criteriaMatches = [];
        
        // Name search
        if (_nameSearch.isNotEmpty) {
          criteriaMatches.add(profile.fullName.toLowerCase().contains(_nameSearch.toLowerCase()));
        }
        
        // Skills Offering search
        if (_selectedSkillsOfferingCategory.isNotEmpty) {
          final categorySkills = SkillsCategories.getSkillsForCategory(_selectedSkillsOfferingCategory);
          final hasOfferingSkill = profile.skillsOffering.any((skill) => categorySkills.contains(skill));
          criteriaMatches.add(hasOfferingSkill);
        }
        
        // Skills Seeking search
        if (_selectedSkillsSeekingCategory.isNotEmpty) {
          final categorySkills = SkillsCategories.getSkillsForCategory(_selectedSkillsSeekingCategory);
          final hasSeekingSkill = profile.skillsSeeking.any((skill) => categorySkills.contains(skill));
          criteriaMatches.add(hasSeekingSkill);
        }
        
        // Experience level search
        if (_selectedExperienceLevel.isNotEmpty) {
          criteriaMatches.add(profile.experienceLevel.toLowerCase().contains(_selectedExperienceLevel.toLowerCase()));
        }
        
        // Purpose search
        if (_selectedPurpose.isNotEmpty) {
          criteriaMatches.add(profile.purposes.contains(_selectedPurpose));
        }
        
        // Apply overall search logic
        if (criteriaMatches.isEmpty) return true; // No criteria = show all
        
        if (_overallLogic == 'AND') {
          return criteriaMatches.every((match) => match);
        } else { // OR logic
          return criteriaMatches.any((match) => match);
        }
      }).toList();
      
      setState(() {
        _searchResults = matches;
        _hasSearched = true;
        _isSearchFormExpanded = false; // Collapse form after search
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _connectWithUser(UserProfile user) async {
    try {
      // Get current user ID from auth service
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to connect with users'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      
      // Use RSVPService for consistent connection handling
      final result = await _rsvpService.sendConnectionRequest(userId: user.id);
      
      if (mounted) {
        if (result['success'] == true) {
          if (result['isMatch'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 It\'s a Match! You are now connected!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection request sent!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: ${result['message'] ?? 'Unknown error'}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send connection request: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}