import 'dart:ui';
import 'package:flutter/material.dart';

/// ComingSoonScreen - Generic screen for features that are coming soon
class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({
    super.key,
    required this.featureName,
  });

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
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Logo Section
                  Image.asset(
                    'assets/CC_PrimaryLogo_SilverPurple.png',
                    height: 120,
                    width: 320,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Coming Soon Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7E00).withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF7E00),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.hourglass_empty,
                            color: Color(0xFFFF7E00),
                            size: 60,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Feature Name
                        Text(
                          featureName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'Matches-StrikeRough',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Coming Soon Text
                        const Text(
                          'COMING SOON',
                          style: TextStyle(
                            color: Color(0xFFFF7E00),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            fontFamily: 'Matches-StrikeRough',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Description
                        const Text(
                          'We\'re working hard to bring you this exciting new feature. Stay tuned for updates!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'GO BACK',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Matches-StrikeRough',
                          ),
                        ),
                      ),
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
}
