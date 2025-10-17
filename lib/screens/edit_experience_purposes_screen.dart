import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_button.dart';

/// Edit Experience and Purposes Screen
class EditExperiencePurposesScreen extends StatefulWidget {
  const EditExperiencePurposesScreen({super.key});

  @override
  State<EditExperiencePurposesScreen> createState() => _EditExperiencePurposesScreenState();
}

class _EditExperiencePurposesScreenState extends State<EditExperiencePurposesScreen> {
  String _selectedExperienceLevel = '';
  List<String> _selectedPurposes = [];
  String? _selectedBusinessPurpose;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _experienceLevels = ['entry', 'mid level', 'senior', 'retired'];
  final List<String> _purposes = [
    'Looking to hire candidates',
    'Looking to get hired',
    'Starting a business',
    'Want to invest in a start up',
  ];
  final List<String> _businessPurposes = ['Fundraising', 'Expertise', 'To Hire'];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _selectedExperienceLevel = args['experienceLevel'] ?? '';
      _selectedPurposes = List<String>.from(args['purposes'] ?? []);
      _selectedBusinessPurpose = args['businessPurpose'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        title: const Text(
          'Edit Experience & Purposes',
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
                  const SizedBox(height: 20),
                  
                  // Form card
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
                    child: Column(
                      children: [
                        // Experience Level picker
                        _buildExperienceLevelPicker(),
                        
                        const SizedBox(height: 30),
                        
                        // Purpose selection
                        _buildPurposeSelection(),
                        
                        const SizedBox(height: 30),
                        
                        // Save button
                        CustomButton(
                          text: 'SAVE CHANGES',
                          onPressed: _isLoading ? null : _saveChanges,
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
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Future<void> _saveChanges() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .update({
        'experienceLevel': _selectedExperienceLevel,
        'purposes': _selectedPurposes,
        'businessPurpose': _selectedBusinessPurpose,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving changes: $e';
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
}

