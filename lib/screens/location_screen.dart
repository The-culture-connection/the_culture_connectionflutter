import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/analytics_service.dart';

/// Location Selection Screen - Final step of registration
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _locationSkipped = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    print('🔐 Starting final registration process...');
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
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      
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
          "Full Name": args['fullName'] ?? '',
          "Email": args['email'] ?? '',
          "Age": args['age'] ?? 0,
          "experienceLevel": args['experienceLevel'] ?? '',
          "skillsOffering": args['skillsOffering'] ?? {},
          "skillsSeeking": args['skillsSeeking'] ?? {},
          "purposes": args['purposes'] ?? [],
          "businessPurpose": args['businessPurpose'] ?? '',
          "Gender Identity": args['genderIdentity'] ?? '',
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
                        'Location',
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
                        'Final Step - Add Your Location',
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
                  
                  // Location form card
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
                          
                          const SizedBox(height: 20),
                          
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
                          
                          const SizedBox(height: 30),
                          
                          // Complete Registration button
                          CustomButton(
                            text: 'COMPLETE REGISTRATION',
                            onPressed: _isLoading ? null : _completeRegistration,
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
