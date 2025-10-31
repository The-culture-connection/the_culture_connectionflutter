import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

/// Registration Step 2 - Skills Selection
class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() => _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  // Skills data
  List<String> _selectedMainCategoriesOffering = [];
  List<String> _selectedSubCategoriesOffering = [];
  List<String> _selectedMainCategoriesSeeking = [];
  List<String> _selectedSubCategoriesSeeking = [];
  
  bool _isOfferingMode = true; // true for offering, false for seeking

  // Skills categories data
  final Map<String, List<String>> _skillsCategories = {
    'Technology & Engineering': [
      'Software Development',
      'Web Design / UX/UI Design',
      'App Development (iOS / Android / Flutter)',
      'Data Analysis / Data Science',
      'Machine Learning / AI Integration',
      'Cybersecurity',
      'Cloud Computing (AWS / Firebase / Azure)',
      'IT Support & Systems Administration',
      'Automation / Scripting',
      'CAD Design / Product Prototyping',
      'Electrical / Mechanical Engineering',
    ],
    'Marketing, Branding & PR': [
      'Public Relations (PR)',
      'Brand Strategy',
      'Marketing Campaign Development',
      'Social Media Management',
      'Copywriting / Content Strategy',
      'Influencer Relations',
      'Event Marketing / Experiential Marketing',
      'SEO / SEM / Paid Ads',
      'Graphic Design',
      'Video Editing / Photography',
    ],
    'Business, Finance & Consulting': [
      'Financial Consulting',
      'Funding Strategy / Grant Writing',
      'Business Planning & Modeling',
      'Accounting / Bookkeeping',
      'Market Research / Competitive Analysis',
      'Strategic Partnerships',
      'Investor Relations / Pitch Decks',
      'Sales / Lead Generation',
      'Project Management',
      'Business Development',
    ],
    'Leadership & Organizational Development': [
      'Executive Leadership Coaching',
      'Team Building / Organizational Culture',
      'Diversity, Equity & Inclusion Strategy',
      'Public Speaking / Communication',
      'Time Management / Productivity Systems',
      'Conflict Resolution / Mediation',
    ],
    'Entrepreneurship & Startups': [
      'Startup Formation & Legal Structure',
      'Fundraising / Venture Capital Readiness',
      'Pitching & Investor Relations',
      'Product Development',
      'Scaling Operations',
      'Community Building',
    ],
    'Creative, Media & Arts': [
      'Photography / Videography',
      'Creative Direction',
      'Fashion Design / Styling',
      'Music Production / Audio Engineering',
      'Writing / Editing / Journalism',
      'Visual Arts / Illustration',
      'Acting / Performing Arts',
    ],
    'Health, Wellness & Lifestyle': [
      'Therapy / Counseling',
      'Life Coaching / Mindset Coaching',
      'Nutrition / Fitness Training',
      'Yoga / Meditation Instruction',
      'Wellness Brand Strategy',
      'Health Tech Innovation',
    ],
    'Education & Mentorship': [
      'Tutoring / Academic Support',
      'Curriculum Development',
      'Training & Facilitation',
      'Career Coaching / Resume Support',
      'Mentorship / Professional Guidance',
    ],
    'Trades & Services': [
      'Construction / General Contracting',
      'Real Estate / Property Management',
      'Home Design / Interior Decorating',
      'Cleaning / Maintenance',
      'Landscaping / Sustainability',
    ],
    'Cosmetology': [
      'Hair Care & Styling',
      'Nail Care',
      'Makeup & Cosmetics',
      'Skin Care & Aesthetics',
      'Body & Spa Services',
      'Wellness & Image',
      'Beauty Product & Brand Services',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
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
                        'Create Profile - Step 2',
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
                        'Skills Selection',
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
                  
                  // Skills selection card
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
                        // Mode selector
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isOfferingMode = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isOfferingMode ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFF7E00)),
                                  ),
                                  child: Text(
                                    'Skills I Can Offer',
                                    style: TextStyle(
                                      color: _isOfferingMode ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isOfferingMode = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isOfferingMode ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFF7E00)),
                                  ),
                                  child: Text(
                                    'Skills I Am Seeking',
                                    style: TextStyle(
                                      color: !_isOfferingMode ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // Skills selection content
                        _buildSkillsSelection(),
                        
                        const SizedBox(height: 25),
                        
                        // Continue button
                        CustomButton(
                          text: 'CONTINUE',
                          onPressed: () {
                            // Navigate to step 3 with all data
                            Navigator.of(context).pushNamed(
                              '/registration-step3',
                              arguments: {
                                ...args,
                                'skillsOffering': {
                                  'mainCategories': _selectedMainCategoriesOffering,
                                  'subCategories': _selectedSubCategoriesOffering,
                                },
                                'skillsSeeking': {
                                  'categories': _selectedMainCategoriesSeeking,
                                  'subCategories': _selectedSubCategoriesSeeking,
                                },
                              },
                            );
                          },
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

  Widget _buildSkillsSelection() {
    final currentMainCategories = _isOfferingMode ? _selectedMainCategoriesOffering : _selectedMainCategoriesSeeking;
    final currentSubCategories = _isOfferingMode ? _selectedSubCategoriesOffering : _selectedSubCategoriesSeeking;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main categories selection
        const Text(
          'Main Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillsCategories.keys.map((String category) {
            final isSelected = currentMainCategories.contains(category);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_isOfferingMode) {
                      _selectedMainCategoriesOffering.remove(category);
                      _selectedSubCategoriesOffering.removeWhere((sub) => 
                        _skillsCategories[category]!.contains(sub));
                    } else {
                      _selectedMainCategoriesSeeking.remove(category);
                      _selectedSubCategoriesSeeking.removeWhere((sub) => 
                        _skillsCategories[category]!.contains(sub));
                    }
                  } else {
                    if (_isOfferingMode) {
                      _selectedMainCategoriesOffering.add(category);
                    } else {
                      _selectedMainCategoriesSeeking.add(category);
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF7E00),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // Subcategories selection
        if (currentMainCategories.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Subcategories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentMainCategories.expand((mainCategory) {
              return _skillsCategories[mainCategory]!.map((subCategory) {
                final isSelected = currentSubCategories.contains(subCategory);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        if (_isOfferingMode) {
                          _selectedSubCategoriesOffering.remove(subCategory);
                        } else {
                          _selectedSubCategoriesSeeking.remove(subCategory);
                        }
                      } else {
                        if (_isOfferingMode) {
                          _selectedSubCategoriesOffering.add(subCategory);
                        } else {
                          _selectedSubCategoriesSeeking.add(subCategory);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF7E00),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subCategory,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ],
      ],
    );
  }
}

