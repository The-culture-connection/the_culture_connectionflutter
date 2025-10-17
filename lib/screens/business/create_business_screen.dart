import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/business.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Therapy & Wellness',
    'Financial Services',
    'Retail & Fashion',
    'Food & Beverage',
    'Technology',
    'Legal Services',
    'Real Estate',
    'Education',
    'Beauty & Personal Care',
    'Arts & Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a business'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final business = Business(
        businessId: '', // Will be set by Firestore
        businessName: _nameController.text.trim(),
        businessCategory: _selectedCategory!,
        businessDescription: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        ownerUserId: currentUserId,
        businessPhone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        businessEmail: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        businessWebsite: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        businessAddress: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        createdAt: DateTime.now(),
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createBusiness(business);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating business: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d1d1e),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Business',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1d1d1e),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Business Information',
              style: TextStyle(
                color: AppColors.electricOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Business Name
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: 'Business Name *',
                icon: Icons.business,
              ),
              validator: Validators.required,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color(0xFF2a2a2e),
              decoration: _inputDecoration(
                label: 'Category *',
                icon: Icons.category,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: _inputDecoration(
                label: 'Description',
                icon: Icons.description,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Contact Information',
              style: TextStyle(
                color: AppColors.electricOrange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: 'Phone Number',
                icon: Icons.phone,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: 'Email Address',
                icon: Icons.email,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.email(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Website
            TextFormField(
              controller: _websiteController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(
                label: 'Website',
                icon: Icons.language,
                hint: 'example.com',
              ),
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: _inputDecoration(
                label: 'Address',
                icon: Icons.location_on,
              ),
            ),
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CREATE BUSINESS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      prefixIcon: Icon(icon, color: AppColors.electricOrange),
      filled: true,
      fillColor: const Color(0xFF2a2a2e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.deepPurple.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.electricOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
