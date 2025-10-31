
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class GreenBookScreen extends StatefulWidget {
  const GreenBookScreen({super.key});

  @override
  State<GreenBookScreen> createState() => _GreenBookScreenState();
}

class _GreenBookScreenState extends State<GreenBookScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Business> _businesses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCity = '';
  String _selectedMainCategory = '';
  String _selectedSubCategory = '';
  List<String> _availableCities = [];
  bool _isSearchExpanded = true; // Controls whether search interface is expanded

  // Business categories structure
  final Map<String, List<String>> _categories = {
    'Health & Wellness': [
      'Therapy & Counseling',
      'Mental Health Services',
      'Physical Therapy / Rehabilitation',
      'Fitness & Personal Training',
      'Nutrition / Meal Planning',
      'Chiropractic / Acupuncture',
      'Spa & Massage Services',
    ],
    'Professional & Financial Services': [
      'Accounting & Tax Preparation',
      'Financial Planning & Investment',
      'Legal Services / Law Firms',
      'Insurance Agencies',
      'Business Consulting',
      'Real Estate Agents / Brokers',
      'IT & Tech Support',
      'Marketing / Branding / PR',
    ],
    'Retail & Shopping': [
      'Clothing & Apparel',
      'Beauty Supply Stores',
      'Jewelry & Accessories',
      'Home Décor & Furniture',
      'Electronics / Tech',
      'Bookstores / Stationery',
      'Gift Shops',
    ],
    'Food & Beverage': [
      'Restaurants & Cafés',
      'Catering Services',
      'Food Trucks',
      'Bakeries / Dessert Shops',
      'Bars & Lounges',
      'Meal Prep Businesses',
    ],
    'Creative & Media': [
      'Photography / Videography',
      'Graphic Design / Branding',
      'Music / Production Studios',
      'Publishing & Writing Services',
      'Event Planning & Decor',
      'Art Galleries / Craft Businesses',
    ],
    'Education & Training': [
      'Tutoring & Test Prep',
      'Childcare / Daycare',
      'Professional Coaching',
      'Trade Schools',
      'Online Courses / E-learning Platforms',
    ],
    'Home & Trades': [
      'Construction / Contracting',
      'Landscaping & Lawn Care',
      'Cleaning Services',
      'Plumbing / Electrical / HVAC',
      'Moving & Storage',
    ],
    'Community & Nonprofit': [
      'Nonprofit Organizations',
      'Churches / Faith-Based Groups',
      'Charities & Mutual Aid',
      'Social Justice / Advocacy',
      'Mentorship Programs',
    ],
    'Transportation & Automotive': [
      'Car Dealerships',
      'Auto Repair & Detailing',
      'Rideshare / Delivery Services',
      'Logistics / Trucking',
    ],
    'Beauty & Personal Care': [
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
    _loadAvailableCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/Loginimage1-3.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button and Add Business Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_left, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "BACK",
                                style: TextStyle(
                                  fontFamily: 'Matches-StrikeRough',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                            color: const Color(0xFF1D1D1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_circle, color: Color(0xFFFF7E00), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "ADD BUSINESS",
                                style: TextStyle(
                                  fontFamily: 'Matches-StrikeRough',
                                  fontSize: 10,
                                  color: const Color(0xFFFF7E00),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Logo and Title
                Column(
                  children: [
                    Image.asset(
                      'assets/CC_PrimaryLogo_SilverPurple.png',
                      width: 120,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      "GREEN BOOK",
                      style: TextStyle(
                        fontFamily: 'Matches-StrikeRough',
                        fontSize: 32,
                        color: const Color(0xFFFF7E00),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Black-owned business indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF7E00), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Color(0xFFFF7E00),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Black-Owned Businesses",
                            style: TextStyle(
                              fontFamily: 'Inter-VariableFont_slnt,wght',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Search Interface (conditional)
                if (_isSearchExpanded) _buildSearchInterface(),
                
                // Collapsed Search Button (when search is collapsed)
                if (!_isSearchExpanded) _buildCollapsedSearchButton(),
                
                // Content Area
                Expanded(
                  child: _buildContentArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text(
        "Select Main Category",
        style: TextStyle(
          fontFamily: 'Inter-VariableFont_slnt,wght',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: _categories.keys.length,
          itemBuilder: (context, index) {
            final category = _categories.keys.elementAt(index);
            return ListTile(
              title: Text(
                category,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedMainCategory = category;
                  _selectedSubCategory = ''; // Reset sub-category
                  _selectedCity = ''; // Reset city
                });
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryPicker() {
    final subCategories = _categories[_selectedMainCategory] ?? [];
    
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text(
        "Select Sub-category",
        style: TextStyle(
          fontFamily: 'Inter-VariableFont_slnt,wght',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = subCategories[index];
            return ListTile(
              title: Text(
                subCategory,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedSubCategory = subCategory;
                  _selectedCity = ''; // Reset city
                });
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildCityPicker() {
    print('Building city picker with ${_availableCities.length} cities: $_availableCities');
    
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text(
        "Select City",
        style: TextStyle(
          fontFamily: 'Inter-VariableFont_slnt,wght',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _availableCities.isEmpty 
          ? const Center(
              child: Text(
                "No cities available",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _availableCities.length,
              itemBuilder: (context, index) {
                final city = _availableCities[index];
                print('Building ListTile for city: $city');
                return ListTile(
                  title: Text(
                    city,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF7E00),
            ),
            SizedBox(height: 20),
            Text(
              "Loading businesses...",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Error",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_selectedMainCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Select a Main Category",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a main business category to get started",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_selectedSubCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Select a Sub-category",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a specific business type within $_selectedMainCategory",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_selectedCity.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_city,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Select a City",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a city to search for $_selectedSubCategory businesses",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_businesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "No businesses found",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No Black-owned businesses found in $_selectedCity",
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Business Listings
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        return _buildBusinessCard(_businesses[index]);
      },
    );
  }

  Widget _buildBusinessCard(Business business) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and name
          Row(
            children: [
              const Icon(
                Icons.business,
                color: Color(0xFFFF7E00),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: TextStyle(
                        fontFamily: 'Inter-VariableFont_slnt,wght',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category,
                      style: TextStyle(
                        fontFamily: 'Inter-VariableFont_slnt,wght',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (business.budget.isNotEmpty && business.budget != "N/A")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7E00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    business.budget,
                    style: TextStyle(
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                      fontSize: 12,
                      color: const Color(0xFFFF7E00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Business Description
          if (business.description.isNotEmpty) ...[
            Text(
              business.description,
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          // Business Details
          Column(
            children: [
              if (business.address.isNotEmpty)
                _buildDetailRow(Icons.location_on, business.address),
              if (business.phone.isNotEmpty)
                _buildPhoneRow(business.phone),
              if (business.hours.isNotEmpty && business.hours != "No Hours Available")
                _buildDetailRow(Icons.access_time, _formatHours(business.hours)),
            ],
          ),
          
          // Rating and Reviews
          if (business.rating != null && business.reviewCount != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < business.rating!.toInt() ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFF7E00),
                      size: 12,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${business.reviewCount} reviews)",
                  style: TextStyle(
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          
          // Website Button
          if (business.website.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(business.website))) {
                    await launchUrl(Uri.parse(business.website));
                  }
                },
                icon: const Icon(Icons.language, size: 16),
                label: const Text("VISIT WEBSITE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter-VariableFont_slnt,wght',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build clickable phone number
  Widget _buildPhoneRow(String phone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.phone,
            color: Colors.grey,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              },
              child: Text(
                phone,
                style: TextStyle(
                  fontFamily: 'Inter-VariableFont_slnt,wght',
                  fontSize: 14,
                  color: const Color(0xFFFF7E00), // Orange color for clickable phone
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format hours from JSON-like string to readable format
  String _formatHours(String hours) {
    if (hours.isEmpty || hours == "No Hours Available") {
      return "Hours not available";
    }
    
    // Check if it's JSON-like data
    if (hours.contains('{') && hours.contains('}')) {
      try {
        // Try to extract readable information from the JSON-like string
        if (hours.contains('Is_open_now: true')) {
          return "Open Now";
        } else if (hours.contains('Is_open_now: false')) {
          return "Closed";
        } else if (hours.contains('hours_type: REGULAR')) {
          return "Regular Hours";
        } else {
          // If we can't parse it properly, return a simplified version
          return "Hours available - see website for details";
        }
      } catch (e) {
        return "Hours available - see website for details";
      }
    }
    
    // If it's not JSON-like, return as is (but limit length)
    if (hours.length > 50) {
      return "${hours.substring(0, 47)}...";
    }
    return hours;
  }

  Future<void> _loadAvailableCities() async {
    try {
      print('Loading cities from Businesses collection...');
      final citiesSnapshot = await _db.collection('Businesses').get();
      print('Found ${citiesSnapshot.docs.length} city documents');
      
      final cities = citiesSnapshot.docs.map((doc) {
        print('City document ID: ${doc.id}');
        return doc.id;
      }).toList();
      
      print('Available cities: $cities');
      
      // If no cities found, add some default cities for testing
      if (cities.isEmpty) {
        print('No cities found in Firestore, adding default cities for testing');
        cities.addAll(['Cincinnati', 'Columbus', 'Dayton', 'Cleveland', 'Toledo']);
      }
      
      setState(() {
        _availableCities = cities;
      });
    } catch (e) {
      print('Error loading cities: $e');
      // Add default cities as fallback
      setState(() {
        _availableCities = ['Cincinnati', 'Columbus', 'Dayton', 'Cleveland', 'Toledo'];
      });
    }
  }

  Future<void> _searchBusinesses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Searching businesses in city: $_selectedCity');
      print('Looking for sub-category: $_selectedSubCategory');
      
      // Search for businesses in the selected city with the sub-category keyword in their description
      final querySnapshot = await _db
          .collection('Businesses')
          .doc(_selectedCity)
          .collection('results')
          .get();

      print('Found ${querySnapshot.docs.length} total businesses in $_selectedCity');

      // Enhanced keyword matching
      final filteredBusinesses = <Business>[];
      final subCategory = _selectedSubCategory.toLowerCase();
      
      // Create multiple keyword variations for better matching
      final keywords = _createSearchKeywords(subCategory);
      print('Search keywords: $keywords');
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Safe type conversion to handle List<dynamic> -> String issues
        final description = _safeStringFromDynamic(data['description']).toLowerCase();
        final name = _safeStringFromDynamic(data['name']).toLowerCase();
        final category = _safeStringFromDynamic(data['category']).toLowerCase();
        
        print('Checking business: ${_safeStringFromDynamic(data['name'])}');
        print('Description: $description');
        
        // Check if any keyword matches in description, name, or category
        bool isMatch = false;
        for (final keyword in keywords) {
          if (description.contains(keyword) || 
              name.contains(keyword) || 
              category.contains(keyword)) {
            isMatch = true;
            print('Match found with keyword: $keyword');
            break;
          }
        }
        
        if (isMatch) {
          print('Adding business: ${_safeStringFromDynamic(data['name'])}');
          filteredBusinesses.add(Business(
            id: doc.id,
            name: _safeStringFromDynamic(data['name']),
            category: _safeStringFromDynamic(data['category']),
            description: _safeStringFromDynamic(data['description']),
            address: _safeStringFromDynamic(data['address']),
            phone: _safeStringFromDynamic(data['phone']),
            website: _safeStringFromDynamic(data['website']),
            hours: _safeStringFromDynamic(data['hours']),
            budget: _safeStringFromDynamic(data['budget']),
            rating: _safeDoubleFromDynamic(data['rating']),
            reviewCount: _safeIntFromDynamic(data['reviewCount']),
          ));
        }
      }

      print('Found ${filteredBusinesses.length} matching businesses');
      
      setState(() {
        _businesses = filteredBusinesses;
        _isLoading = false;
        _isSearchExpanded = false; // Collapse search interface after successful search
      });
    } catch (e) {
      print('Error searching businesses: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Safe type conversion helpers to handle Firestore data type mismatches
  String _safeStringFromDynamic(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  double? _safeDoubleFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _safeIntFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Enhanced keyword creation for better matching
  List<String> _createSearchKeywords(String subCategory) {
    final keywords = <String>[];
    
    // Add the original sub-category
    keywords.add(subCategory);
    
    // Add variations by removing common words and creating shorter versions
    final words = subCategory.split(' ');
    for (final word in words) {
      if (word.length > 3) { // Only add words longer than 3 characters
        keywords.add(word);
      }
    }
    
    // Add specific keyword mappings for common business types
    final keywordMappings = {
      'therapy & counseling': ['therapy', 'counseling', 'mental health', 'counselor', 'therapist'],
      'fitness & personal training': ['fitness', 'gym', 'trainer', 'training', 'workout', 'exercise'],
      'hair salons & barbershops': ['hair', 'salon', 'barber', 'barbershop', 'stylist', 'haircut'],
      'restaurants & cafés': ['restaurant', 'cafe', 'food', 'dining', 'eatery', 'kitchen'],
      'photography / videography': ['photography', 'photographer', 'photo', 'video', 'videography', 'camera'],
      'accounting & tax preparation': ['accounting', 'accountant', 'tax', 'bookkeeping', 'financial'],
      'legal services / law firms': ['legal', 'lawyer', 'attorney', 'law', 'legal services'],
      'real estate agents / brokers': ['real estate', 'realtor', 'property', 'housing', 'broker'],
      'it & tech support': ['tech', 'it', 'computer', 'technology', 'software', 'support'],
      'marketing / branding / pr': ['marketing', 'branding', 'advertising', 'pr', 'promotion'],
      'clothing & apparel': ['clothing', 'fashion', 'apparel', 'clothes', 'wear', 'style'],
      'beauty supply stores': ['beauty', 'cosmetics', 'makeup', 'skincare', 'beauty supply'],
      'jewelry & accessories': ['jewelry', 'jewellery', 'accessories', 'rings', 'necklaces'],
      'home décor & furniture': ['furniture', 'decor', 'décor', 'home', 'interior', 'furnishings'],
      'electronics / tech': ['electronics', 'tech', 'gadgets', 'devices', 'computers'],
      'bookstores / stationery': ['books', 'bookstore', 'stationery', 'office supplies'],
      'catering services': ['catering', 'caterer', 'events', 'party', 'food service'],
      'food trucks': ['food truck', 'truck', 'mobile food', 'street food'],
      'bakeries / dessert shops': ['bakery', 'baker', 'dessert', 'cake', 'pastry', 'sweets'],
      'bars & lounges': ['bar', 'lounge', 'pub', 'cocktail', 'drinks', 'nightlife'],
      'music / production studios': ['music', 'studio', 'recording', 'audio', 'sound'],
      'graphic design / branding': ['graphic design', 'design', 'graphics', 'visual', 'creative'],
      'event planning & decor': ['event planning', 'events', 'planning', 'decorations', 'party'],
      'art galleries / craft businesses': ['art', 'gallery', 'craft', 'artisan', 'creative'],
      'tutoring & test prep': ['tutoring', 'tutor', 'education', 'test prep', 'academic'],
      'childcare / daycare': ['childcare', 'daycare', 'child care', 'babysitting', 'kids'],
      'professional coaching': ['coaching', 'coach', 'professional development', 'career'],
      'construction / contracting': ['construction', 'contractor', 'building', 'renovation', 'remodel'],
      'landscaping & lawn care': ['landscaping', 'lawn', 'garden', 'yard', 'outdoor'],
      'cleaning services': ['cleaning', 'cleaner', 'housekeeping', 'janitorial', 'maintenance'],
      'plumbing / electrical / hvac': ['plumbing', 'electrician', 'hvac', 'electrical', 'heating'],
      'moving & storage': ['moving', 'storage', 'relocation', 'packing', 'transport'],
      'nonprofit organizations': ['nonprofit', 'charity', 'foundation', 'organization', 'community'],
      'churches / faith-based groups': ['church', 'faith', 'religious', 'spiritual', 'worship'],
      'charities & mutual aid': ['charity', 'charities', 'mutual aid', 'help', 'support'],
      'social justice / advocacy': ['social justice', 'advocacy', 'activism', 'rights', 'equality'],
      'mentorship programs': ['mentorship', 'mentor', 'mentoring', 'guidance', 'development'],
      'car dealerships': ['car dealer', 'dealership', 'automotive', 'cars', 'vehicles'],
      'auto repair & detailing': ['auto repair', 'car repair', 'detailing', 'automotive', 'mechanic'],
      'rideshare / delivery services': ['rideshare', 'delivery', 'transportation', 'uber', 'lyft'],
      'logistics / trucking': ['logistics', 'trucking', 'shipping', 'freight', 'transport'],
      'nail technicians': ['nail', 'manicure', 'pedicure', 'nail art', 'nail tech'],
      'estheticians / skincare': ['esthetician', 'skincare', 'skin care', 'facial', 'beauty'],
      'makeup artists': ['makeup', 'makeup artist', 'cosmetics', 'beauty', 'styling'],
      'cosmetic brands': ['cosmetics', 'beauty brand', 'makeup brand', 'skincare brand'],
    };
    
    // Add mapped keywords if available
    if (keywordMappings.containsKey(subCategory)) {
      keywords.addAll(keywordMappings[subCategory]!);
    }
    
    // Remove duplicates and return
    return keywords.toSet().toList();
  }

  // Build the full search interface
  Widget _buildSearchInterface() {
    return Column(
      children: [
        // Step 1: Main Category Selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Step 1: Select Main Category",
                style: TextStyle(
                  fontFamily: 'Inter-VariableFont_slnt,wght',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => _buildCategoryPicker(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category,
                        color: Color(0xFFFF7E00),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedMainCategory.isEmpty ? "Choose a main category..." : _selectedMainCategory,
                          style: TextStyle(
                            fontFamily: 'Inter-VariableFont_slnt,wght',
                            fontSize: 16,
                            color: _selectedMainCategory.isEmpty ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
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
        ),
        
        const SizedBox(height: 20),
        
        // Step 2: Sub-category Selection (only show if main category is selected)
        if (_selectedMainCategory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 2: Select Sub-category",
                  style: TextStyle(
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _buildSubCategoryPicker(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Color(0xFFFF7E00),
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedSubCategory.isEmpty ? "Choose a sub-category..." : _selectedSubCategory,
                            style: TextStyle(
                              fontFamily: 'Inter-VariableFont_slnt,wght',
                              fontSize: 16,
                              color: _selectedSubCategory.isEmpty ? Colors.grey : Colors.white,
                            ),
                          ),
                        ),
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
          ),
          const SizedBox(height: 20),
        ],
        
        // Step 3: City Selection (only show if sub-category is selected)
        if (_selectedSubCategory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 3: Select City",
                  style: TextStyle(
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _buildCityPicker(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF7E00), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFF7E00),
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedCity.isEmpty ? "Choose a city..." : _selectedCity,
                            style: TextStyle(
                              fontFamily: 'Inter-VariableFont_slnt,wght',
                              fontSize: 16,
                              color: _selectedCity.isEmpty ? Colors.grey : Colors.white,
                            ),
                          ),
                        ),
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
          ),
          const SizedBox(height: 20),
        ],
        
        // Search Button (only show if all selections are made)
        if (_selectedCity.isNotEmpty && _selectedMainCategory.isNotEmpty && _selectedSubCategory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchBusinesses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "SEARCH BUSINESSES",
                  style: TextStyle(
                    fontFamily: 'Matches-StrikeRough',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Build the collapsed search button
  Widget _buildCollapsedSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Show current search criteria
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF7E00), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Search:",
                    style: TextStyle(
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$_selectedSubCategory in $_selectedCity",
                    style: TextStyle(
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isSearchExpanded = true;
              });
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: Text(
              "SEARCH",
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7E00),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Business {
  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final String phone;
  final String website;
  final String hours;
  final String budget;
  final double? rating;
  final int? reviewCount;

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.phone,
    required this.website,
    required this.hours,
    required this.budget,
    this.rating,
    this.reviewCount,
  });
}
