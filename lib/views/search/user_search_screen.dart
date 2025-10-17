import 'package:flutter/material.dart';
import 'package:culture_connection/models/user_profile.dart';
import 'package:culture_connection/services/firestore_service.dart';
import 'package:culture_connection/constants/app_constants.dart';
import 'package:culture_connection/constants/skills_categories.dart';
import 'package:culture_connection/widgets/user_card.dart';

/// Enhanced user search screen with multiple filters
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  String? _selectedExperienceLevel;
  List<String> _selectedSkillsOffering = [];
  List<String> _selectedSkillsSeeking = [];
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      final results = await _firestoreService.searchUsersWithFilters(
        name: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        experienceLevel: _selectedExperienceLevel,
        skillsOffering: _selectedSkillsOffering.isNotEmpty
            ? _selectedSkillsOffering
            : null,
        skillsSeeking: _selectedSkillsSeeking.isNotEmpty
            ? _selectedSkillsSeeking
            : null,
      );

      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedExperienceLevel = null;
      _selectedSkillsOffering.clear();
      _selectedSkillsSeeking.clear();
      _searchResults.clear();
    });
  }

  Future<void> _showSkillsSelector({
    required String title,
    required List<String> selectedSkills,
    required Function(List<String>) onSelected,
  }) async {
    List<String> tempSelected = List.from(selectedSkills);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView(
              children: SkillsCategories.allCategories.entries.map((category) {
                return ExpansionTile(
                  title: Text(
                    category.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: category.value.map((skill) {
                    final isSelected = tempSelected.contains(skill);
                    return CheckboxListTile(
                      title: Text(skill),
                      value: isSelected,
                      dense: true,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelected.add(skill);
                          } else {
                            tempSelected.remove(skill);
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
                onSelected(tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedExperienceLevel != null) count++;
    if (_selectedSkillsOffering.isNotEmpty) count++;
    if (_selectedSkillsSeeking.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$_activeFiltersCount'),
              isLabelVisible: _activeFiltersCount > 0,
              child: Icon(
                _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          if (_activeFiltersCount > 0 || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) => _performSearch(),
            ),
          ),

          // Filters Panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Experience Level Filter
                  DropdownButtonFormField<String>(
                    value: _selectedExperienceLevel,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Levels'),
                      ),
                      ...AppConstants.experienceLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedExperienceLevel = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Skills Offering Filter
                  OutlinedButton.icon(
                    onPressed: () {
                      _showSkillsSelector(
                        title: 'Filter by Skills Offering',
                        selectedSkills: _selectedSkillsOffering,
                        onSelected: (skills) {
                          setState(() => _selectedSkillsOffering = skills);
                        },
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(
                      _selectedSkillsOffering.isEmpty
                          ? 'Filter by Skills Offering'
                          : 'Skills Offering (${_selectedSkillsOffering.length})',
                    ),
                  ),
                  if (_selectedSkillsOffering.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkillsOffering.map((skill) {
                          return Chip(
                            label: Text(skill),
                            onDeleted: () {
                              setState(() {
                                _selectedSkillsOffering.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Skills Seeking Filter
                  OutlinedButton.icon(
                    onPressed: () {
                      _showSkillsSelector(
                        title: 'Filter by Skills Seeking',
                        selectedSkills: _selectedSkillsSeeking,
                        onSelected: (skills) {
                          setState(() => _selectedSkillsSeeking = skills);
                        },
                      );
                    },
                    icon: const Icon(Icons.search_outlined),
                    label: Text(
                      _selectedSkillsSeeking.isEmpty
                          ? 'Filter by Skills Seeking'
                          : 'Skills Seeking (${_selectedSkillsSeeking.length})',
                    ),
                  ),
                  if (_selectedSkillsSeeking.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkillsSeeking.map((skill) {
                          return Chip(
                            label: Text(skill),
                            onDeleted: () {
                              setState(() {
                                _selectedSkillsSeeking.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

          // Search Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _performSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ),

          const Divider(height: 1),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search filters',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          return UserCard(
                            profile: _searchResults[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
