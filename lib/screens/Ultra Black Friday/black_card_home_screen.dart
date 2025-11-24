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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayTheme();
  }

  Future<void> _loadTodayTheme() async {
    try {
      final themeDoc = await FirebaseFirestore.instance
          .collection('ultraBlackFriday')
          .doc('settings')
          .get();

      if (themeDoc.exists && themeDoc.data()?['todayTheme'] != null) {
        setState(() {
          _todayTheme = themeDoc.data()!['todayTheme'];
        });
      } else {
        setState(() {
          _todayTheme = _getThemeForToday();
        });
      }
    } catch (e) {
      setState(() {
        _todayTheme = _getThemeForToday();
      });
    }
  }

  String _getThemeForToday() {
    final dayOfWeek = DateTime.now().weekday;
    switch (dayOfWeek) {
      case DateTime.monday:
        return 'Motivation Monday';
      case DateTime.tuesday:
        return 'Tasty Tuesday';
      case DateTime.wednesday:
        return 'Wellness Wednesday';
      case DateTime.thursday:
        return 'Thrifty Thursday';
      case DateTime.friday:
        return 'Feel Good Friday';
      case DateTime.saturday:
        return 'Self-Care Saturday';
      case DateTime.sunday:
        return 'Support Sunday';
      default:
        return 'Daily Deals';
    }
  }

  @override
  Widget build(BuildContext context) {
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
      onRefresh: _loadTodayTheme,
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

              final deals = snapshot.data!.docs;

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
    if (user == null) {
      return Stream.empty();
    }

    // In a real implementation, this would use the user's preferences
    // to filter and sort businesses. For now, we'll just get all businesses.
    return FirebaseFirestore.instance
        .collection('ultraBlackFriday')
        .doc('data')
        .collection('businesses')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots();
  }

  Stream<QuerySnapshot> _getDealsStream() {
    final now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('ultraBlackFriday')
        .doc('data')
        .collection('deals')
        .where('isActive', isEqualTo: true)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


