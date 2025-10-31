import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/analytics_service.dart';

/// RegistrationScreen - Equivalent to iOS RegisterUser.swift
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  String _selectedExperienceLevel = '';
  String _selectedGenderIdentity = '';
  List<String> _selectedPurposes = [];
  String? _selectedBusinessPurpose;
  bool _locationSkipped = false;
  double? _latitude;
  double? _longitude;
  
  // Skills data
  List<String> _selectedMainCategoriesOffering = [];
  List<String> _selectedSubCategoriesOffering = [];
  List<String> _selectedMainCategoriesSeeking = [];
  List<String> _selectedSubCategoriesSeeking = [];
  
  final List<String> _experienceLevels = ['entry', 'mid level', 'senior', 'retired'];
  final List<String> _genderIdentities = ['Female', 'Male', 'Nonbinary', 'Prefer Not to Say'];
  final List<String> _purposes = [
    'Looking to hire candidates',
    'Looking to get hired',
    'Starting a business',
    'Want to invest in a start up',
  ];
  final List<String> _businessPurposes = ['Fundraising', 'Expertise', 'To Hire'];

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _registerUserAndNavigate() async {
    print('🔐 Starting registration process...');
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      print('📧 Attempting registration with email: ${_emailController.text.trim()}');
      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('✅ User account created successfully');

      final user = userCredential.user;
      if (user != null) {
        // Track user account creation
        final analyticsService = AnalyticsService();
        await analyticsService.trackProfileCreation(
          completionStep: "account_created",
          hasPhoto: _selectedImage != null,
        );
        await analyticsService.setUserId(user.uid);

        // Handle photo upload
        String? photoUrl;
        if (_selectedImage != null) {
          photoUrl = await _uploadProfileImage(_selectedImage!, user.uid);
        }

        // Save user profile data to Firestore
        final userDocument = FirebaseFirestore.instance
            .collection("Profiles")
            .doc(user.uid);
        
        final profileData = {
          "Full Name": _fullNameController.text.trim(),
          "Email": _emailController.text.trim(),
          "Age": int.tryParse(_ageController.text.trim()) ?? 0,
          "experienceLevel": _selectedExperienceLevel,
          "mainCategories": _selectedMainCategoriesOffering,
          "categories": _selectedMainCategoriesSeeking,
          "subCategories": _selectedSubCategoriesOffering,
          "skillsSeeking": _selectedSubCategoriesSeeking,
          "purposes": _selectedPurposes,
          "businessPurpose": _selectedBusinessPurpose,
          "Gender Identity": _selectedGenderIdentity,
          "Gender Preferences": "Everyone",
          "Age Preferences": "Everyone",
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        };

        // Add location data if not skipped
        if (!_locationSkipped && _latitude != null && _longitude != null) {
          profileData["location"] = {
            "coordinates": {
              "latitude": _latitude,
              "longitude": _longitude,
            }
          };
        }

        if (photoUrl != null) {
          profileData["photoURL"] = photoUrl;
        }

        await userDocument.set(profileData, SetOptions(merge: true));
        print('✅ User profile data saved to Firestore');

        // Navigate to main screen after successful registration
        if (mounted) {
          print('✅ Registration completed successfully');
          // Navigate to main screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/main',
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: ${e.message}";
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error saving preferences: ${e.message}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      const Text(
                        'Create Profile',
                        style: TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 28,
                          color: Color(0xFFFF7E00),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Registration form card
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email field
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Password field
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Full Name field
                          CustomTextField(
                            controller: _fullNameController,
                            hintText: 'Full Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Age field
                          CustomTextField(
                            controller: _ageController,
                            hintText: 'Age',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid age';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Profile Photo Section
                          _buildProfilePhotoSection(),
                          
                          const SizedBox(height: 25),
                          
                          // Skills Offering Section
                          _buildSkillsOfferingSection(),
                          
                          const SizedBox(height: 25),
                          
                          // Skills Seeking Section
                          _buildSkillsSeekingSection(),
                          
                          const SizedBox(height: 25),
                          
                          // Experience Level picker
                          _buildExperienceLevelPicker(),
                          
                          const SizedBox(height: 25),
                          
                          // Purpose selection
                          _buildPurposeSelection(),
                          
                          const SizedBox(height: 25),
                          
                          // Gender Identity selection
                          _buildGenderIdentityPicker(),
                          
                          const SizedBox(height: 25),
                          
                          // Location section
                          _buildLocationSection(),
                          
                          const SizedBox(height: 25),
                          
                          // Create Profile button
                          CustomButton(
                            text: 'CREATE PROFILE',
                            onPressed: _isLoading ? null : _registerUserAndNavigate,
                            isLoading: _isLoading,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Error message
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFFF7E00),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        const Text(
          'PROFILE PHOTO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF7E00),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to add photo',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceLevelPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPERIENCE LEVEL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
            border: Border.all(color: const Color(0xFFFF7E00)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedExperienceLevel.isNotEmpty ? _selectedExperienceLevel : null,
              hint: const Text(
                'Select Experience Level',
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
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFFF7E00),
              ),
              items: _experienceLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedExperienceLevel = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PURPOSE',
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
          children: _purposes.map((String purpose) {
            final isSelected = _selectedPurposes.contains(purpose);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPurposes.remove(purpose);
                    if (purpose == 'Starting a business') {
                      _selectedBusinessPurpose = null;
                    }
                  } else {
                    _selectedPurposes.add(purpose);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
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
        
        // Business purpose selection (only shown if "Starting a business" is selected)
        if (_selectedPurposes.contains('Starting a business')) ...[
          const SizedBox(height: 16),
          const Text(
            'BUSINESS PURPOSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF7E00)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBusinessPurpose,
                hint: const Text(
                  'Select Business Purpose',
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
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFFF7E00),
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
      ],
    );
  }

  Widget _buildGenderIdentityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER IDENTITY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
            border: Border.all(color: const Color(0xFFFF7E00)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGenderIdentity.isNotEmpty ? _selectedGenderIdentity : null,
              hint: const Text(
                'Select Gender Identity',
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
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFFF7E00),
              ),
              items: _genderIdentities.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGenderIdentity = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsOfferingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SKILLS YOU CAN OFFER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        
        // Main category selection (single select)
        const Text(
          'Select Main Category',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7E00)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMainCategoriesOffering.isNotEmpty ? _selectedMainCategoriesOffering.first : null,
              hint: const Text(
                'Select Main Category',
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
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFFF7E00),
              ),
              items: _skillsCategories.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMainCategoriesOffering.clear();
                    _selectedSubCategoriesOffering.clear();
                    _selectedMainCategoriesOffering.add(newValue);
                  });
                }
              },
            ),
          ),
        ),
        
        // Subcategories selection (multiselect)
        if (_selectedMainCategoriesOffering.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Select Subcategories (Multiple)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedMainCategoriesOffering.isNotEmpty 
                ? _skillsCategories[_selectedMainCategoriesOffering.first]!.map((subCategory) {
                    final isSelected = _selectedSubCategoriesOffering.contains(subCategory);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSubCategoriesOffering.remove(subCategory);
                          } else {
                            _selectedSubCategoriesOffering.add(subCategory);
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
                  }).toList()
                : [],
          ),
          
          // Add more skills button
          const SizedBox(height: 16),
          CustomButton(
            text: 'ADD MORE SKILLS',
            onPressed: () {
              // Clear current selection to allow selecting different main category
              setState(() {
                _selectedMainCategoriesOffering.clear();
                _selectedSubCategoriesOffering.clear();
              });
            },
            backgroundColor: const Color(0xFF2A2A2A),
            borderColor: const Color(0xFFFF7E00),
          ),
        ],
      ],
    );
  }

  Widget _buildSkillsSeekingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SKILLS YOU ARE SEEKING',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        
        // Main category selection (single select)
        const Text(
          'Select Main Category',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7E00)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMainCategoriesSeeking.isNotEmpty ? _selectedMainCategoriesSeeking.first : null,
              hint: const Text(
                'Select Main Category',
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
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFFF7E00),
              ),
              items: _skillsCategories.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMainCategoriesSeeking.clear();
                    _selectedSubCategoriesSeeking.clear();
                    _selectedMainCategoriesSeeking.add(newValue);
                  });
                }
              },
            ),
          ),
        ),
        
        // Subcategories selection (multiselect)
        if (_selectedMainCategoriesSeeking.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Select Subcategories (Multiple)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedMainCategoriesSeeking.isNotEmpty 
                ? _skillsCategories[_selectedMainCategoriesSeeking.first]!.map((subCategory) {
                    final isSelected = _selectedSubCategoriesSeeking.contains(subCategory);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSubCategoriesSeeking.remove(subCategory);
                          } else {
                            _selectedSubCategoriesSeeking.add(subCategory);
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
                  }).toList()
                : [],
          ),
          
          // Add more skills button
          const SizedBox(height: 16),
          CustomButton(
            text: 'ADD MORE SKILLS',
            onPressed: () {
              // Clear current selection to allow selecting different main category
              setState(() {
                _selectedMainCategoriesSeeking.clear();
                _selectedSubCategoriesSeeking.clear();
              });
            },
            backgroundColor: const Color(0xFF2A2A2A),
            borderColor: const Color(0xFFFF7E00),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOCATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        
        // Location input field
        CustomTextField(
          controller: _locationController,
          hintText: 'Enter your location',
          icon: Icons.location_on,
          validator: (value) {
            if (!_locationSkipped && (value == null || value.isEmpty)) {
              return 'Please enter your location or skip';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Location buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'GET CURRENT LOCATION',
                onPressed: _getCurrentLocation,
                backgroundColor: const Color(0xFF2A2A2A),
                borderColor: const Color(0xFFFF7E00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'SKIP FOR NOW',
                onPressed: () {
                  setState(() {
                    _locationSkipped = true;
                    _locationController.clear();
                    _latitude = null;
                    _longitude = null;
                  });
                },
                backgroundColor: const Color(0xFF2A2A2A),
                borderColor: const Color(0xFFFF7E00),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationSkipped = false;
        _locationController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location obtained successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadProfileImage(File image, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId.jpg');
      
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
