import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../constants/app_colors.dart';
import '../../constants/skills_categories.dart';
import '../../constants/experience_levels.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_profile.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // State
  File? _profileImage;
  final Set<String> _selectedSkillsOffering = {};
  final Set<String> _selectedSkillsSeeking = {};
  String? _selectedLevel;
  final Set<String> _selectedPurposes = {};
  String? _selectedGender;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _levels = ['Entry-Level', 'Mid-Level', 'Senior-Level', 'Retired/Advisor'];
  final List<String> _genders = ['Male', 'Female', 'Nonbinary', 'Prefer not to say'];
  final List<String> _purposes = [
    'Looking to Hire',
    'Starting a business',
    'Looking to get hired',
    'Looking to invest in a start up',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Reverse geocode to get city/state
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location detected!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _geocodeLocation() async {
    if (_cityController.text.isEmpty || _stateController.text.isEmpty) {
      return;
    }

    try {
      final query = '${_cityController.text}, ${_stateController.text}';
      final locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
      }
    } catch (e) {
      // Silent fail - geocoding is optional
      print('Geocoding failed: $e');
    }
  }

  Future<void> _register() async {
    // Validation
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedSkillsOffering.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one skill you can offer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedSkillsSeeking.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one skill you are seeking'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your experience level'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPurposes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one purpose'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_cityController.text.isEmpty || _stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your city and state'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Geocode if not already done
      if (_latitude == null || _longitude == null) {
        await _geocodeLocation();
      }

      // 1. Create Firebase Auth account
      final authService = AuthService();
      final userCredential = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final userId = userCredential.user!.uid;

      // 2. Upload profile photo
      final storageService = StorageService();
      final photoURL = await storageService.uploadProfilePhoto(
        userId,
        _profileImage!,
      );

      // 3. Create user profile in Firestore
      final userProfile = UserProfile(
        id: userId,
        userId: userId,
        fullName: _nameController.text.trim(),
        age: 0, // Not collected in this flow
        gender: _selectedGender!,
        experienceLevel: _selectedLevel!,
        skillsOffering: _selectedSkillsOffering.toList(),
        skillsSeeking: _selectedSkillsSeeking.toList(),
        purposes: _selectedPurposes.toList(),
        photoURL: photoURL,
        totalPoints: 0,
        blockedUsers: {},
        genderPreferences: 'Everyone',
        connectionPreference: 'Both',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      final firestoreService = FirestoreService();
      await firestoreService.createUserProfile(userProfile);

      // 4. Award registration points
      await firestoreService.addPoints(
        userId,
        50,
        'profile_created',
      );

      // Success! AuthWrapper will automatically navigate to MainNavigationScreen
      // because the user is now authenticated
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Loginimage1-3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/CC_PrimaryLogo_DeepPurple.png',
                        width: 100,
                        height: 50,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Profile',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${_currentPage + 1} of 7',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress indicator (7 steps total)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 35,
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? AppColors.electricOrange
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                
                // Form pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    children: [
                      _buildStep1BasicInfo(),
                      _buildStep2SkillsOffering(),
                      _buildStep3SkillsSeeking(),
                      _buildStep4Level(),
                      _buildStep5Purpose(),
                      _buildStep6Gender(),
                      _buildStep7Location(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.electricOrange, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('BACK'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_currentPage < 6 ? _nextPage : _register),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.electricOrange,
                                width: 2,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentPage < 6 ? 'NEXT' : 'CREATE PROFILE',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sign in link
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.electricOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: Name / Email / Password / Avatar
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Let\'s get started!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile photo
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepPurple.withOpacity(0.3),
                  border: Border.all(
                    color: AppColors.electricOrange,
                    width: 3,
                  ),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: AppColors.electricOrange,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add photo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            
            // Password
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              validator: Validators.password,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.electricOrange,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Skills Offering (What can you offer)
  Widget _buildStep2SkillsOffering() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What can you offer?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the skills and expertise you can share',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          ...SkillsCategories.categories.entries.map((entry) {
            return _buildSkillCategory(entry.key, entry.value, _selectedSkillsOffering);
          }),
        ],
      ),
    );
  }

  // STEP 3: Skills Seeking (What are you looking for)
  Widget _buildStep3SkillsSeeking() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What skills are you seeking?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the skills you want to learn or need help with',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          ...SkillsCategories.categories.entries.map((entry) {
            return _buildSkillCategory(entry.key, entry.value, _selectedSkillsSeeking);
          }),
        ],
      ),
    );
  }

  // STEP 4: Experience Level
  Widget _buildStep4Level() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Experience Level',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your professional experience level',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          ..._levels.map((level) {
            final isSelected = _selectedLevel == level;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.electricOrange.withOpacity(0.2)
                    : const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.electricOrange 
                      : AppColors.deepPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  level,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                value: level,
                groupValue: _selectedLevel,
                activeColor: AppColors.electricOrange,
                onChanged: (value) {
                  setState(() => _selectedLevel = value);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 5: What brings you here (Purpose)
  Widget _buildStep5Purpose() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What brings you here?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          ..._purposes.map((purpose) {
            final isSelected = _selectedPurposes.contains(purpose);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.electricOrange.withOpacity(0.2)
                    : const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.electricOrange 
                      : AppColors.deepPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  purpose,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                value: isSelected,
                activeColor: AppColors.electricOrange,
                checkColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedPurposes.add(purpose);
                    } else {
                      _selectedPurposes.remove(purpose);
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 6: Gender
  Widget _buildStep6Gender() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Gender',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your gender identity',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          ..._genders.map((gender) {
            final isSelected = _selectedGender == gender;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.electricOrange.withOpacity(0.2)
                    : const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.electricOrange 
                      : AppColors.deepPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  gender,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                value: gender,
                groupValue: _selectedGender,
                activeColor: AppColors.electricOrange,
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 7: Location
  Widget _buildStep7Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Location',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help others find you based on location',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          
          // City
          _buildTextField(
            controller: _cityController,
            label: 'City',
            icon: Icons.location_city,
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          
          // State
          _buildTextField(
            controller: _stateController,
            label: 'State',
            icon: Icons.map,
            validator: Validators.required,
          ),
          const SizedBox(height: 24),
          
          // Use Current Location button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.electricOrange,
                side: const BorderSide(color: AppColors.electricOrange, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          if (_latitude != null && _longitude != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location detected: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String category, List<String> skills, Set<String> selectedSkills) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.electricOrange.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: AppColors.electricOrange,
        collapsedIconColor: Colors.white,
        children: skills.map((skill) {
          final isSelected = selectedSkills.contains(skill);
          return CheckboxListTile(
            title: Text(
              skill,
              style: const TextStyle(color: Colors.white),
            ),
            value: isSelected,
            activeColor: AppColors.electricOrange,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedSkills.add(skill);
                } else {
                  selectedSkills.remove(skill);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppColors.electricOrange),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.deepPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }
}
