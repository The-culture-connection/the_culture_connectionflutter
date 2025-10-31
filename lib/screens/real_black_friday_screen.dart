import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RealBlackFridayScreen extends StatefulWidget {
  const RealBlackFridayScreen({super.key});

  @override
  State<RealBlackFridayScreen> createState() => _RealBlackFridayScreenState();
}

class _RealBlackFridayScreenState extends State<RealBlackFridayScreen> {
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

