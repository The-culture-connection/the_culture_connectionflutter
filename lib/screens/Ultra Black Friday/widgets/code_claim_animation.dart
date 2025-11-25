import 'package:flutter/material.dart';
import 'dart:async';

class CodeClaimAnimationScreen extends StatefulWidget {
  const CodeClaimAnimationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CodeClaimAnimationScreen> createState() =>
      _CodeClaimAnimationScreenState();
}

class _CodeClaimAnimationScreenState extends State<CodeClaimAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Show GIF first for 2.5 seconds, then transition to success message
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = true;
        });
        _controller.forward();
      }
    });

    // Auto close after showing success message for 3 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated switcher to transition between GIF and success message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _showSuccessMessage
                  ? // Success message screen
                    Center(
                        key: const ValueKey('success'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated checkmark
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6600),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6600).withOpacity(0.5),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'Code Claimed!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Check "My Claimed Deals" to redeem',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                  : // GIF animation screen
                    Center(
                        key: const ValueKey('gif'),
                        child: Transform.scale(
                          scale: 1.3,
                          child: Image.asset(
                            'assets/Blackcardanimation.gif',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if GIF is not available
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black,
                                child: Center(
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      gradient: const RadialGradient(
                                        colors: [
                                          Color(0xFFFF6600),
                                          Colors.black,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


