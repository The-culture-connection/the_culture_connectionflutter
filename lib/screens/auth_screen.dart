import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_step1_screen.dart';

/// AuthScreen - Equivalent to iOS AuthView.swift
/// Shows the main authentication screen with background image and buttons
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Loginimage1-2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay for better text readability
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Logo and Title Section
                Column(
                  children: [
                    // Logo
                    Container(
                      width: 300,
                      height: 180,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/CC_PrimaryLogo_SilverPurple.png'),
                          fit: BoxFit.contain,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Buttons stacked vertically
                    Column(
                      children: [
                        // LOGIN button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFFF7E00),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontFamily: 'Matches-StrikeRough',
                                fontSize: 20,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // SIGN UP button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationStep1Screen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7E00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontFamily: 'Matches-StrikeRough',
                                fontSize: 20,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}