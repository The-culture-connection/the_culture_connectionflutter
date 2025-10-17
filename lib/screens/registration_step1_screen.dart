import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Registration Step 1 - Basic Information (Name, Email, Password, Age, Photo)
class RegistrationStep1Screen extends StatefulWidget {
  const RegistrationStep1Screen({super.key});

  @override
  State<RegistrationStep1Screen> createState() => _RegistrationStep1ScreenState();
}

class _RegistrationStep1ScreenState extends State<RegistrationStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  
  File? _selectedImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _navigateToStep2() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      Navigator.of(context).pushNamed(
        '/experience-level',
        arguments: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'fullName': _fullNameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'selectedImage': _selectedImage,
        },
      );
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
                        'Create Profile - Step 1',
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
                        'Basic Information',
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
                          
                          // Continue button
                          CustomButton(
                            text: 'CONTINUE',
                            onPressed: _navigateToStep2,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Back to login link
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
}
