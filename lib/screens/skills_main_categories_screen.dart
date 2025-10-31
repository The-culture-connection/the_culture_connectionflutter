import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

/// Skills Main Categories Selection Screen
class SkillsMainCategoriesScreen extends StatefulWidget {
  final String type; // 'offering' or 'seeking'
  final List<String> selectedMainCategories;
  final List<String> selectedSubCategories;

  const SkillsMainCategoriesScreen({
    super.key,
    required this.type,
    required this.selectedMainCategories,
    required this.selectedSubCategories,
  });

  @override
  State<SkillsMainCategoriesScreen> createState() => _SkillsMainCategoriesScreenState();
}

class _SkillsMainCategoriesScreenState extends State<SkillsMainCategoriesScreen> {
  List<String> _selectedMainCategories = [];

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
    _selectedMainCategories = List.from(widget.selectedMainCategories);
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
                        'Skills You ${widget.type == 'offering' ? 'Can Offer' : 'Are Seeking'}',
                        style: const TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 28,
                          color: Color(0xFFFF7E00),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Select Main Categories',
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
                        // Main categories selection
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _skillsCategories.keys.map((String category) {
                            final isSelected = _selectedMainCategories.contains(category);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedMainCategories.remove(category);
                                  } else {
                                    _selectedMainCategories.add(category);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFF7E00),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Continue button
                        CustomButton(
                          text: 'CONTINUE',
                          onPressed: _selectedMainCategories.isNotEmpty ? _navigateToSubcategories : null,
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

  void _navigateToSubcategories() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.of(context).pushNamed(
      '/skills-subcategories',
      arguments: {
        'type': widget.type,
        'selectedMainCategories': _selectedMainCategories,
        'selectedSubCategories': widget.selectedSubCategories,
        // Pass through all registration data
        ...args,
      },
    );
  }
}
