import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

/// Skills Subcategories Selection Screen
class SkillsSubcategoriesScreen extends StatefulWidget {
  const SkillsSubcategoriesScreen({super.key});

  @override
  State<SkillsSubcategoriesScreen> createState() => _SkillsSubcategoriesScreenState();
}

class _SkillsSubcategoriesScreenState extends State<SkillsSubcategoriesScreen> {
  late String _type;
  late List<String> _selectedMainCategories;
  late List<String> _selectedSubCategories;
  String? _currentMainCategory;
  List<String> _currentSubcategories = [];

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
  void initState() {
    super.initState();
    // Initialize with default values
    _type = '';
    _selectedMainCategories = [];
    _selectedSubCategories = [];
    _currentMainCategory = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access route arguments after the widget is fully initialized
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _type = args['type'];
    _selectedMainCategories = List<String>.from(args['selectedMainCategories']);
    _selectedSubCategories = List<String>.from(args['selectedSubCategories']);
    _currentMainCategory = _selectedMainCategories.isNotEmpty ? _selectedMainCategories.first : null;
    _loadCurrentSubcategories();
  }

  void _loadCurrentSubcategories() {
    if (_currentMainCategory != null) {
      _currentSubcategories = _skillsCategories[_currentMainCategory] ?? [];
    }
  }

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
                      Text(
                        'Skills You ${_type == 'offering' ? 'Can Offer' : 'Are Seeking'}',
                        style: const TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 28,
                          color: Color(0xFFFF7E00),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _currentMainCategory ?? 'Select Subcategories',
                        style: const TextStyle(
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
                        // Subcategories selection
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _currentSubcategories.map((String subCategory) {
                            final isSelected = _selectedSubCategories.contains(subCategory);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSubCategories.remove(subCategory);
                                  } else {
                                    _selectedSubCategories.add(subCategory);
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
                                  subCategory,
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
                        
                        const SizedBox(height: 30),
                        
                        // Add another skill button
                        CustomButton(
                          text: 'ADD ANOTHER SKILL',
                          onPressed: _addAnotherSkill,
                          backgroundColor: const Color(0xFF2A2A2A),
                          borderColor: const Color(0xFFFF7E00),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Continue button
                        CustomButton(
                          text: 'CONTINUE',
                          onPressed: _continue,
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

  void _addAnotherSkill() {
    // Simply go back to the previous screen (main categories)
    Navigator.of(context).pop();
  }

  void _continue() {
    // Navigate to next step in registration flow
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    if (_type == 'offering') {
      // Navigate to skills seeking
      Navigator.of(context).pushNamed(
        '/skills-seeking-main',
        arguments: {
          ...args,
          'skillsOffering': {
            'mainCategories': _selectedMainCategories,
            'subCategories': _selectedSubCategories,
          },
        },
      );
    } else {
      // Navigate to location screen (final step)
      Navigator.of(context).pushNamed(
        '/location',
        arguments: {
          ...args,
          'skillsOffering': args['skillsOffering'],
          'skillsSeeking': {
            'categories': _selectedMainCategories,
            'subCategories': _selectedSubCategories,
          },
        },
      );
    }
  }
}
