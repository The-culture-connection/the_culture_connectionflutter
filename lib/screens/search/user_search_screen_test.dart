import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_profile.dart';

class UserSearchScreenTest extends StatefulWidget {
  const UserSearchScreenTest({super.key});

  @override
  State<UserSearchScreenTest> createState() => _UserSearchScreenTestState();
}

class _UserSearchScreenTestState extends State<UserSearchScreenTest> {
  final _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('UserSearchScreenTest: initState called');
    _loadTestUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTestUsers() {
    print('UserSearchScreenTest: _loadTestUsers called');
    setState(() {
      _isLoading = true;
    });
    print('UserSearchScreenTest: Set loading to true');

    // Simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      print('UserSearchScreenTest: Creating test users');
      if (mounted) {
        setState(() {
          _searchResults = [
            UserProfile(
              id: 'test1',
              userId: 'test1',
              fullName: 'Test User 1',
              age: 25,
              gender: 'Male',
              experienceLevel: 'Entry Level',
              skillsOffering: ['Programming', 'Design'],
              skillsSeeking: ['Marketing', 'Sales'],
              purposes: ['Networking'],
              photoURL: '',
              totalPoints: 100,
              blockedUsers: {},
              genderPreferences: 'Everyone',
              connectionPreference: 'Both',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              lastActive: DateTime.now(),
            ),
            UserProfile(
              id: 'test2',
              userId: 'test2',
              fullName: 'Test User 2',
              age: 30,
              gender: 'Female',
              experienceLevel: 'Mid Level',
              skillsOffering: ['Marketing', 'Sales'],
              skillsSeeking: ['Programming', 'Design'],
              purposes: ['Mentoring'],
              photoURL: '',
              totalPoints: 200,
              blockedUsers: {},
              genderPreferences: 'Everyone',
              connectionPreference: 'Both',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              lastActive: DateTime.now(),
            ),
          ];
          _isLoading = false;
        });
        print('UserSearchScreenTest: Test users created, loading set to false');
      } else {
        print('UserSearchScreenTest: Widget not mounted, skipping setState');
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    print('UserSearchScreenTest: _performSearch called with query: "$query"');
    
    setState(() {
      if (query.isEmpty) {
        _searchResults = _searchResults; // Show all
      } else {
        _searchResults = _searchResults.where((user) {
          return user.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
    print('UserSearchScreenTest: Search completed, ${_searchResults.length} results');
  }

  @override
  Widget build(BuildContext context) {
    print('UserSearchScreenTest: build() called');
    print('UserSearchScreenTest: _isLoading: $_isLoading');
    print('UserSearchScreenTest: _searchResults.length: ${_searchResults.length}');

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
          'Search People (TEST)',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
        ? (() {
            print('UserSearchScreenTest: Showing loading state');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.electricOrange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading test users...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          })()
        : (() {
            print('UserSearchScreenTest: Showing main content');
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.search, color: AppColors.electricOrange),
                      filled: true,
                      fillColor: const Color(0xFF1d1d1e),
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
                    onChanged: (_) => _performSearch(),
                  ),
                ),
                
                // Results
                Expanded(
                  child: _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          print('UserSearchScreenTest: Building user tile for ${user.fullName}');
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.deepPurple,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            subtitle: Text(
                              '${user.age} • ${user.gender} • ${user.experienceLevel}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            onTap: () {
                              print('UserSearchScreenTest: Tapped on ${user.fullName}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tapped on ${user.fullName}')),
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            );
          })(),
    );
  }
}
