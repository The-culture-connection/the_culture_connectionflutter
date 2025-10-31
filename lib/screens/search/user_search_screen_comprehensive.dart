import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/experience_levels.dart';
import '../../constants/skills_categories.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_preview_screen.dart';

class UserSearchScreenComprehensive extends ConsumerStatefulWidget {
  const UserSearchScreenComprehensive({super.key});

  @override
  ConsumerState<UserSearchScreenComprehensive> createState() => _UserSearchScreenComprehensiveState();
}

class _UserSearchScreenComprehensiveState extends ConsumerState<UserSearchScreenComprehensive> {
  final _searchController = TextEditingController();
  
  // Search criteria
  String _nameSearch = '';
  String _selectedSkillsOfferingCategory = '';
  String _selectedSkillsSeekingCategory = '';
  String _selectedExperienceLevel = '';
  String _selectedJobLevel = '';
  String _selectedPurpose = '';
  
  // Logic options
  String _overallLogic = 'AND';
  String _skillsOfferingLogic = 'AND';
  String _skillsSeekingLogic = 'AND';
  String _experienceLogic = 'AND';
  String _jobLevelLogic = 'AND';
  String _purposeLogic = 'AND';
  
  // State
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isSearchFormExpanded = true;

  // Available options
  final List<String> _experienceLevels = ExperienceLevels.all;
  final List<String> _jobLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Executive Level',
    'C-Level',
  ];
  final List<String> _purposes = [
    'Looking to Hire',
    'Starting a business',
    'Looking to get hired',
    'Networking',
    'Looking to invest in a start up',
  ];
  final List<String> _searchLogicOptions = ['AND', 'OR'];

  @override
  void initState() {
    super.initState();
    print('UserSearchScreenComprehensive: initState called');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('UserSearchScreenComprehensive: build() called');
    print('UserSearchScreenComprehensive: _isLoading: $_isLoading');
    print('UserSearchScreenComprehensive: _hasSearched: $_hasSearched');
    print('UserSearchScreenComprehensive: _searchResults.length: ${_searchResults.length}');
    
    final currentUserId = ref.watch(currentUserIdProvider);
    print('UserSearchScreenComprehensive: currentUserId: $currentUserId');

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
      body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.electricOrange,
                ),
                SizedBox(height: 16),
                Text(
                  'Searching users...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      const Text(
                        'Search by name, skills, experience, job level, or purpose',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Search Form
                if (_isSearchFormExpanded)
                  Flexible(child: _buildSearchForm())
                else
                  _buildCollapsedSearchForm(),
                
                const SizedBox(height: 24),
                
                // Search Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
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
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Name Search
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Full Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _nameSearch = value.trim();
                    print('UserSearchScreenComprehensive: _nameSearch updated to: "$_nameSearch"');
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter person\'s full name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.person, color: AppColors.electricOrange),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Skills Offering Category
          _buildDropdownField(
            label: 'Skills Offering',
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
            label: 'Skills Seeking',
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
          
          // Job Level
          _buildDropdownField(
            label: 'Job Level',
            hint: 'Select job level',
            value: _selectedJobLevel,
            items: _jobLevels,
            onChanged: (value) => setState(() => _selectedJobLevel = value ?? ''),
            icon: Icons.work,
          ),
          
          if (_selectedJobLevel.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLogicSelector('Job Level Logic', _jobLevelLogic, (value) => setState(() => _jobLevelLogic = value ?? 'AND')),
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
                        ? 'All criteria must match (Name AND Skills AND Experience AND Job Level AND Purpose)'
                        : 'Any criteria can match (Name OR Skills OR Experience OR Job Level OR Purpose)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clear Filters Button
          if (_nameSearch.isNotEmpty || _selectedSkillsOfferingCategory.isNotEmpty || _selectedSkillsSeekingCategory.isNotEmpty || _selectedExperienceLevel.isNotEmpty || _selectedJobLevel.isNotEmpty || _selectedPurpose.isNotEmpty)
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
          controller: _searchController,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Use the field full-width; no wrapping Row
        DropdownButtonFormField<String>(
          isExpanded: true, // <-- critical to avoid overflows
          value: value.isEmpty ? null : value,
          items: items.map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(
              e,
              overflow: TextOverflow.ellipsis, // long text won't overflow
              maxLines: 1,
            ),
          )).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down), // trailing chevron
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1D1D1E),
            prefixIcon: Icon(icon, color: const Color(0xFFFF7E00), size: 18),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7E00), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7E00), width: 2),
            ),
          ),
        ),
      ],
    );
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
                  maxLines: 3,
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
      criteria.add('Experience: $_selectedExperienceLevel');
    }
    if (_selectedJobLevel.isNotEmpty) {
      criteria.add('Job Level: $_selectedJobLevel');
    }
    if (_selectedPurpose.isNotEmpty) {
      criteria.add('Purpose: $_selectedPurpose');
    }
    
    if (criteria.isEmpty) {
      return 'No search criteria set';
    }
    
    return 'Searching: ${criteria.join(', ')}';
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
          
          ElevatedButton(
            onPressed: () => _viewUserProfile(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'View Profile',
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

  void _clearFilters() {
    setState(() {
      _nameSearch = '';
      _searchController.clear();
      _selectedSkillsOfferingCategory = '';
      _selectedSkillsSeekingCategory = '';
      _selectedExperienceLevel = '';
      _selectedJobLevel = '';
      _selectedPurpose = '';
      _overallLogic = 'AND';
      _skillsOfferingLogic = 'AND';
      _skillsSeekingLogic = 'AND';
      _experienceLogic = 'AND';
      _jobLevelLogic = 'AND';
      _purposeLogic = 'AND';
      _searchResults = [];
      _hasSearched = false;
      _isSearchFormExpanded = true;
    });
  }

  Future<void> _performSearch() async {
    print('UserSearchScreenComprehensive: _performSearch called');
    
    // Sync controller value to _nameSearch in case it wasn't updated
    _nameSearch = _searchController.text.trim();
    print('UserSearchScreenComprehensive: Search criteria - Name: "$_nameSearch", Skills Offering: "$_selectedSkillsOfferingCategory", Skills Seeking: "$_selectedSkillsSeekingCategory", Experience: "$_selectedExperienceLevel", Job Level: "$_selectedJobLevel", Purpose: "$_selectedPurpose"');
    
    if (_nameSearch.isEmpty && _selectedSkillsOfferingCategory.isEmpty && _selectedSkillsSeekingCategory.isEmpty && _selectedExperienceLevel.isEmpty && _selectedJobLevel.isEmpty && _selectedPurpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one search criteria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    print('UserSearchScreenComprehensive: Set loading to true');

    try {
      print('UserSearchScreenComprehensive: Getting firestore service...');
      final firestoreService = ref.read(firestoreServiceProvider);
      print('UserSearchScreenComprehensive: Firestore service obtained');
      
      print('UserSearchScreenComprehensive: Calling getAllUsers...');
      // Use Firestore query for name search if only name is provided, otherwise get all users
      List<UserProfile> profiles;
      if (_nameSearch.isNotEmpty && 
          _selectedSkillsOfferingCategory.isEmpty && 
          _selectedSkillsSeekingCategory.isEmpty && 
          _selectedExperienceLevel.isEmpty && 
          _selectedJobLevel.isEmpty && 
          _selectedPurpose.isEmpty) {
        // Use Firestore name search for better performance
        print('UserSearchScreenComprehensive: Using Firestore name search query');
        final stream = firestoreService.searchUsersByName(_nameSearch);
        final snapshot = await stream.first.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('UserSearchScreenComprehensive: Timeout occurred');
            throw Exception('Loading users timed out');
          },
        );
        profiles = snapshot;
        print('UserSearchScreenComprehensive: Got ${profiles.length} users from name search');
      } else {
        // For complex searches, get all users (no limit or very high limit)
        profiles = await firestoreService.getAllUsers(limit: 10000).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('UserSearchScreenComprehensive: Timeout occurred');
            throw Exception('Loading users timed out');
          },
        );
        print('UserSearchScreenComprehensive: Got ${profiles.length} users');
      }
      
      // Filter profiles based on search criteria
      List<UserProfile> matches = profiles.where((profile) {
        List<bool> criteriaMatches = [];
        
        // Name search
        if (_nameSearch.isNotEmpty) {
          final nameMatch = profile.fullName.toLowerCase().contains(_nameSearch.toLowerCase());
          criteriaMatches.add(nameMatch);
          print('UserSearchScreenComprehensive: Name match for ${profile.fullName}: $nameMatch');
        }
        
        // Skills Offering search - map main category to subcategories
        if (_selectedSkillsOfferingCategory.isNotEmpty) {
          final categorySkills = SkillsCategories.getSkillsForCategory(_selectedSkillsOfferingCategory);
          final hasOfferingSkill = profile.skillsOffering.any((skill) => categorySkills.contains(skill));
          criteriaMatches.add(hasOfferingSkill);
          print('UserSearchScreenComprehensive: Skills offering match for ${profile.fullName}: $hasOfferingSkill');
        }
        
        // Skills Seeking search - map main category to subcategories
        if (_selectedSkillsSeekingCategory.isNotEmpty) {
          final categorySkills = SkillsCategories.getSkillsForCategory(_selectedSkillsSeekingCategory);
          final hasSeekingSkill = profile.skillsSeeking.any((skill) => categorySkills.contains(skill));
          criteriaMatches.add(hasSeekingSkill);
          print('UserSearchScreenComprehensive: Skills seeking match for ${profile.fullName}: $hasSeekingSkill');
        }
        
        // Experience level search
        if (_selectedExperienceLevel.isNotEmpty) {
          final expMatch = profile.experienceLevel.toLowerCase().contains(_selectedExperienceLevel.toLowerCase());
          criteriaMatches.add(expMatch);
          print('UserSearchScreenComprehensive: Experience match for ${profile.fullName}: $expMatch');
        }
        
        // Job level search (if available in profile)
        if (_selectedJobLevel.isNotEmpty) {
          // Note: Job level might not be in UserProfile model, this is a placeholder
          final jobMatch = profile.jobLevel.toLowerCase().contains(_selectedJobLevel.toLowerCase());
          criteriaMatches.add(jobMatch);
          print('UserSearchScreenComprehensive: Job level match for ${profile.fullName}: $jobMatch');
        }
        
        // Purpose search
        if (_selectedPurpose.isNotEmpty) {
          final purposeMatch = profile.purposes.contains(_selectedPurpose);
          criteriaMatches.add(purposeMatch);
          print('UserSearchScreenComprehensive: Purpose match for ${profile.fullName}: $purposeMatch');
        }
        
        // Apply overall search logic
        if (criteriaMatches.isEmpty) return true; // No criteria = show all
        
        bool result;
        if (_overallLogic == 'AND') {
          result = criteriaMatches.every((match) => match);
        } else { // OR logic
          result = criteriaMatches.any((match) => match);
        }
        
        print('UserSearchScreenComprehensive: Overall match for ${profile.fullName}: $result');
        return result;
      }).toList();
      
      print('UserSearchScreenComprehensive: Found ${matches.length} matches');
      
      if (mounted) {
        setState(() {
          _searchResults = matches;
          _hasSearched = true;
          _isSearchFormExpanded = false;
          _isLoading = false;
        });
        print('UserSearchScreenComprehensive: State updated successfully');
      }
      
    } catch (e) {
      print('UserSearchScreenComprehensive: Error occurred: $e');
      print('UserSearchScreenComprehensive: Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewUserProfile(UserProfile user) {
    print('UserSearchScreenComprehensive: Viewing profile for ${user.fullName}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePreviewScreen(userId: user.userId),
      ),
    );
  }
}
