import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../constants/skills_categories.dart';
import '../constants/experience_levels.dart';
import '../constants/app_colors.dart';

class EditProfileSimpleScreen extends StatefulWidget {
  const EditProfileSimpleScreen({super.key});

  @override
  State<EditProfileSimpleScreen> createState() => _EditProfileSimpleScreenState();
}

class _EditProfileSimpleScreenState extends State<EditProfileSimpleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  
  // State
  UserProfile? _userProfile;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Selected values
  String _selectedExperienceLevel = '';
  String _selectedGenderPreference = 'Everyone';
  Set<String> _selectedSkillsOffering = {};
  Set<String> _selectedSkillsSeeking = {};
  
  // Available options
  final List<String> _experienceLevels = ExperienceLevels.all;
  final List<String> _genderPreferences = ['Everyone', 'Male', 'Female', 'Nonbinary'];
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _jobTitleController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;
      
      final profile = await _firestoreService.getUserProfile(userId);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.fullName;
          _ageController.text = profile.age.toString();
          _jobTitleController.text = profile.jobTitle;
          _minAgeController.text = profile.minAgeSeeking.toString();
          _maxAgeController.text = profile.maxAgeSeeking.toString();
          _selectedExperienceLevel = profile.experienceLevel;
          _selectedGenderPreference = profile.genderPreferences;
          _selectedSkillsOffering = Set.from(profile.skillsOffering);
          _selectedSkillsSeeking = Set.from(profile.skillsSeeking);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
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
  
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 18 || age > 100) {
      _showError('Please enter a valid age (18-100)');
      return;
    }
    
    final minAge = int.tryParse(_minAgeController.text.trim());
    final maxAge = int.tryParse(_maxAgeController.text.trim());
    if (minAge == null || maxAge == null || minAge < 18 || maxAge > 100 || minAge > maxAge) {
      _showError('Please enter valid age range (18-100)');
      return;
    }
    
    if (_selectedExperienceLevel.isEmpty) {
      _showError('Please select your experience level');
      return;
    }
    
    if (_selectedSkillsOffering.isEmpty) {
      _showError('Please select at least one skill you can offer');
      return;
    }
    
    if (_selectedSkillsSeeking.isEmpty) {
      _showError('Please select at least one skill you are seeking');
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final userId = _authService.currentUserId!;
      
      // Upload new image if selected
      String photoURL = _userProfile!.photoURL;
      if (_selectedImage != null) {
        photoURL = await _storageService.uploadProfilePhoto(userId, _selectedImage!);
      }
      
      // Update profile
      final updatedProfile = _userProfile!.copyWith(
        fullName: _nameController.text.trim(),
        age: age,
        jobTitle: _jobTitleController.text.trim(),
        experienceLevel: _selectedExperienceLevel,
        skillsOffering: _selectedSkillsOffering.toList(),
        skillsSeeking: _selectedSkillsSeeking.toList(),
        genderPreferences: _selectedGenderPreference,
        minAgeSeeking: minAge,
        maxAgeSeeking: maxAge,
        photoURL: photoURL,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUserProfile(updatedProfile.userId, updatedProfile.toFirestore());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Information saved successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error saving profile: $e');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  double _calculateProfileCompletion() {
    if (_userProfile == null) return 0.0;
    
    double completion = 0.0;
    int totalFields = 0;
    
    // Full Name (required)
    totalFields++;
    if (_nameController.text.trim().isNotEmpty) completion++;
    
    // Age (required)
    totalFields++;
    final age = int.tryParse(_ageController.text.trim());
    if (age != null && age > 0) completion++;
    
    // Job Title (required)
    totalFields++;
    if (_jobTitleController.text.trim().isNotEmpty) completion++;
    
    // Experience Level (required)
    totalFields++;
    if (_selectedExperienceLevel.isNotEmpty) completion++;
    
    // At least one skill offering (should have at least one)
    totalFields++;
    if (_selectedSkillsOffering.isNotEmpty) completion++;
    
    // At least one skill seeking (should have at least one)
    totalFields++;
    if (_selectedSkillsSeeking.isNotEmpty) completion++;
    
    return totalFields > 0 ? completion / totalFields : 0.0;
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1d1d1e),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) {
                // Navigate to welcome screen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.electricOrange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1d1d1e),
        title: const Text(
          'Delete Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your profile? This action cannot be undone and will permanently remove all your data.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUserProfile();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserProfile() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      setState(() => _isSaving = true);

      // Delete user data from Firestore
      await _firestoreService.deleteUserProfile(userId);

      // Sign out the user
      await _authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to welcome screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error deleting profile: $e');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0a0a),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.electricOrange,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.electricOrange,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.electricOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo with Completion Meter
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular progress indicator for profile completion
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _calculateProfileCompletion(),
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Profile Photo
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
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _userProfile?.photoURL.isNotEmpty == true
                              ? ClipOval(
                                  child: Image.network(
                                    _userProfile!.photoURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: AppColors.electricOrange,
                                ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Profile Completion Percentage
            Center(
              child: Text(
                'Profile ${(_calculateProfileCompletion() * 100).toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Full Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              onChanged: () => setState(() {}), // Update completion meter
            ),
            
            const SizedBox(height: 16),
            
            // Age
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              onChanged: () => setState(() {}), // Update completion meter
            ),
            
            const SizedBox(height: 16),
            
            // Job Title
            _buildTextField(
              controller: _jobTitleController,
              label: 'Job Title',
              icon: Icons.work,
              onChanged: () => setState(() {}), // Update completion meter
            ),
            
            const SizedBox(height: 16),
            
            // Experience Level
            _buildDropdownField(
              label: 'Experience Level',
              value: _selectedExperienceLevel,
              items: _experienceLevels,
              onChanged: (value) => setState(() => _selectedExperienceLevel = value ?? ''),
              icon: Icons.trending_up,
            ),
            
            const SizedBox(height: 16),
            
            // Skills Offering
            _buildSkillsSection(
              title: 'Skills Offering',
              subtitle: 'What skills can you offer?',
              selectedSkills: _selectedSkillsOffering,
              onSkillsChanged: (skills) => setState(() => _selectedSkillsOffering = skills),
              icon: Icons.psychology,
            ),
            
            const SizedBox(height: 16),
            
            // Skills Seeking
            _buildSkillsSection(
              title: 'Skills Seeking',
              subtitle: 'What skills are you looking for?',
              selectedSkills: _selectedSkillsSeeking,
              onSkillsChanged: (skills) => setState(() => _selectedSkillsSeeking = skills),
              icon: Icons.search,
            ),
            
            const SizedBox(height: 16),
            
            // Gender Preferences
            _buildDropdownField(
              label: 'Gender Preferences',
              value: _selectedGenderPreference,
              items: _genderPreferences,
              onChanged: (value) => setState(() => _selectedGenderPreference = value ?? 'Everyone'),
              icon: Icons.people,
            ),
            
            const SizedBox(height: 16),
            
            // Min Age Seeking
            _buildTextField(
              controller: _minAgeController,
              label: 'Min Age Seeking',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Max Age Seeking
            _buildTextField(
              controller: _maxAgeController,
              label: 'Max Age Seeking',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 32),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Delete Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleteProfile,
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text(
                  'DELETE PROFILE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => onChanged?.call(),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: AppColors.electricOrange),
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
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: AppColors.electricOrange),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: const Color(0xFF1d1d1e),
            style: const TextStyle(color: Colors.white),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSkillsSection({
    required String title,
    required String subtitle,
    required Set<String> selectedSkills,
    required ValueChanged<Set<String>> onSkillsChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        
        // Selected skills display
        if (selectedSkills.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.electricOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.electricOrange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        final newSkills = Set<String>.from(selectedSkills);
                        newSkills.remove(skill);
                        onSkillsChanged(newSkills);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        
        // Add skills button
        ElevatedButton.icon(
          onPressed: () => _showSkillsPicker(title, selectedSkills, onSkillsChanged),
          icon: Icon(icon, color: AppColors.electricOrange),
          label: Text(
            selectedSkills.isEmpty ? 'Add $title' : 'Edit $title',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.3),
            side: BorderSide(color: AppColors.electricOrange.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
  
  void _showSkillsPicker(String title, Set<String> currentSkills, ValueChanged<Set<String>> onChanged) {
    showDialog(
      context: context,
      builder: (context) => SkillsPickerDialog(
        title: title,
        currentSkills: currentSkills,
        onSkillsChanged: onChanged,
      ),
    );
  }
}

class SkillsPickerDialog extends StatefulWidget {
  final String title;
  final Set<String> currentSkills;
  final ValueChanged<Set<String>> onSkillsChanged;
  
  const SkillsPickerDialog({
    super.key,
    required this.title,
    required this.currentSkills,
    required this.onSkillsChanged,
  });
  
  @override
  State<SkillsPickerDialog> createState() => _SkillsPickerDialogState();
}

class _SkillsPickerDialogState extends State<SkillsPickerDialog> {
  late Set<String> _selectedSkills;
  
  @override
  void initState() {
    super.initState();
    _selectedSkills = Set.from(widget.currentSkills);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1d1d1e),
      title: Text(
        'Select ${widget.title}',
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: SkillsCategories.categories.entries.map((entry) {
              return ExpansionTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                iconColor: AppColors.electricOrange,
                collapsedIconColor: Colors.white,
                children: entry.value.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return CheckboxListTile(
                    title: Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    value: isSelected,
                    activeColor: AppColors.electricOrange,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSkillsChanged(_selectedSkills);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricOrange,
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
