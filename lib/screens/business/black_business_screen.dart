import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/business.dart';
import '../../services/firestore_service.dart';
import 'create_business_screen.dart';
import 'business_detail_screen.dart';

class BlackBusinessScreen extends ConsumerStatefulWidget {
  const BlackBusinessScreen({super.key});

  @override
  ConsumerState<BlackBusinessScreen> createState() => _BlackBusinessScreenState();
}

class _BlackBusinessScreenState extends ConsumerState<BlackBusinessScreen> {
  String? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Therapy & Wellness',
    'Financial Services',
    'Retail & Fashion',
    'Food & Beverage',
    'Technology',
    'Legal Services',
    'Real Estate',
    'Education',
    'Beauty & Personal Care',
    'Arts & Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'GREEN BOOK',
          style: TextStyle(
            fontFamily: 'InterTight',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1d1d1e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: AppColors.electricOrange),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateBusinessScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: AppColors.electricOrange),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF2a2a2e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category || 
                                  (category == 'All' && _selectedCategory == null);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'All' ? null : category;
                      });
                    },
                    backgroundColor: const Color(0xFF2a2a2e),
                    selectedColor: AppColors.electricOrange,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected 
                          ? AppColors.electricOrange 
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Business list
          Expanded(
            child: StreamBuilder<List<Business>>(
              stream: firestoreService.streamBusinesses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.electricOrange),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                var businesses = snapshot.data ?? [];

                // Apply category filter
                if (_selectedCategory != null) {
                  businesses = businesses.where((b) => 
                    b.businessCategory == _selectedCategory
                  ).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  businesses = businesses.where((b) =>
                    b.businessName.toLowerCase().contains(_searchQuery) ||
                    (b.businessDescription?.toLowerCase().contains(_searchQuery) ?? false)
                  ).toList();
                }

                if (businesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != null
                              ? 'No businesses found'
                              : 'No businesses yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to add one!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateBusinessScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Business'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricOrange,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    return _buildBusinessCard(context, businesses[index], currentUserId);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateBusinessScreen()),
          );
        },
        backgroundColor: AppColors.electricOrange,
        icon: const Icon(Icons.add),
        label: const Text('Add Business'),
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, Business business, String? currentUserId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2a2a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.deepPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BusinessDetailScreen(business: business),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Business icon/logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.electricOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.electricOrange,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppColors.electricOrange,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Business info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.businessName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.deepPurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            business.businessCategory,
                            style: const TextStyle(
                              color: AppColors.electricOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.electricOrange,
                    size: 16,
                  ),
                ],
              ),
              
              if (business.businessDescription != null) ...[
                const SizedBox(height: 12),
                Text(
                  business.businessDescription!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              if (business.businessAddress != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.electricOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        business.businessAddress!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Quick action buttons
              Row(
                children: [
                  if (business.businessPhone != null)
                    Expanded(
                      child: _buildActionButton(
                        Icons.phone,
                        'Call',
                        () => _launchPhone(business.businessPhone!),
                      ),
                    ),
                  if (business.businessPhone != null && business.businessWebsite != null)
                    const SizedBox(width: 8),
                  if (business.businessWebsite != null)
                    Expanded(
                      child: _buildActionButton(
                        Icons.language,
                        'Website',
                        () => _launchURL(business.businessWebsite!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.electricOrange,
        side: const BorderSide(color: AppColors.electricOrange),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open website'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
