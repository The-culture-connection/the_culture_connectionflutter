import 'package:flutter/material.dart';
import 'dart:async';

class CodeClaimAnimationScreen extends StatefulWidget {
  final String code;

  const CodeClaimAnimationScreen({
    Key? key,
    required this.code,
  }) : super(key: key);

  @override
  State<CodeClaimAnimationScreen> createState() =>
      _CodeClaimAnimationScreenState();
}

class _CodeClaimAnimationScreenState extends State<CodeClaimAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showCheckmark = false;

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

    _controller.forward();

    // Show checkmark after animation
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showCheckmark = true;
        });
      }
    });

    // Auto close after showing success
    Timer(const Duration(seconds: 3), () {
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
            // Background animation (GIF placeholder)
            Center(
              child: Image.asset(
                'assets/Blackcardanimation.gif',
                fit: BoxFit.cover,
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

            // Content overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated checkmark
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedOpacity(
                      opacity: _showCheckmark ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
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
                  ),

                  const SizedBox(height: 40),

                  // Success text
                  AnimatedOpacity(
                    opacity: _showCheckmark ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        const Text(
                          'Code Claimed!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF6600),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            widget.code,
                            style: const TextStyle(
                              color: Color(0xFFFF6600),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Check "My Claimed Deals" to redeem',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
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


