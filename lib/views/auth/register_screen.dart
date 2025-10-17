import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:culture_connection/services/auth_service.dart';
import 'package:culture_connection/services/firestore_service.dart';
import 'package:culture_connection/services/storage_service.dart';
import 'package:culture_connection/models/user_profile.dart';
import 'package:culture_connection/constants/app_constants.dart';
import 'package:culture_connection/constants/skills_categories.dart';

/// Simplified single-screen registration
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  // Form state
  String? _selectedGender;
  String? _selectedExperienceLevel;
  File? _profileImage;
  List<String> _selectedSkillsOffering = [];
  List<String> _selectedSkillsSeeking = [];
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _profileImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _showSkillsSelector({
    required String title,
    required List<String> selectedSkills,
    required Function(List<String>) onSelected,
  }) async {
    List<String> tempSelected = List.from(selectedSkills);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: SkillsCategories.allCategories.entries.map((category) {
                return ExpansionTile(
                  title: Text(
                    category.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: category.value.map((skill) {
                    final isSelected = tempSelected.contains(skill);
                    return CheckboxListTile(
                      title: Text(skill),
                      value: isSelected,
                      dense: true,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelected.add(skill);
                          } else {
                            tempSelected.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelected(tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile photo')),
      );
      return;
    }

    if (_selectedSkillsOffering.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill you can offer')),
      );
      return;
    }

    if (_selectedSkillsSeeking.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill you are seeking')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create auth account
      final userCredential = await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final userId = userCredential.user!.uid;

      // Upload profile photo
      final photoURL = await _storageService.uploadProfilePhoto(
        userId,
        _profileImage!,
      );

      // Create user profile
      final profile = UserProfile(
        userId: userId,
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender!,
        experienceLevel: _selectedExperienceLevel!,
        skillsOffering: _selectedSkillsOffering,
        skillsSeeking: _selectedSkillsSeeking,
        photoURL: photoURL,
        totalPoints: AppConstants.pointsProfileComplete,
      );

      await _firestoreService.createUserProfile(profile);

      // Award points for completing profile
      // This will be handled automatically in the main app

      if (mounted) {
        // Navigate to main app (auth state listener will handle it)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to add photo',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
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
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age *',
                    hintText: 'Enter your age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Please enter a valid age';
                    }
                    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
                      return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: AppConstants.genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Experience Level
                DropdownButtonFormField<String>(
                  value: _selectedExperienceLevel,
                  decoration: const InputDecoration(
                    labelText: 'Experience Level *',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: AppConstants.experienceLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedExperienceLevel = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your experience level';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Skills Offering
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Skills Offering *',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showSkillsSelector(
                                title: 'Select Skills You Can Offer',
                                selectedSkills: _selectedSkillsOffering,
                                onSelected: (skills) {
                                  setState(() => _selectedSkillsOffering = skills);
                                },
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _selectedSkillsOffering.isEmpty
                          ? const Text(
                              'No skills selected. Tap Add to select skills.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSkillsOffering.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSkillsOffering.remove(skill);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Skills Seeking
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Skills Seeking *',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showSkillsSelector(
                                title: 'Select Skills You Are Seeking',
                                selectedSkills: _selectedSkillsSeeking,
                                onSelected: (skills) {
                                  setState(() => _selectedSkillsSeeking = skills);
                                },
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _selectedSkillsSeeking.isEmpty
                          ? const Text(
                              'No skills selected. Tap Add to select skills.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSkillsSeeking.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSkillsSeeking.remove(skill);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 16),

                // Terms & Conditions
                Text(
                  'By creating an account, you agree to our Terms & Conditions and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
