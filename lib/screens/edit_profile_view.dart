import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_basic_info_screen.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
    'selectedIndustry': '',
    'Experience Level': '',
    'Interests and Hobbies': '',
    'Skills': '',
    'Areas of Improvement': '',
    'Personality Traits': '',
    'Relationship Status': ''
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
    _tabController = TabController(length: 3, vsync: this);
    fetchProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // Preview Button
          TextButton(
            onPressed: () => _showProfilePreview(),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF7E00),
          labelColor: const Color(0xFFFF7E00),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Filtering'),
            Tab(text: 'Points'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildFilteringTab(),
              _buildPointsTab(),
            ],
          ),
          
          // Success Message Overlay
          if (showSaveSuccess)
            _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Photo and Name Section
          _buildProfileHeader(),
          
          const SizedBox(height: 30),
          
          // Edit Basic Info Button
          _buildEditButton(
            icon: Icons.person,
            title: 'EDIT BASIC INFO',
            onTap: () => _navigateToEditBasicInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtering Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Age Range Filter
          _buildAgeRangeFilter(),
          
          const SizedBox(height: 30),
          
          // Gender Filter
          _buildGenderFilter(),
          
          const SizedBox(height: 30),
          
          // Industry Filter
          _buildIndustryFilter(),
          
          const SizedBox(height: 30),
          
          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildPointsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Points Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF7E00), width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFF7E00),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profileData['points'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFFFF7E00),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Earn points by connecting with others, attending events, and participating in the community!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Points History Button
          _buildEditButton(
            icon: Icons.history,
            title: 'VIEW POINTS HISTORY',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Points history coming soon!'),
                  backgroundColor: Color(0xFFFF7E00),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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

  Widget _buildEditButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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

  Widget _buildAgeRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AGE RANGE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Min Age',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '18',
                      hintStyle: const TextStyle(color: Colors.white60),
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
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        profileData['minageseeking'] = int.tryParse(value) ?? 18;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Age',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '50',
                      hintStyle: const TextStyle(color: Colors.white60),
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
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        profileData['maxageseeking'] = int.tryParse(value) ?? 50;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER PREFERENCES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ['Everyone', 'Male', 'Female', 'Non-binary'].map((gender) {
            final isSelected = profileData['Gender Preferences'] == gender;
            return GestureDetector(
              onTap: () {
                setState(() {
                  profileData['Gender Preferences'] = gender;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF7E00) : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF7E00) : Colors.white30,
                  ),
                ),
                child: Text(
                  gender,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIndustryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INDUSTRY FILTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Text(
                'Match by Industry',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Switch(
              value: profileData['matchByIndustry'] == 'Yes',
              onChanged: (value) {
                setState(() {
                  profileData['matchByIndustry'] = value ? 'Yes' : 'No';
                });
              },
              activeColor: const Color(0xFFFF7E00),
            ),
          ],
        ),
        
        // Industry Selection (only show when match by industry is enabled)
        if (profileData['matchByIndustry'] == 'Yes') ...[
          const SizedBox(height: 20),
          _buildIndustrySelection(),
        ],
      ],
    );
  }

  Widget _buildIndustrySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT INDUSTRY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
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
              value: profileData['selectedIndustry'].isNotEmpty ? profileData['selectedIndustry'] : null,
              hint: const Text(
                'Choose Industry',
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
                  value: '🔧 Technology & Engineering',
                  child: Text('🔧 Technology & Engineering'),
                ),
                DropdownMenuItem(
                  value: '📢 Marketing, Branding & PR',
                  child: Text('📢 Marketing, Branding & PR'),
                ),
                DropdownMenuItem(
                  value: '💼 Business, Finance & Consulting',
                  child: Text('💼 Business, Finance & Consulting'),
                ),
                DropdownMenuItem(
                  value: '🧩 Leadership & Organizational Development',
                  child: Text('🧩 Leadership & Organizational Development'),
                ),
                DropdownMenuItem(
                  value: '💡 Entrepreneurship & Startups',
                  child: Text('💡 Entrepreneurship & Startups'),
                ),
                DropdownMenuItem(
                  value: '🎨 Creative, Media & Arts',
                  child: Text('🎨 Creative, Media & Arts'),
                ),
                DropdownMenuItem(
                  value: '🧘🏽‍♀️ Health, Wellness & Lifestyle',
                  child: Text('🧘🏽‍♀️ Health, Wellness & Lifestyle'),
                ),
                DropdownMenuItem(
                  value: '🏫 Education & Mentorship',
                  child: Text('🏫 Education & Mentorship'),
                ),
                DropdownMenuItem(
                  value: '🏠 Trades & Services',
                  child: Text('🏠 Trades & Services'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    profileData['selectedIndustry'] = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7E00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SAVE FILTERING PREFERENCES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
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
  void _navigateToEditBasicInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBasicInfoScreen(
          profileData: profileData,
          selectedImage: selectedImage,
          onSave: _saveProfile,
        ),
      ),
    );
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

  Future<void> _saveProfile() async {
    try {
      setState(() {
        isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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

  void _showProfilePreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Profile Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Profile Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Photo
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFFF7E00).withOpacity(0.1),
                      child: selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                selectedImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : profileData['photoURL'] != null && profileData['photoURL'].isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileData['photoURL'],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildInitialsAvatar();
                                    },
                                  ),
                                )
                              : _buildInitialsAvatar(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Name and Age
                    Text(
                      profileData['Full Name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Age: ${profileData['Age'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bio
                    if (profileData['Bio'] != null && profileData['Bio'].isNotEmpty) ...[
                      const Text(
                        'Bio:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileData['Bio'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Job Title and Industry
                    if (profileData['Job Title'] != null && profileData['Job Title'].isNotEmpty) ...[
                      Text(
                        'Job Title: ${profileData['Job Title']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    if (profileData['Industry'] != null && profileData['Industry'].isNotEmpty) ...[
                      Text(
                        'Industry: ${profileData['Industry']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Major
                    if (profileData['Major'] != null && profileData['Major'].isNotEmpty) ...[
                      Text(
                        'Major: ${profileData['Major']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Greek Organization
                    if (profileData['Greek Organization'] != null && profileData['Greek Organization'].isNotEmpty) ...[
                      Text(
                        'Greek Organization: ${profileData['Greek Organization']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Skills
                    if (profileData['Skills'] != null && profileData['Skills'].isNotEmpty) ...[
                      const Text(
                        'Skills:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileData['Skills'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final name = profileData['Full Name'] ?? 'No Name';
    final initials = name.isNotEmpty 
        ? name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').join('').toUpperCase()
        : 'U';
    
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF7E00),
      ),
    );
  }
}
