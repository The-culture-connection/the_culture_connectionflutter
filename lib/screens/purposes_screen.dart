import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

/// Purposes Selection Screen
class PurposesScreen extends StatefulWidget {
  const PurposesScreen({super.key});

  @override
  State<PurposesScreen> createState() => _PurposesScreenState();
}

class _PurposesScreenState extends State<PurposesScreen> {
  List<String> _selectedPurposes = [];
  String? _selectedBusinessPurpose;

  final List<String> _purposes = [
    'Looking to hire candidates',
    'Looking to get hired',
    'Starting a business',
    'Networking',
    'Learning new skills',
    'Mentoring others',
    'Finding co-founders',
  ];

  final List<String> _businessPurposes = [
    'Fundraising',
    'Expertise',
    'To Hire',
    'Want to invest in a startup',
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
                        'Why Are You Here?',
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
                        'Select your purposes (multiple allowed)',
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
                  
                  // Purposes selection card
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
                        // Purposes selection
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _purposes.map((String purpose) {
                            final isSelected = _selectedPurposes.contains(purpose);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPurposes.remove(purpose);
                                    // Clear business purpose if "Starting a business" is deselected
                                    if (purpose == 'Starting a business') {
                                      _selectedBusinessPurpose = null;
                                    }
                                  } else {
                                    _selectedPurposes.add(purpose);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFF7E00),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  purpose,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        // Business purpose dropdown (only show if "Starting a business" is selected)
                        if (_selectedPurposes.contains('Starting a business')) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'What do you need help with for your business?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF7E00),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedBusinessPurpose,
                                hint: const Text(
                                  'Select business purpose',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                dropdownColor: const Color(0xFF2A2A2A),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                items: _businessPurposes.map((String purpose) {
                                  return DropdownMenuItem<String>(
                                    value: purpose,
                                    child: Text(purpose),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBusinessPurpose = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 30),
                        
                        // Continue button
                        CustomButton(
                          text: 'CONTINUE',
                          onPressed: _selectedPurposes.isNotEmpty ? _navigateToGender : null,
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

  void _navigateToGender() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.of(context).pushNamed(
      '/gender-identity',
      arguments: {
        ...args,
        'purposes': _selectedPurposes,
        'businessPurpose': _selectedBusinessPurpose,
      },
    );
  }
}

