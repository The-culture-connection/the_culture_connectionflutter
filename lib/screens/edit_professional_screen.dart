import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfessionalScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Function() onSave;

  const EditProfessionalScreen({
    super.key,
    required this.profileData,
    required this.onSave,
  });

  @override
  State<EditProfessionalScreen> createState() => _EditProfessionalScreenState();
}

class _EditProfessionalScreenState extends State<EditProfessionalScreen> {
  late TextEditingController _jobTitleController;
  late TextEditingController _industryController;
  late TextEditingController _universityController;
  late TextEditingController _majorController;
  late TextEditingController _greekOrgController;
  late TextEditingController _otherOrgsController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController(text: widget.profileData['Job Title'] ?? '');
    _industryController = TextEditingController(text: widget.profileData['Industry'] ?? '');
    _universityController = TextEditingController(text: widget.profileData['University'] ?? '');
    _majorController = TextEditingController(text: widget.profileData['Major'] ?? '');
    _greekOrgController = TextEditingController(text: widget.profileData['Greek Organization'] ?? '');
    _otherOrgsController = TextEditingController(text: widget.profileData['Other Organizations'] ?? '');
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _industryController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _greekOrgController.dispose();
    _otherOrgsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        title: const Text(
          'Edit Professional',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Info Form
            _buildProfessionalForm(),
            
            const SizedBox(height: 30),
            
            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        
        // Other Organizations
        _buildTextField(
          label: 'Other Organizations',
          controller: _otherOrgsController,
          icon: Icons.group_work,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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

  Future<void> _saveProfile() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Map<String, dynamic> updatedData = {
        'Job Title': _jobTitleController.text.trim(),
        'Industry': _industryController.text.trim(),
        'University': _universityController.text.trim(),
        'Major': _majorController.text.trim(),
        'Greek Organization': _greekOrgController.text.trim(),
        'Other Organizations': _otherOrgsController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

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
          content: Text('Professional info updated successfully!'),
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
}


