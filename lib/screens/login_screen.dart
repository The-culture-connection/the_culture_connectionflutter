import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'registration_screen.dart';

/// LoginScreen - Equivalent to iOS LoginView.swift
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logInUser() async {
    print('🔐 Starting login process...');
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📧 Attempting login with email: ${_emailController.text.trim()}');
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('✅ Login successful!');
      
      // Navigation will be handled by the ContentView auth state listener
      // No need to pop or navigate manually
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = "Failed to log in: ${e.message}";
      });
      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
      });
      print('Unexpected Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    print('🔐 Starting Google sign in...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📱 Calling Google Sign In service...');
      final userCredential = await _authService.signInWithGoogle();
      print('✅ Google sign in successful! User: ${userCredential.user?.email}');
      
      // Check if user profile exists in Firestore
      final user = userCredential.user;
      if (user != null) {
        final profileDoc = await FirebaseFirestore.instance
            .collection('Profiles')
            .doc(user.uid)
            .get();
        
        // If profile doesn't exist, create a basic one
        if (!profileDoc.exists) {
          print('📝 Creating new profile for Google user...');
          await FirebaseFirestore.instance
              .collection('Profiles')
              .doc(user.uid)
              .set({
            'Full Name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Profile created successfully');
        }
      }
      
      // Navigation will be handled by the ContentView auth state listener
    } on Exception catch (e) {
      setState(() {
        _errorMessage = "Failed to sign in with Google: ${e.toString()}";
      });
      print('❌ Google Sign In Error: $e');
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
                        width: 300,
                        height: 180,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/CC_PrimaryLogo_SilverPurple.png'),
                            fit: BoxFit.contain,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Login form card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D1E).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
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
                              
                              // Login button
                              CustomButton(
                                text: 'LOGIN',
                                onPressed: _isLoading ? null : _logInUser,
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
                              
                              // Forgot Password button
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement password reset
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password reset feature coming soon'),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFFFF7E00),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Divider
                              Row(
                                children: [
                                  const Expanded(child: Divider(color: Colors.white54)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: Colors.white54)),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Google Sign In Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _signInWithGoogle,
                                  icon: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.login,
                                        color: Colors.white,
                                        size: 24,
                                      );
                                    },
                                  ),
                                  label: const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    side: const BorderSide(color: Colors.white54, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RegistrationScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign up',
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
                    ],
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
}
