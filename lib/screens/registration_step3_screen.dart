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

/// Registration Step 3 - Location, Experience, Purposes, Gender
class RegistrationStep3Screen extends StatefulWidget {
  const RegistrationStep3Screen({super.key});

  @override
  State<RegistrationStep3Screen> createState() => _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedExperienceLevel = '';
  String _selectedGenderIdentity = '';
  List<String> _selectedPurposes = [];
  String? _selectedBusinessPurpose;
  bool _locationSkipped = false;
  double? _latitude;
  double? _longitude;
  
  final List<String> _experienceLevels = ['entry', 'mid level', 'senior', 'retired'];
  final List<String> _genderIdentities = ['Female', 'Male', 'Nonbinary', 'Prefer Not to Say'];
  final List<String> _purposes = [
    'Looking to hire candidates',
    'Looking to get hired',
    'Starting a business',
    'Want to invest in a start up',
  ];
  final List<String> _businessPurposes = ['Fundraising', 'Expertise', 'To Hire'];

  @override
  void dispose() {
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
      final route = ModalRoute.of(context);
      if (route?.settings.arguments == null) {
        print('❌ No arguments provided to registration step 3');
        return;
      }
      final args = route!.settings.arguments as Map<String, dynamic>;
      
      print('📧 Attempting registration with email: ${args['email']}');
      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: args['email'],
        password: args['password'],
      );
      print('✅ User account created successfully');

      final user = userCredential.user;
      if (user != null) {
        // Track user account creation
        final analyticsService = AnalyticsService();
        await analyticsService.trackProfileCreation(
          completionStep: "account_created",
          hasPhoto: args['selectedImage'] != null,
        );
        await analyticsService.setUserId(user.uid);

        // Handle photo upload
        String? photoUrl;
        if (args['selectedImage'] != null) {
          photoUrl = await _uploadProfileImage(args['selectedImage'], user.uid);
        }

        // Save user profile data to Firestore
        final userDocument = FirebaseFirestore.instance
            .collection("Profiles")
            .doc(user.uid);
        
        final profileData = {
          "Full Name": args['fullName'],
          "Email": args['email'],
          "Age": args['age'],
          "experienceLevel": _selectedExperienceLevel,
          "skillsOffering": args['skillsOffering'],
          "skillsSeeking": args['skillsSeeking'],
          "purposes": _selectedPurposes,
          "businessPurpose": _selectedBusinessPurpose,
          "Gender Identity": _selectedGenderIdentity,
          "Gender Preferences": "Everyone",
          "Age Preferences": "Everyone",
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        };

        if (photoUrl != null) {
          profileData["photoURL"] = photoUrl;
        }

        // Add location data if not skipped
        if (!_locationSkipped && _latitude != null && _longitude != null) {
          profileData["location"] = {
            "coordinates": {
              "latitude": _latitude,
              "longitude": _longitude,
            }
          };
        }

        await userDocument.set(profileData, SetOptions(merge: true));
        print('✅ User profile data saved to Firestore');

        // Navigate to main app
        if (mounted) {
          print('✅ Registration completed successfully');
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
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
                        'Create Profile - Step 3',
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
                        'Location & Preferences',
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
                          // Location section
                          _buildLocationSection(),
                          
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

