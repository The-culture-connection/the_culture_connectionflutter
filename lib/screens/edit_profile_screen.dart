import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_basic_info_screen.dart';
import 'edit_professional_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Profile data
  Map<String, dynamic> profileData = {
    'Full Name': '',
    'Age': 0,
    'Bio': '',
    'Job Title': '',
    'Industry': '',
    'University': '',
    'Major': '',
    'Greek Organization': '',
    'Other Organizations': '',
    'Connection Preference': 'Mentee',
    'Networking Goal': '',
    'Relationship Goal': '',
    'Friendship Goal': '',
    'Gender Identity': '',
    'Gender Preferences': 'Everyone',
    'minageseeking': 18,
    'maxageseeking': 50,
    'matchByIndustry': 'No',
    'Experience Level': '',
    'Interests and Hobbies': '',
    'Skills': '',
    'Areas of Improvement': '',
    'Personality Traits': '',
    'Relationship Status': '',
    // New fields from registration
    'experienceLevel': '',
    'mainCategories': [],
    'categories': [],
    'subCategories': [],
    'skillsSeeking': [],
    'purposes': [],
    'businessPurpose': '',
    'location': null,
  };

  File? selectedImage;
  bool isSaving = false;
  String? uploadStatus;
  bool showSaveSuccess = false;

  // Multi-select data
  Set<String> selectedHobbies = {};
  Set<String> selectedSkills = {};
  Set<String> selectedImprovements = {};

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        title: const Text(
          'Edit Profile',
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
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement profile preview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile preview coming soon!'),
                  backgroundColor: Color(0xFFFF7E00),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, color: Color(0xFFFF7E00), size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Preview',
                  style: TextStyle(
                    color: Color(0xFFFF7E00),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Profile Photo and Name Section
                _buildProfileHeader(),
                
                // Points Button
                _buildPointsButton(),
                
                // Edit Sections
                _buildEditSections(),
                
                // Footer Buttons
                _buildFooterButtons(),
              ],
            ),
          ),
          
          // Success Message Overlay
          if (showSaveSuccess)
            _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Photo
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
                child: selectedImage != null
                    ? Image.file(
                        selectedImage!,
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
          
          // Name
          Text(
            profileData['Full Name']?.isNotEmpty == true 
                ? profileData['Full Name'] 
                : 'Full Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to points/rewards screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Points system coming soon!'),
              backgroundColor: Color(0xFFFF7E00),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.star,
              color: Color(0xFFFF7E00),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'POINTS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSections() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildEditButton(
            icon: Icons.person,
            title: 'EDIT BASIC INFO',
            onTap: () => _navigateToEditSection('basic'),
          ),
          
          _buildEditButton(
            icon: Icons.work,
            title: 'EDIT PROFESSIONAL',
            onTap: () => _navigateToEditSection('professional'),
          ),
          
          _buildEditButton(
            icon: Icons.people,
            title: 'EDIT MENTORSHIP',
            onTap: () => _navigateToEditSection('mentorship'),
          ),
          
          _buildEditButton(
            icon: Icons.settings,
            title: 'EDIT PREFERENCES',
            onTap: () => _navigateToEditSection('preferences'),
          ),
          
          _buildEditButton(
            icon: Icons.favorite,
            title: 'EDIT MATCHING',
            onTap: () => _navigateToEditSection('matching'),
          ),
          
          _buildEditButton(
            icon: Icons.info,
            title: 'EDIT ADDITIONAL INFO',
            onTap: () => _navigateToEditSection('additional'),
          ),
          
          _buildEditButton(
            icon: Icons.star,
            title: 'EDIT SKILLS OFFERING',
            onTap: () => _navigateToEditSection('skills-offering'),
          ),
          
          _buildEditButton(
            icon: Icons.search,
            title: 'EDIT SKILLS SEEKING',
            onTap: () => _navigateToEditSection('skills-seeking'),
          ),
          
          _buildEditButton(
            icon: Icons.location_on,
            title: 'EDIT LOCATION',
            onTap: () => _navigateToEditSection('location'),
          ),
          
          _buildEditButton(
            icon: Icons.work,
            title: 'EDIT EXPERIENCE & PURPOSES',
            onTap: () => _navigateToEditSection('experience-purposes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF7E00),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _deleteProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  child: const Text(
                    'DELETE PROFILE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF7E7BEF), width: 2),
                    ),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Changes Saved Successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToEditSection(String section) {
    switch (section) {
      case 'basic':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditBasicInfoScreen(
              profileData: profileData,
              selectedImage: selectedImage,
              onSave: saveProfile,
            ),
          ),
        );
        break;
      case 'professional':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfessionalScreen(
              profileData: profileData,
              onSave: saveProfile,
            ),
          ),
        );
        break;
      case 'mentorship':
        // TODO: Implement mentorship edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit mentorship section coming soon!'),
            backgroundColor: Color(0xFFFF7E00),
          ),
        );
        break;
      case 'preferences':
        // TODO: Implement preferences edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit preferences section coming soon!'),
            backgroundColor: Color(0xFFFF7E00),
          ),
        );
        break;
      case 'matching':
        // TODO: Implement matching edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit matching section coming soon!'),
            backgroundColor: Color(0xFFFF7E00),
          ),
        );
        break;
      case 'additional':
        // TODO: Implement additional info edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit additional info section coming soon!'),
            backgroundColor: Color(0xFFFF7E00),
          ),
        );
        break;
      case 'skills-offering':
        // Navigate to skills offering edit
        Navigator.of(context).pushNamed('/skills-main-categories', arguments: {
          'type': 'offering',
          'selectedMainCategories': profileData['mainCategories'] ?? [],
          'selectedSubCategories': profileData['subCategories'] ?? [],
          'isEditMode': true,
        });
        break;
      case 'skills-seeking':
        // Navigate to skills seeking edit
        Navigator.of(context).pushNamed('/skills-seeking-main', arguments: {
          'type': 'seeking',
          'selectedMainCategories': profileData['categories'] ?? [],
          'selectedSubCategories': profileData['skillsSeeking'] ?? [],
          'isEditMode': true,
        });
        break;
      case 'location':
        // Navigate to location edit
        Navigator.of(context).pushNamed('/location', arguments: {
          'isEditMode': true,
          'location': profileData['location'],
        });
        break;
      case 'experience-purposes':
        // Navigate to experience and purposes edit
        Navigator.of(context).pushNamed('/edit-experience-purposes', arguments: {
          'experienceLevel': profileData['experienceLevel'],
          'purposes': profileData['purposes'] ?? [],
          'businessPurpose': profileData['businessPurpose'],
        });
        break;
    }
  }

  // Image selection
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
          selectedImage = File(image.path);
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

  // Data management methods
  Future<void> fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        
        setState(() {
          // Parse Firestore data
          for (String key in profileData.keys) {
            if (data.containsKey(key)) {
              profileData[key] = data[key];
            }
          }
          
          // Handle multi-select fields
          if (data['Interests and Hobbies'] != null) {
            selectedHobbies = Set<String>.from(
              (data['Interests and Hobbies'] as String).split(', ')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
            );
          }
          
          if (data['Skills'] != null) {
            selectedSkills = Set<String>.from(
              (data['Skills'] as String).split(', ')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
            );
          }
          
          if (data['Areas of Improvement'] != null) {
            selectedImprovements = Set<String>.from(
              (data['Areas of Improvement'] as String).split(', ')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
            );
          }
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        isSaving = true;
        uploadStatus = null;
      });

      Map<String, dynamic> updatedProfileData = Map.from(profileData);

      // Handle photo upload
      if (selectedImage != null) {
        final imageUrl = await _uploadProfileImage(selectedImage!, user.uid);
        if (imageUrl != null) {
          updatedProfileData['photoURL'] = imageUrl;
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .set(updatedProfileData, SetOptions(merge: true));

      setState(() {
        isSaving = false;
        showSaveSuccess = true;
      });

      // Hide success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showSaveSuccess = false;
          });
        }
      });

    } catch (e) {
      setState(() {
        isSaving = false;
        uploadStatus = 'Error saving profile: $e';
      });
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

  void _deleteProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Delete Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your profile? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Pop to root and let ContentView handle authentication state
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Color(0xFF7E7BEF)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .delete();

      // Delete user's profile images from Storage
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');
        await storageRef.delete();
      } catch (e) {
        print('Error deleting profile image: $e');
        // Continue even if image deletion fails
      }

      // Delete the user account
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to auth screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
