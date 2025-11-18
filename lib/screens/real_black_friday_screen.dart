import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/black_friday_service.dart';
import '../models/black_friday_offer.dart';
import 'black_friday_bid_detail_screen.dart';
import 'black_friday_bid_dashboard_screen.dart';

class RealBlackFridayScreen extends StatefulWidget {
  const RealBlackFridayScreen({super.key});

  @override
  State<RealBlackFridayScreen> createState() => _RealBlackFridayScreenState();
}

class _RealBlackFridayScreenState extends State<RealBlackFridayScreen> {
  final BlackFridayService _service = BlackFridayService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Update every second to refresh countdown
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _updateCountdown();
      }
    });
  }

  String _getCountdown() {
    final targetDate = DateTime(2025, 11, 28, 0, 0, 0);
    final now = DateTime.now();
    
    if (now.isAfter(targetDate)) {
      return 'Event has started!';
    }
    
    final difference = targetDate.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return '${days}d ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    // Check if event is active
    if (_service.isEventActive()) {
      return _buildActiveEventScreen();
    } else {
      return _buildCountdownScreen();
    }
  }

  Widget _buildActiveEventScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/realblackfridaylandingpage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with dashboard button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/CC_PrimaryLogo_SilverPurple.png',
                          height: 40,
                        ),
                        // Bid Dashboard Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BlackFridayBidDashboardScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Bid Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Dynamic Title from Firebase
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreamBuilder<String>(
                      stream: _service.streamTodaysTitle(),
                      builder: (context, snapshot) {
                        final title = snapshot.data ?? 'CAREER & BUSINESS GROWTH';
                        return Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Matches-StrikeRough',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Offers Grid
                  Expanded(
                    child: StreamBuilder<List<BlackFridayOffer>>(
                      stream: _service.streamTodaysOffers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.electricOrange,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading offers',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          );
                        }

                        final offers = snapshot.data ?? [];

                        if (offers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 64,
                                  color: AppColors.electricOrange.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No offers available today',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            return _buildOfferCard(offers[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BlackFridayOffer offer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlackFridayBidDetailScreen(
              offer: offer,
              dayKey: _service.getTodayKey(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.electricOrange,
              AppColors.electricOrange.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricOrange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.deepPurple.withOpacity(0.3),
                  backgroundImage: offer.creatorPhotoUrl.isNotEmpty
                      ? NetworkImage(offer.creatorPhotoUrl)
                      : null,
                  child: offer.creatorPhotoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                offer.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Description
              Expanded(
                child: Text(
                  offer.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Tamearaimage-2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/CC_PrimaryLogo_SilverPurple.png',
                        height: 100,
                        width: 280,
                      ),
                      const SizedBox(height: 40),
                      
                      // Title
                      const Text(
                        'THE REAL BLACK FRIDAY',
                        style: TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricOrange,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Coming Soon Message
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.electricOrange,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: AppColors.electricOrange,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'COMING SOON',
                              style: TextStyle(
                                fontFamily: 'Matches-StrikeRough',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Stay tuned for an exclusive event that celebrates Black excellence and community.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            // Countdown Timer
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.deepPurple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.electricOrange,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Event Starts In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getCountdown(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.electricOrange,
                                      fontFamily: 'Inter',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Until November 28, 2025 at 12:00 AM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.6),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

