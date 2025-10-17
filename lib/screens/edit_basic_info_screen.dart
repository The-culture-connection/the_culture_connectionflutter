import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditBasicInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final File? selectedImage;
  final Function() onSave;

  const EditBasicInfoScreen({
    super.key,
    required this.profileData,
    required this.selectedImage,
    required this.onSave,
  });

  @override
  State<EditBasicInfoScreen> createState() => _EditBasicInfoScreenState();
}

class _EditBasicInfoScreenState extends State<EditBasicInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _jobTitleController;
  late TextEditingController _industryController;
  late TextEditingController _universityController;
  late TextEditingController _majorController;
  late TextEditingController _greekOrgController;
  late TextEditingController _skillsController;
  late TextEditingController _businessNeedsController;
  late TextEditingController _experienceLevelController;
  late TextEditingController _minAgeSeekingController;
  late TextEditingController _maxAgeSeekingController;
  
  String _selectedGender = '';
  String _selectedExperienceLevel = '';
  
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData['Full Name'] ?? '');
    _ageController = TextEditingController(text: widget.profileData['Age']?.toString() ?? '');
    _bioController = TextEditingController(text: widget.profileData['Bio'] ?? '');
    _jobTitleController = TextEditingController(text: widget.profileData['Job Title'] ?? '');
    _industryController = TextEditingController(text: widget.profileData['Industry'] ?? '');
    _universityController = TextEditingController(text: widget.profileData['University'] ?? '');
    _majorController = TextEditingController(text: widget.profileData['Major'] ?? '');
    _greekOrgController = TextEditingController(text: widget.profileData['Greek Organization'] ?? '');
    _skillsController = TextEditingController(text: widget.profileData['Skills'] ?? '');
    _businessNeedsController = TextEditingController(text: widget.profileData['businessNeeds'] ?? '');
    _experienceLevelController = TextEditingController(text: widget.profileData['Experience Level'] ?? '');
    _minAgeSeekingController = TextEditingController(text: widget.profileData['minageseeking']?.toString() ?? '18');
    _maxAgeSeekingController = TextEditingController(text: widget.profileData['maxageseeking']?.toString() ?? '50');
    
    _selectedGender = widget.profileData['Gender Identity'] ?? '';
    _selectedExperienceLevel = widget.profileData['Experience Level'] ?? '';
    _selectedImage = widget.selectedImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _industryController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _greekOrgController.dispose();
    _skillsController.dispose();
    _businessNeedsController.dispose();
    _experienceLevelController.dispose();
    _minAgeSeekingController.dispose();
    _maxAgeSeekingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        title: const Text(
          'Edit Basic Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            _buildProfilePhotoSection(),
            
            const SizedBox(height: 30),
            
            // Basic Info Form
            _buildBasicInfoForm(),
            
            const SizedBox(height: 30),
            
            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 4,
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
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Tap to change photo',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        _buildTextField(
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person,
        ),
        
        const SizedBox(height: 20),
        
        // Age
        _buildTextField(
          label: 'Age',
          controller: _ageController,
          icon: Icons.cake,
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 20),
        
        // Bio
        _buildBioField(),
        
        const SizedBox(height: 20),
        
        // Gender Identity
        _buildGenderPicker(),
        
        const SizedBox(height: 20),
        
        // Job Title
        _buildTextField(
          label: 'Job Title',
          controller: _jobTitleController,
          icon: Icons.work,
        ),
        
        const SizedBox(height: 20),
        
        // Industry
        _buildTextField(
          label: 'Industry',
          controller: _industryController,
          icon: Icons.business,
        ),
        
        const SizedBox(height: 20),
        
        // University
        _buildTextField(
          label: 'University',
          controller: _universityController,
          icon: Icons.school,
        ),
        
        const SizedBox(height: 20),
        
        // Major
        _buildTextField(
          label: 'Major',
          controller: _majorController,
          icon: Icons.menu_book,
        ),
        
        const SizedBox(height: 20),
        
        // Greek Organization
        _buildTextField(
          label: 'Greek Organization',
          controller: _greekOrgController,
          icon: Icons.groups,
        ),
        
        const SizedBox(height: 20),
        
        // Skills
        _buildTextField(
          label: 'Skills',
          controller: _skillsController,
          icon: Icons.star,
        ),
        
        const SizedBox(height: 20),
        
        // Business Needs
        _buildTextField(
          label: 'Business Needs',
          controller: _businessNeedsController,
          icon: Icons.business_center,
        ),
        
        const SizedBox(height: 20),
        
        // Experience Level
        _buildExperienceLevelPicker(),
        
        const SizedBox(height: 20),
        
        // Age Range for Matching
        _buildAgeRangeSection(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: Icon(icon, color: const Color(0xFFFF7E00)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7E00)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7E00)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7E00), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BIO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7E00)),
          ),
          child: TextField(
            controller: _bioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tell us about yourself...',
              hintStyle: TextStyle(color: Colors.white60),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7E00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SAVE CHANGES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
      ),
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

  Future<void> _saveProfile() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Map<String, dynamic> updatedData = {
        'Full Name': _nameController.text.trim(),
        'Age': int.tryParse(_ageController.text.trim()) ?? 0,
        'Bio': _bioController.text.trim(),
        'Gender Identity': _selectedGender,
        'Job Title': _jobTitleController.text.trim(),
        'Industry': _industryController.text.trim(),
        'University': _universityController.text.trim(),
        'Major': _majorController.text.trim(),
        'Greek Organization': _greekOrgController.text.trim(),
        'Skills': _skillsController.text.trim(),
        'businessNeeds': _businessNeedsController.text.trim(),
        'Experience Level': _selectedExperienceLevel,
        'minageseeking': int.tryParse(_minAgeSeekingController.text.trim()) ?? 18,
        'maxageseeking': int.tryParse(_maxAgeSeekingController.text.trim()) ?? 50,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Handle photo upload
      if (_selectedImage != null) {
        final imageUrl = await _uploadProfileImage(_selectedImage!, user.uid);
        if (imageUrl != null) {
          updatedData['photoURL'] = imageUrl;
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .set(updatedData, SetOptions(merge: true));

      setState(() {
        _isSaving = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Call the parent's onSave callback
      widget.onSave();

      // Navigate back
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGenderPicker() {
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
              value: _selectedGender.isNotEmpty ? _selectedGender : null,
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
              items: const [
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Nonbinary',
                  child: Text('Nonbinary'),
                ),
                DropdownMenuItem(
                  value: 'Prefer not to say',
                  child: Text('Prefer not to say'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
            ),
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
              items: const [
                DropdownMenuItem(
                  value: 'Entry',
                  child: Text('Entry'),
                ),
                DropdownMenuItem(
                  value: 'Mid',
                  child: Text('Mid'),
                ),
                DropdownMenuItem(
                  value: 'Senior',
                  child: Text('Senior'),
                ),
                DropdownMenuItem(
                  value: 'Retired',
                  child: Text('Retired'),
                ),
              ],
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

  Widget _buildAgeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AGE RANGE FOR MATCHING',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Min Age',
                controller: _minAgeSeekingController,
                icon: Icons.trending_down,
                keyboardType: TextInputType.number,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildTextField(
                label: 'Max Age',
                controller: _maxAgeSeekingController,
                icon: Icons.trending_up,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
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
