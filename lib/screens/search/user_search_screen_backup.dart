import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_preview_screen.dart';

class UserSearchScreenBackup extends ConsumerStatefulWidget {
  const UserSearchScreenBackup({super.key});

  @override
  ConsumerState<UserSearchScreenBackup> createState() => _UserSearchScreenBackupState();
}

class _UserSearchScreenBackupState extends ConsumerState<UserSearchScreenBackup> {
  final _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('UserSearchScreenBackup: initState called');
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    print('UserSearchScreenBackup: _loadUsers called');
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    print('UserSearchScreenBackup: Set loading state to true');

    try {
      print('UserSearchScreenBackup: Getting firestore service...');
      final firestoreService = ref.read(firestoreServiceProvider);
      print('UserSearchScreenBackup: Firestore service obtained');
      
      print('UserSearchScreenBackup: Calling getAllUsers...');
      final users = await firestoreService.getAllUsers(limit: 20).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('UserSearchScreenBackup: Timeout occurred');
          throw Exception('Loading users timed out');
        },
      );
      print('UserSearchScreenBackup: Got ${users.length} users');
      
      if (mounted) {
        print('UserSearchScreenBackup: Widget is mounted, updating state');
        setState(() {
          _searchResults = users;
          _isLoading = false;
        });
        print('UserSearchScreenBackup: State updated successfully');
      } else {
        print('UserSearchScreenBackup: Widget not mounted, skipping setState');
      }
    } catch (e) {
      print('UserSearchScreenBackup: Error occurred: $e');
      print('UserSearchScreenBackup: Error type: ${e.runtimeType}');
      if (mounted) {
        print('UserSearchScreenBackup: Widget is mounted, setting error state');
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        print('UserSearchScreenBackup: Error state set');
      } else {
        print('UserSearchScreenBackup: Widget not mounted, cannot set error state');
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _searchResults = _searchResults; // Show all
      } else {
        _searchResults = _searchResults.where((user) {
          return user.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('UserSearchScreenBackup: build() called');
    print('UserSearchScreenBackup: _isLoading: $_isLoading');
    print('UserSearchScreenBackup: _hasError: $_hasError');
    print('UserSearchScreenBackup: _searchResults.length: ${_searchResults.length}');
    
    final currentUserId = ref.watch(currentUserIdProvider);
    print('UserSearchScreenBackup: currentUserId: $currentUserId');

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
        ? (() {
            print('UserSearchScreenBackup: Showing loading state');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.electricOrange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading users...',
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
        : _hasError
          ? (() {
              print('UserSearchScreenBackup: Showing error state');
              print('UserSearchScreenBackup: Error message: $_errorMessage');
              return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          })()
        : (() {
            print('UserSearchScreenBackup: Showing main content');
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
                          
                          // Don't show current user
                          if (user.userId == currentUserId) {
                            return const SizedBox.shrink();
                          }
                          
                          return _UserTile(user: user);
                        },
                      ),
                ),
              ],
            );
          })(),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfilePreviewScreen(userId: user.userId),
          ),
        );
      },
    );
  }
}
