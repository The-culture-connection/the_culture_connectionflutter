import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business.dart';
import '../services/business_service.dart';

class BlackBusinessScreen extends StatefulWidget {
  const BlackBusinessScreen({super.key});

  @override
  State<BlackBusinessScreen> createState() => _BlackBusinessScreenState();
}

class _BlackBusinessScreenState extends State<BlackBusinessScreen> {
  final BusinessService _businessService = BusinessService();
  List<Business> _businesses = [];
  List<Business> _filteredBusinesses = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchText = '';
  String _selectedCity = '';
  bool _showCityPicker = false;
  bool _showCategoryPicker = false;
  String _selectedMainCategory = '';
  String _selectedSubCategory = '';
  bool _showSubCategoryPicker = false;
  int _currentStep = 0; // 0: main category, 1: subcategory, 2: city, 3: results
  String _sortBy = 'name'; // 'name', 'rating', 'distance'
  bool _sortAscending = true;

  final List<String> _cities = [
    'Cincinnati',
    'Columbus',
    'Dayton',
    // Add more cities as they become available in your database
  ];

  final Map<String, List<String>> _categories = {
    '🧠 Health & Wellness': [
      'Therapy & Counseling',
      'Mental Health Services',
      'Physical Therapy / Rehabilitation',
      'Fitness & Personal Training',
      'Nutrition / Meal Planning',
      'Chiropractic / Acupuncture',
      'Spa & Massage Services',
    ],
    '💼 Professional & Financial Services': [
      'Accounting & Tax Preparation',
      'Financial Planning & Investment',
      'Legal Services / Law Firms',
      'Insurance Agencies',
      'Business Consulting',
      'Real Estate Agents / Brokers',
      'IT & Tech Support',
      'Marketing / Branding / PR',
    ],
    '🛍️ Retail & Shopping': [
      'Clothing & Apparel',
      'Beauty Supply Stores',
      'Jewelry & Accessories',
      'Home Décor & Furniture',
      'Electronics / Tech',
      'Bookstores / Stationery',
      'Gift Shops',
    ],
    '🍽️ Food & Beverage': [
      'Restaurants & Cafés',
      'Catering Services',
      'Food Trucks',
      'Bakeries / Dessert Shops',
      'Bars & Lounges',
      'Meal Prep Businesses',
    ],
    '🎨 Creative & Media': [
      'Photography / Videography',
      'Graphic Design / Branding',
      'Music / Production Studios',
      'Publishing & Writing Services',
      'Event Planning & Decor',
      'Art Galleries / Craft Businesses',
    ],
    '🏫 Education & Training': [
      'Tutoring & Test Prep',
      'Childcare / Daycare',
      'Professional Coaching',
      'Trade Schools',
      'Online Courses / E-learning Platforms',
    ],
    '🧰 Home & Trades': [
      'Construction / Contracting',
      'Landscaping & Lawn Care',
      'Cleaning Services',
      'Plumbing / Electrical / HVAC',
      'Moving & Storage',
    ],
    '🌍 Community & Nonprofit': [
      'Nonprofit Organizations',
      'Churches / Faith-Based Groups',
      'Charities & Mutual Aid',
      'Social Justice / Advocacy',
      'Mentorship Programs',
    ],
    '🚗 Transportation & Automotive': [
      'Car Dealerships',
      'Auto Repair & Detailing',
      'Rideshare / Delivery Services',
      'Logistics / Trucking',
    ],
    '💅🏽 Beauty & Personal Care': [
      'Hair Salons & Barbershops',
      'Nail Technicians',
      'Estheticians / Skincare',
      'Makeup Artists',
      'Cosmetic Brands',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use getAllBusinesses method which works with your Firestore structure
      final businesses = await _businessService.getAllBusinesses(
        latitude: 39.1031, // Default to Cincinnati coordinates
        longitude: -84.5120,
        limit: 100,
      );
      
      if (mounted) {
        setState(() {
          _businesses = businesses;
          _filteredBusinesses = businesses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterBusinesses() {
    setState(() {
      _filteredBusinesses = _businesses.where((business) {
        // Text search (name, category, description, address)
        final matchesSearch = _searchText.isEmpty ||
            business.name.toLowerCase().contains(_searchText.toLowerCase()) ||
            business.category.toLowerCase().contains(_searchText.toLowerCase()) ||
            business.description.toLowerCase().contains(_searchText.toLowerCase()) ||
            business.address.toLowerCase().contains(_searchText.toLowerCase());
        
        // City filter
        final matchesCity = _selectedCity.isEmpty || 
            business.address.toLowerCase().contains(_selectedCity.toLowerCase());
        
        // Category filter - search for subcategory keywords in both category and description
        final matchesCategory = _selectedSubCategory.isEmpty ||
            _searchForSubcategoryKeywords(business, _selectedSubCategory);
        
        return matchesSearch && matchesCity && matchesCategory;
      }).toList();
    });
  }

  void _selectMainCategory(String category) {
    setState(() {
      _selectedMainCategory = category;
      _selectedSubCategory = '';
      _showCategoryPicker = false;
      _currentStep = 1; // Move to subcategory step
    });
  }

  void _selectSubCategory(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
      _showSubCategoryPicker = false;
      _currentStep = 2; // Move to city step
    });
  }

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
      _showCityPicker = false;
      _currentStep = 3; // Move to results step
    });
    _loadBusinessesByCity(city);
  }

  void _clearFilters() {
    setState(() {
      _searchText = '';
      _selectedCity = '';
      _selectedMainCategory = '';
      _selectedSubCategory = '';
      _showCityPicker = false;
      _showCategoryPicker = false;
      _showSubCategoryPicker = false;
      _currentStep = 0;
    });
    _filterBusinesses();
  }

  void _goBack() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        if (_currentStep == 0) {
          _selectedMainCategory = '';
          _selectedSubCategory = '';
        } else if (_currentStep == 1) {
          _selectedSubCategory = '';
        } else if (_currentStep == 2) {
          _selectedCity = '';
        }
      }
    });
  }

  Future<void> _loadBusinessesByCity(String city) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final businesses = await _businessService.getBusinessesByCity(
        city,
        latitude: 39.1031, // Default to Cincinnati coordinates
        longitude: -84.5120,
        limit: 100,
      );
      
      if (mounted) {
        setState(() {
          _businesses = businesses;
          // Filter by subcategory keywords in description
          _filteredBusinesses = businesses.where((business) {
            final description = business.description.toLowerCase();
            final subCategory = _selectedSubCategory.toLowerCase();
            
            // Check if any word from the subcategory appears in the description
            final subCategoryWords = subCategory.split(' ');
            return subCategoryWords.any((word) => 
              word.length > 2 && description.contains(word)
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Title and Badge
                _buildTitleSection(),
                
                // Step-by-step content
                Expanded(
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMainCategoryStep();
      case 1:
        return _buildSubCategoryStep();
      case 2:
        return _buildCityStep();
      case 3:
        return _buildResultsStep();
      default:
        return _buildMainCategoryStep();
    }
  }

  Widget _buildMainCategoryStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Category:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final mainCategory = _categories.keys.elementAt(index);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _selectMainCategory(mainCategory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1d1d1e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            mainCategory,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Select Subcategory:',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedMainCategory,
            style: const TextStyle(
              color: Color(0xFFFF7E00),
              fontSize: 18,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _categories[_selectedMainCategory]!.length,
              itemBuilder: (context, index) {
                final subCategory = _categories[_selectedMainCategory]![index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _selectSubCategory(subCategory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1d1d1e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            subCategory,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Select City:',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_selectedMainCategory} > $_selectedSubCategory',
            style: const TextStyle(
              color: Color(0xFFFF7E00),
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _selectCity(city),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1d1d1e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFF7E00), width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFF7E00)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStep() {
    return Column(
      children: [
        // Filter summary
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1d1d1e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7E00), width: 2),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results for:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      '$_selectedSubCategory in $_selectedCity',
                      style: const TextStyle(
                        color: Color(0xFFFF7E00),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, color: Colors.white),
              ),
            ],
          ),
        ),
        
        // Search and Sort Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search businesses...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF7E00)),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchText = '';
                              _filterBusinesses();
                            });
                          },
                          icon: const Icon(Icons.clear, color: Colors.grey),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
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
                ),
                style: const TextStyle(color: Colors.white),
              ),
              
              const SizedBox(height: 12),
              
              // Sort Controls
              Row(
                children: [
                  const Text(
                    'Sort by:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                            _sortBusinesses();
                          });
                        }
                      },
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'rating', child: Text('Rating')),
                        DropdownMenuItem(value: 'distance', child: Text('Distance')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                        _sortBusinesses();
                      });
                    },
                    icon: Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: const Color(0xFFFF7E00),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Results
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF7E00),
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBusinesses,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredBusinesses.isEmpty
                      ? const Center(
                          child: Text(
                            'No businesses found matching your criteria',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _filteredBusinesses[index];
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildBusinessCard(business),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Add Business Button
          GestureDetector(
            onTap: () async {
              const url = 'https://forms.gle/eqHkVrhk72kGsL4y5';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'ADD BUSINESS',
                    style: TextStyle(
                      color: Color(0xFFFF7E00),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/CC_PrimaryLogo_SilverPurple.png',
            width: 120,
            height: 60,
          ),
          
          const SizedBox(height: 10),
          
          // Title
          const Text(
            'GREEN BOOK',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7E00),
              fontFamily: 'Matches-StrikeRough',
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Black-owned business indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF7E00),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Color(0xFFFF7E00),
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'Black-Owned Businesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select City:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _showCityPicker = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCity.isEmpty ? 'Choose a city...' : _selectedCity,
                    style: TextStyle(
                      color: _selectedCity.isEmpty ? Colors.grey : Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFFF7E00),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Category:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showCategoryPicker = !_showCategoryPicker;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.category,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedSubCategory.isEmpty 
                          ? (_selectedMainCategory.isEmpty ? 'Choose a category...' : _selectedMainCategory)
                          : _selectedSubCategory,
                      style: TextStyle(
                        color: _selectedSubCategory.isEmpty && _selectedMainCategory.isEmpty ? Colors.grey : Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showCategoryPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFFF7E00),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          
          // Category Picker Dropdown
          if (_showCategoryPicker)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Main Categories
                  if (_selectedMainCategory.isEmpty)
                    ..._categories.keys.map((mainCategory) {
                      return GestureDetector(
                        onTap: () => _selectMainCategory(mainCategory),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[700]!, width: 0.5),
                            ),
                          ),
                          child: Text(
                            mainCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  
                  // Sub Categories
                  if (_selectedMainCategory.isNotEmpty)
                    ..._categories[_selectedMainCategory]!.map((subCategory) {
                      return GestureDetector(
                        onTap: () => _selectSubCategory(subCategory),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[700]!, width: 0.5),
                            ),
                          ),
                          child: Text(
                            subCategory,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          
          // Clear Filters Button
          if (_selectedMainCategory.isNotEmpty || _selectedSubCategory.isNotEmpty || _selectedCity.isNotEmpty || _searchText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7E00),
            width: 2,
          ),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
            _filterBusinesses();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name, category, or address...',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessCard(Business business) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Business Name
          Text(
            business.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Category
          if (business.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7E00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                business.category,
                style: const TextStyle(
                  color: Color(0xFFFF7E00),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Description
          if (business.description.isNotEmpty) ...[
            Text(
              business.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          
          // Address
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFFF7E00),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  business.address,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Hours
          if (business.hours.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFFFF7E00),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.hours,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Phone
          if (business.phone.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: Color(0xFFFF7E00),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.phone,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Action Buttons
          Row(
            children: [
              if (business.phone.isNotEmpty)
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        print('Calling: ${business.phone}');
                        final uri = Uri(scheme: 'tel', path: business.phone);
                        
                        // Try to launch the phone app
                        final canLaunch = await canLaunchUrl(uri);
                        print('Can launch phone URL: $canLaunch');
                        
                        if (canLaunch) {
                          await launchUrl(uri);
                          print('Phone app launched successfully');
                        } else {
                          // Show the phone number in a dialog as fallback
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Phone Number'),
                              content: Text('Call: ${business.phone}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error launching phone: $e');
                        // Show the phone number in a dialog as fallback
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Phone Number'),
                            content: Text('Call: ${business.phone}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7E00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              if (business.phone.isNotEmpty) const SizedBox(width: 8),
              if (business.website != null && business.website!.isNotEmpty)
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        String websiteUrl = business.website!;
                        print('Opening website: $websiteUrl');
                        // Add https:// if no protocol is specified
                        if (!websiteUrl.startsWith('http://') && !websiteUrl.startsWith('https://')) {
                          websiteUrl = 'https://$websiteUrl';
                        }
                        final uri = Uri.parse(websiteUrl);
                        
                        // Try to launch the website
                        final canLaunch = await canLaunchUrl(uri);
                        print('Can launch website URL: $canLaunch');
                        
                        if (canLaunch) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                          print('Website opened successfully');
                        } else {
                          // Show the website URL in a dialog as fallback
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Website'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Website: $websiteUrl'),
                                  const SizedBox(height: 16),
                                  const Text('Copy this URL to your browser:'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error launching website: $e');
                        // Show the website URL in a dialog as fallback
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Website'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Website: ${business.website}'),
                                const SizedBox(height: 16),
                                const Text('Copy this URL to your browser:'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.language, size: 16),
                    label: const Text('Website'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCityPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select City',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              return ListTile(
                title: Text(
                  city,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                    _showCityPicker = false;
                  });
                  _loadBusinessesByCity(city);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
      _filterBusinesses();
    });
  }

  void _sortBusinesses() {
    _filteredBusinesses.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'rating':
          final ratingA = a.rating ?? 0.0;
          final ratingB = b.rating ?? 0.0;
          comparison = ratingA.compareTo(ratingB);
          break;
        case 'distance':
          // For distance, we'll use a simple comparison
          // In a real app, you'd calculate actual distances
          comparison = a.name.compareTo(b.name); // Fallback to name
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  /// Search for subcategory keywords in business data
  bool _searchForSubcategoryKeywords(dynamic business, String subCategory) {
    final searchText = subCategory.toLowerCase();
    final category = business.category.toLowerCase();
    final description = business.description.toLowerCase();
    
    // Split subcategory into keywords for more flexible matching
    final keywords = searchText.split(' ').where((word) => word.length > 2).toList();
    
    // Check if any keyword appears in category or description
    for (final keyword in keywords) {
      if (category.contains(keyword) || description.contains(keyword)) {
        return true;
      }
    }
    
    // Also check for exact subcategory match
    return category.contains(searchText) || description.contains(searchText);
  }
}
