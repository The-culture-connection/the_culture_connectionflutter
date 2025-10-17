import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/experience_levels.dart';
import '../../constants/skills_categories.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_preview_screen.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedExperienceLevel;
  final Set<String> _selectedSkillsOffering = {};
  final Set<String> _selectedSkillsSeeking = {};
  
  List<UserProfile> _searchResults = [];
  List<UserProfile> _allUsers = [];
  bool _isLoading = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final users = await firestoreService.getAllUsers(limit: 100);
      
      setState(() {
        _allUsers = users;
        _searchResults = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      _searchResults = _allUsers.where((user) {
        // Name filter
        bool matchesName = true;
        if (query.isNotEmpty) {
          matchesName = user.fullName.toLowerCase().contains(query);
        }
        
        // Experience level filter
        bool matchesExperience = true;
        if (_selectedExperienceLevel != null) {
          matchesExperience = user.experienceLevel == _selectedExperienceLevel;
        }
        
        // Skills offering filter
        bool matchesSkillsOffering = true;
        if (_selectedSkillsOffering.isNotEmpty) {
          matchesSkillsOffering = user.skillsOffering.any(
            (skill) => _selectedSkillsOffering.contains(skill),
          );
        }
        
        // Skills seeking filter
        bool matchesSkillsSeeking = true;
        if (_selectedSkillsSeeking.isNotEmpty) {
          matchesSkillsSeeking = user.skillsSeeking.any(
            (skill) => _selectedSkillsSeeking.contains(skill),
          );
        }
        
        return matchesName && 
               matchesExperience && 
               matchesSkillsOffering && 
               matchesSkillsSeeking;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedExperienceLevel = null;
      _selectedSkillsOffering.clear();
      _selectedSkillsSeeking.clear();
      _searchResults = _allUsers;
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_searchController.text.isNotEmpty) count++;
    if (_selectedExperienceLevel != null) count++;
    if (_selectedSkillsOffering.isNotEmpty) count++;
    if (_selectedSkillsSeeking.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        actions: [
          if (_activeFilterCount > 0)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch();
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: _activeFilterCount > 0 
                        ? AppColors.electricOrange 
                        : Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                ),
              ],
            ),
          ),
          
          // Filter chips
          if (_activeFilterCount > 0)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedExperienceLevel != null)
                    _buildFilterChip(
                      _selectedExperienceLevel!,
                      () {
                        setState(() {
                          _selectedExperienceLevel = null;
                          _performSearch();
                        });
                      },
                    ),
                  if (_selectedSkillsOffering.isNotEmpty)
                    _buildFilterChip(
                      '${_selectedSkillsOffering.length} skills offering',
                      () {
                        setState(() {
                          _selectedSkillsOffering.clear();
                          _performSearch();
                        });
                      },
                    ),
                  if (_selectedSkillsSeeking.isNotEmpty)
                    _buildFilterChip(
                      '${_selectedSkillsSeeking.length} skills seeking',
                      () {
                        setState(() {
                          _selectedSkillsSeeking.clear();
                          _performSearch();
                        });
                      },
                    ),
                ],
              ),
            ),
          
          // Filters panel
          if (_showFilters)
            Container(
              color: const Color(0xFF2A2A2A),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Experience Level
                  _buildFilterSection(
                    'Experience Level',
                    DropdownButtonFormField<String>(
                      value: _selectedExperienceLevel,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1d1d1e),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      hint: const Text('Select level', style: TextStyle(color: Colors.grey)),
                      items: ExperienceLevels.all.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperienceLevel = value;
                          _performSearch();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Skills buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSkillsDialog(true),
                          icon: const Icon(Icons.lightbulb_outline),
                          label: Text(
                            'Skills Offering (${_selectedSkillsOffering.length})',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: _selectedSkillsOffering.isNotEmpty
                                  ? AppColors.electricOrange
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSkillsDialog(false),
                          icon: const Icon(Icons.search),
                          label: Text(
                            'Skills Seeking (${_selectedSkillsSeeking.length})',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: _selectedSkillsSeeking.isNotEmpty
                                  ? AppColors.electricOrange
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Results count
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '${_searchResults.length} ${_searchResults.length == 1 ? 'user' : 'users'} found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Results list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.electricOrange),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          
                          // Don't show current user
                          if (user.userId == currentUserId) {
                            return const SizedBox.shrink();
                          }
                          
                          return _UserTile(user: user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: AppColors.electricOrange,
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showSkillsDialog(bool isOffering) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedSkills = isOffering 
                ? _selectedSkillsOffering 
                : _selectedSkillsSeeking;
            
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: Text(
                isOffering ? 'Skills Offering' : 'Skills Seeking',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: SkillsCategories.categories.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: entry.value.map((skill) {
                        final isSelected = selectedSkills.contains(skill);
                        return CheckboxListTile(
                          title: Text(
                            skill,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: isSelected,
                          activeColor: AppColors.electricOrange,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedSkills.add(skill);
                              } else {
                                selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _performSearch());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricOrange,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserTile extends ConsumerWidget {
  final UserProfile user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.deepPurple,
        backgroundImage: user.photoURL != null
            ? NetworkImage(user.photoURL!)
            : null,
        child: user.photoURL == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.age} • ${user.gender} • ${user.experienceLevel}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          if (user.skillsOffering.isNotEmpty)
            Text(
              user.skillsOffering.take(2).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.electricOrange.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 16,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfilePreviewScreen(userId: user.userId),
          ),
        );
      },
    );
  }
}
