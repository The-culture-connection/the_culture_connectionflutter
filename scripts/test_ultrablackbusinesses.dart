import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

// Business name generators
final List<String> businessNamePrefixes = [
  'Elite', 'Premium', 'Royal', 'Golden', 'Platinum', 'Diamond', 'Crystal',
  'Urban', 'Modern', 'Classic', 'Vintage', 'Fresh', 'New', 'Prime', 'Supreme',
  'Apex', 'Summit', 'Peak', 'Zenith', 'Noble', 'Prestige', 'Luxury', 'Boutique'
];

final List<String> businessNameSuffixes = [
  'Solutions', 'Services', 'Group', 'Enterprises', 'LLC', 'Inc', 'Co',
  'Studio', 'Works', 'Hub', 'Center', 'Place', 'Spot', 'Lounge', 'Bar',
  'Shop', 'Store', 'Market', 'Boutique', 'Gallery', 'Salon', 'Spa'
];

final List<String> businessTypes = [
  'Wellness', 'Fitness', 'Nutrition', 'Therapy', 'Coaching', 'Consulting',
  'Design', 'Media', 'Marketing', 'Legal', 'Finance', 'Real Estate',
  'Beauty', 'Fashion', 'Food', 'Catering', 'Education', 'Training',
  'Construction', 'Cleaning', 'Repair', 'Automotive', 'Retail', 'Tech'
];

// Owner names
final List<String> firstNames = [
  'James', 'Michael', 'Robert', 'John', 'David', 'William', 'Richard',
  'Joseph', 'Thomas', 'Christopher', 'Charles', 'Daniel', 'Matthew',
  'Anthony', 'Mark', 'Donald', 'Steven', 'Paul', 'Andrew', 'Joshua',
  'Kenneth', 'Kevin', 'Brian', 'George', 'Timothy', 'Ronald', 'Jason',
  'Edward', 'Jeffrey', 'Ryan', 'Jacob', 'Gary', 'Nicholas', 'Eric',
  'Jonathan', 'Stephen', 'Larry', 'Justin', 'Scott', 'Brandon',
  'Benjamin', 'Samuel', 'Frank', 'Gregory', 'Raymond', 'Alexander',
  'Patrick', 'Jack', 'Dennis', 'Jerry', 'Tyler', 'Aaron', 'Jose',
  'Henry', 'Adam', 'Douglas', 'Nathan', 'Zachary', 'Peter', 'Kyle',
  'Noah', 'Ethan', 'Jeremy', 'Walter', 'Christian', 'Keith', 'Roger',
  'Terry', 'Austin', 'Sean', 'Gerald', 'Carl', 'Harold', 'Dylan',
  'Jesse', 'Jordan', 'Bryan', 'Billy', 'Joe', 'Bruce', 'Gabriel',
  'Logan', 'Alan', 'Juan', 'Wayne', 'Ralph', 'Roy', 'Eugene',
  'Louis', 'Philip', 'Johnny', 'Bobby', 'Howard', 'Randy'
];

final List<String> lastNames = [
  'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
  'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Wilson',
  'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee',
  'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis',
  'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott',
  'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson',
  'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts',
  'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz',
  'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy',
  'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson',
  'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward',
  'Richardson', 'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett',
  'Gray', 'Mendoza', 'Ruiz', 'Hughes', 'Price', 'Alvarez', 'Castillo',
  'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez'
];

// Categories and subcategories
final Map<String, List<String>> categories = {
  'Health & Wellness': [
    'Therapy & Counseling',
    'Mental Health Services',
    'Physical Therapy / Rehabilitation',
    'Fitness & Personal Training',
    'Nutrition / Meal Planning',
    'Chiropractic / Acupuncture',
    'Spa & Massage Services'
  ],
  'Professional & Financial Services': [
    'Accounting & Tax Preparation',
    'Financial Planning & Investment',
    'Legal Services / Law Firms',
    'Insurance Agencies',
    'Business Consulting',
    'Real Estate Agents / Brokers',
    'IT & Tech Support',
    'Marketing / Branding / PR'
  ],
  'Retail & Shopping': [
    'Clothing & Apparel',
    'Beauty Supply Stores',
    'Jewelry & Accessories',
    'Home Décor & Furniture',
    'Electronics / Tech',
    'Bookstores / Stationery',
    'Gift Shops'
  ],
  'Food & Beverage': [
    'Restaurants & Cafés',
    'Catering Services',
    'Food Trucks',
    'Bakeries / Dessert Shops',
    'Bars & Lounges',
    'Meal Prep Businesses'
  ],
  'Creative & Media': [
    'Photography / Videography',
    'Graphic Design / Branding',
    'Music / Production Studios',
    'Publishing & Writing Services',
    'Event Planning & Decor',
    'Art Galleries / Craft Businesses'
  ],
  'Education & Training': [
    'Tutoring & Test Prep',
    'Childcare / Daycare',
    'Professional Coaching',
    'Trade Schools',
    'Online Courses / E-learning Platforms'
  ],
  'Home & Trades': [
    'Construction / Contracting',
    'Landscaping & Lawn Care',
    'Cleaning Services',
    'Plumbing / Electrical / HVAC',
    'Moving & Storage'
  ],
  'Community & Nonprofit': [
    'Nonprofit Organizations',
    'Churches / Faith-Based Groups',
    'Charities & Mutual Aid',
    'Social Justice / Advocacy',
    'Mentorship Programs'
  ],
  'Transportation & Automotive': [
    'Car Dealerships',
    'Auto Repair & Detailing',
    'Rideshare / Delivery Services',
    'Logistics / Trucking'
  ],
  'Beauty & Personal Care': [
    'Hair Salons & Barbershops',
    'Nail Technicians',
    'Estheticians / Skincare',
    'Makeup Artists',
    'Cosmetic Brands'
  ],
};

final List<String> serviceTypes = ['In-person', 'Online', 'Hybrid'];
final List<String> priceRanges = ['\$', '\$\$', '\$\$\$', '\$\$\$\$', '\$\$\$\$\$'];
final List<String> discountTypes = ['% off', '\$ off', 'BOGO', 'Free consultation', 'Exclusive service', 'Other'];

// Cincinnati addresses
final List<Map<String, String>> cincinnatiAddresses = [
  {'street': '332 Boal street', 'zip': '45202'},
  {'street': '123 Main Street', 'zip': '45202'},
  {'street': '456 Vine Street', 'zip': '45202'},
  {'street': '789 Walnut Street', 'zip': '45202'},
  {'street': '321 Race Street', 'zip': '45202'},
  {'street': '654 Elm Street', 'zip': '45219'},
  {'street': '987 Oak Avenue', 'zip': '45219'},
  {'street': '147 Pine Street', 'zip': '45219'},
  {'street': '258 Maple Drive', 'zip': '45220'},
  {'street': '369 Cedar Lane', 'zip': '45220'},
  {'street': '741 Cherry Street', 'zip': '45220'},
  {'street': '852 Birch Road', 'zip': '45206'},
  {'street': '963 Willow Way', 'zip': '45206'},
  {'street': '159 Spruce Court', 'zip': '45206'},
  {'street': '357 Ash Boulevard', 'zip': '45208'},
  {'street': '468 Poplar Place', 'zip': '45208'},
  {'street': '579 Hickory Circle', 'zip': '45208'},
  {'street': '680 Sycamore Street', 'zip': '45211'},
  {'street': '791 Chestnut Avenue', 'zip': '45211'},
  {'street': '802 Beech Drive', 'zip': '45211'},
];

void main() async {
  print('🚀 Initializing Flutter bindings...');
  
  // Initialize Flutter bindings (required for Firebase on some platforms)
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Initializing Firebase...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    exit(1);
  }

  final firestore = FirebaseFirestore.instance;
  final random = Random();
  
  print('📝 Generating 100 test businesses...\n');

  int successCount = 0;
  int errorCount = 0;

  for (int i = 0; i < 100; i++) {
    try {
      // Generate random business data
      final prefix = businessNamePrefixes[random.nextInt(businessNamePrefixes.length)];
      final type = businessTypes[random.nextInt(businessTypes.length)];
      final suffix = businessNameSuffixes[random.nextInt(businessNameSuffixes.length)];
      final businessName = '$prefix $type $suffix';
      
      final firstName = firstNames[random.nextInt(firstNames.length)];
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final ownerName = '$firstName $lastName';
      
      final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@test-business.com';
      final phone = '513${random.nextInt(9000000) + 1000000}';
      
      // Select random category
      final categoryKeys = categories.keys.toList();
      final mainCategory = categoryKeys[random.nextInt(categoryKeys.length)];
      final subCategories = categories[mainCategory]!;
      final subCategory = subCategories[random.nextInt(subCategories.length)];
      
      // Random address
      final addressData = cincinnatiAddresses[random.nextInt(cincinnatiAddresses.length)];
      
      // Random service types (1-3 selected)
      final selectedServiceTypes = <String>[];
      final numServiceTypes = random.nextInt(3) + 1;
      final shuffledServices = List<String>.from(serviceTypes)..shuffle(random);
      selectedServiceTypes.addAll(shuffledServices.take(numServiceTypes));
      
      // Random price range
      final priceRange = priceRanges[random.nextInt(priceRanges.length)];
      
      // Random deal data
      final discountType = discountTypes[random.nextInt(discountTypes.length)];
      final discountValue = discountType == '% off' 
          ? '${random.nextInt(50) + 10}' // 10-60%
          : discountType == '\$ off'
              ? '\$${random.nextInt(100) + 5}' // $5-$105
              : '';
      
      final totalCodes = random.nextInt(200) + 50; // 50-250 codes
      
      // Generate business ID
      final businessId = firestore.collection('Ultra Black Friday').doc().id;
      
      // Random code prefix
      final randomCodePrefix = businessName.replaceAll(' ', '').toLowerCase() + 
          (100 + random.nextInt(900)).toString();
      
      // Create deal data
      final dealData = {
        'title': 'Special ${discountType == '% off' ? discountValue + '%' : discountType} Offer',
        'description': 'Exclusive deal for Ultra Black Friday participants. ${discountType == '% off' ? discountValue + '% off' : discountType} on selected services.',
        'terms': 'Valid for first-time customers only. Cannot be combined with other offers. Expires 30 days after claim.',
        'discountType': discountType,
        'discountValue': discountValue,
        'totalCodes': totalCodes,
        'redemptionInstructions': 'Present this code at checkout. Code must be verified by staff before discount is applied.',
      };
      
      // Create address data
      final addressDataMap = {
        'street': addressData['street'],
        'city': 'Cincinnati',
        'state': 'OH',
        'zip': addressData['zip'],
        'mapLink': null,
      };
      
      // Create social data (mostly null, some random)
      final socialData = {
        'instagram': random.nextDouble() > 0.7 ? 'https://instagram.com/${businessName.replaceAll(' ', '').toLowerCase()}' : null,
        'facebook': random.nextDouble() > 0.7 ? 'https://facebook.com/${businessName.replaceAll(' ', '').toLowerCase()}' : null,
        'tiktok': random.nextDouble() > 0.8 ? 'https://tiktok.com/@${businessName.replaceAll(' ', '').toLowerCase()}' : null,
        'linkedin': random.nextDouble() > 0.8 ? 'https://linkedin.com/company/${businessName.replaceAll(' ', '').toLowerCase()}' : null,
        'twitter': random.nextDouble() > 0.8 ? 'https://x.com/${businessName.replaceAll(' ', '').toLowerCase()}' : null,
      };
      
      // Prepare business data
      final now = FieldValue.serverTimestamp();
      final businessData = {
        'address': addressDataMap,
        'appVisibility': true,
        'bookingLink': null,
        'businessId': businessId,
        'businessName': businessName,
        'codeInventoryCount': totalCodes,
        'dateCreated': now,
        'deal': dealData,
        'email': email,
        'hours': null,
        'lastUpdated': now,
        'logoStoragePath': null,
        'logoUrl': null,
        'mainCategory': mainCategory,
        'menuLink': null,
        'ownerName': ownerName,
        'phone': phone,
        'priceRange': priceRange,
        'randomCodePrefix': randomCodePrefix,
        'serviceTypes': selectedServiceTypes,
        'shortDescription': 'Quality ${type.toLowerCase()} services in the Cincinnati area. ${businessName} is committed to excellence.',
        'social': socialData,
        'subCategory': subCategory,
        'website': random.nextDouble() > 0.5 ? 'https://www.${businessName.replaceAll(' ', '').toLowerCase()}.com' : null,
      };
      
      // Save to Firestore
      // Path: Ultra Black Friday/{mainCategory}/businesses/{businessId}
      // First, ensure the category document exists with Theme field
      final categoryRef = firestore.collection('Ultra Black Friday').doc(mainCategory);
      await categoryRef.set({
        'Theme': mainCategory,
      }, SetOptions(merge: true));
      
      // Then add the business to the businesses subcollection
      await categoryRef
          .collection('businesses')
          .doc(businessId)
          .set(businessData);
      
      successCount++;
      if ((i + 1) % 10 == 0) {
        print('✅ Created ${i + 1}/100 businesses...');
      }
    } catch (e) {
      errorCount++;
      print('❌ Error creating business ${i + 1}: $e');
    }
  }
  
  print('\n📊 Summary:');
  print('✅ Successfully created: $successCount businesses');
  print('❌ Errors: $errorCount businesses');
  print('\n🎉 Done! Test businesses have been uploaded to Firestore.');
  
  exit(0);
}

