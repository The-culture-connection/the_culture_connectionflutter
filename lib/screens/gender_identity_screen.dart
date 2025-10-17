import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

/// Gender Identity Selection Screen
class GenderIdentityScreen extends StatefulWidget {
  const GenderIdentityScreen({super.key});

  @override
  State<GenderIdentityScreen> createState() => _GenderIdentityScreenState();
}

class _GenderIdentityScreenState extends State<GenderIdentityScreen> {
  String? _selectedGenderIdentity;

  final List<String> _genderIdentities = [
    'Female',
    'Male',
    'Nonbinary',
    'Prefer Not to Say',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Loginimage1-3.png'),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo and Title Section
                  Column(
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/CC_PrimaryLogo_SilverPurple.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Title
                      const Text(
                        'Gender Identity',
                        style: TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 28,
                          color: Color(0xFFFF7E00),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'How do you identify?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gender identity selection card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D1E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Gender identity selection
                        ..._genderIdentities.map((String gender) {
                          final isSelected = _selectedGenderIdentity == gender;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGenderIdentity = gender;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF7E00),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                gender,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 30),
                        
                        // Continue button
                        CustomButton(
                          text: 'CONTINUE',
                          onPressed: _selectedGenderIdentity != null ? _navigateToSkillsOffering : null,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSkillsOffering() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.of(context).pushNamed(
      '/skills-main-categories',
      arguments: {
        ...args,
        'genderIdentity': _selectedGenderIdentity,
      },
    );
  }
}

