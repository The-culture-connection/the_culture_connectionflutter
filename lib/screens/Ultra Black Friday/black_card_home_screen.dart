import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'deal_detail_screen.dart';
import 'my_black_card_wallet_screen.dart';
import 'widgets/business_carousel.dart';
import 'widgets/deal_card.dart';

class BlackCardHomeScreen extends StatefulWidget {
  const BlackCardHomeScreen({Key? key}) : super(key: key);

  @override
  State<BlackCardHomeScreen> createState() => _BlackCardHomeScreenState();
}

class _BlackCardHomeScreenState extends State<BlackCardHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _todayTheme = 'Loading...';
  String? _currentThemeDocId;
  List<String> _allThemes = [];
  int _themeIndex = 0;

  @override
  void initState() {
    super.initState();
    print('🏠 BlackCardHomeScreen initState called');
    _tabController = TabController(length: 2, vsync: this);
    _loadThemesAndSelectToday();
  }

  /// Load all themes from Firestore and select today's theme based on 24-hour rotation
  Future<void> _loadThemesAndSelectToday() async {
    try {
      print('🎨 Loading themes from Ultra Black Friday collection...');
      
      // Get all theme documents from Ultra Black Friday collection
      final themesSnapshot = await FirebaseFirestore.instance
          .collection('Ultra Black Friday')
          .get();

      if (themesSnapshot.docs.isEmpty) {
        print('⚠️ No themes found in Ultra Black Friday collection');
        setState(() {
          _todayTheme = 'Daily Deals';
        });
        return;
      }

      // Extract theme names and document IDs
      final themes = <String, String>{}; // themeName -> docId
      for (var doc in themesSnapshot.docs) {
        final data = doc.data();
        final themeName = data['Theme'] as String?;
        if (themeName != null && themeName.isNotEmpty) {
          themes[themeName] = doc.id;
        }
      }

      if (themes.isEmpty) {
        print('⚠️ No valid themes found');
        setState(() {
          _todayTheme = 'Daily Deals';
        });
        return;
      }

      _allThemes = themes.keys.toList();
      print('🎨 Found ${_allThemes.length} themes: $_allThemes');

      // Calculate which theme to show based on 24-hour rotation
      // Use days since epoch to rotate themes
      final now = DateTime.now();
      final daysSinceEpoch = now.difference(DateTime(1970, 1, 1)).inDays;
      _themeIndex = daysSinceEpoch % _allThemes.length;
      
      final selectedTheme = _allThemes[_themeIndex];
      _currentThemeDocId = themes[selectedTheme];

      print('🎨 Selected theme for today: $selectedTheme (index: $_themeIndex, docId: $_currentThemeDocId)');

      setState(() {
        _todayTheme = selectedTheme;
      });
    } catch (e) {
      print('❌ Error loading themes: $e');
      setState(() {
        _todayTheme = 'Daily Deals';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 BlackCardHomeScreen build called');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Ultra Black Friday',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6600),
          labelColor: const Color(0xFFFF6600),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Home'),
            Tab(text: 'My Claimed Deals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          const MyBlackCardWalletScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadThemesAndSelectToday,
      color: const Color(0xFFFF6600),
      backgroundColor: Colors.grey[900],
      child: CustomScrollView(
        slivers: [
          // Today's Theme Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6600), Color(0xFFFF8833)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Theme",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _todayTheme,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Businesses You Might Like Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Businesses You Might Like',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.favorite,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Business Carousel
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getRecommendedBusinessesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading businesses',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6600),
                      ),
                    ),
                  );
                }

                final businesses = snapshot.data!.docs;

                if (businesses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No businesses available yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return BusinessCarousel(businesses: businesses);
              },
            ),
          ),

          // Today's Deals Section Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Deals",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF6600),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Deals Grid
          StreamBuilder<QuerySnapshot>(
            stream: _getDealsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading deals',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6600),
                      ),
                    ),
                  ),
                );
              }

              var deals = snapshot.data!.docs;
              
              // Filter to only show businesses that have a deal
              deals = deals.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['deal'] != null && data['appVisibility'] == true;
              }).toList();

              if (deals.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 64,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No deals available yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final deal = deals[index];
                      return DealCard(
                        deal: deal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DealDetailScreen(
                                dealId: deal.id,
                                themeDocId: _currentThemeDocId ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: deals.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getRecommendedBusinessesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentThemeDocId == null) {
      return Stream.empty();
    }

    // Get businesses from the current theme's businesses subcollection
    return FirebaseFirestore.instance
        .collection('Ultra Black Friday')
        .doc(_currentThemeDocId)
        .collection('businesses')
        .where('appVisibility', isEqualTo: true)
        .limit(10)
        .snapshots();
  }

  Stream<QuerySnapshot> _getDealsStream() {
    if (_currentThemeDocId == null) {
      return Stream.empty();
    }

    // Get businesses from current theme, then filter for those with deals
    // Since deals are stored within each business document, we'll get businesses
    // and display them as deals if they have a deal field
    return FirebaseFirestore.instance
        .collection('Ultra Black Friday')
        .doc(_currentThemeDocId)
        .collection('businesses')
        .where('appVisibility', isEqualTo: true)
        .snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


