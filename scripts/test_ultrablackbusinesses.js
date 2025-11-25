/**
 * Node.js script to generate 100 test businesses for Ultra Black Friday
 * 
 * To run:
 * 1. Install dependencies: npm install firebase-admin
 * 2. Set up Firebase Admin credentials (see README)
 * 3. Run: node scripts/test_ultrablackbusinesses.js
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
// You'll need to download your service account key from Firebase Console
// and place it in the project root or set GOOGLE_APPLICATION_CREDENTIALS
try {
  // Try to initialize with service account key
  const serviceAccount = require('../serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  // If no service account key, try using default credentials
  try {
    admin.initializeApp();
  } catch (err) {
    console.error('❌ Firebase initialization error:', err.message);
    console.error('\nPlease set up Firebase Admin credentials.');
    console.error('Option 1: Download serviceAccountKey.json from Firebase Console');
    console.error('Option 2: Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
    process.exit(1);
  }
}

const db = admin.firestore();

// Business name generators
const businessNamePrefixes = [
  'Elite', 'Premium', 'Royal', 'Golden', 'Platinum', 'Diamond', 'Crystal',
  'Urban', 'Modern', 'Classic', 'Vintage', 'Fresh', 'New', 'Prime', 'Supreme',
  'Apex', 'Summit', 'Peak', 'Zenith', 'Noble', 'Prestige', 'Luxury', 'Boutique'
];

const businessNameSuffixes = [
  'Solutions', 'Services', 'Group', 'Enterprises', 'LLC', 'Inc', 'Co',
  'Studio', 'Works', 'Hub', 'Center', 'Place', 'Spot', 'Lounge', 'Bar',
  'Shop', 'Store', 'Market', 'Boutique', 'Gallery', 'Salon', 'Spa'
];

const businessTypes = [
  'Wellness', 'Fitness', 'Nutrition', 'Therapy', 'Coaching', 'Consulting',
  'Design', 'Media', 'Marketing', 'Legal', 'Finance', 'Real Estate',
  'Beauty', 'Fashion', 'Food', 'Catering', 'Education', 'Training',
  'Construction', 'Cleaning', 'Repair', 'Automotive', 'Retail', 'Tech'
];

// Owner names
const firstNames = [
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

const lastNames = [
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
const categories = {
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

const serviceTypes = ['In-person', 'Online', 'Hybrid'];
const priceRanges = ['$', '$$', '$$$', '$$$$', '$$$$$'];
const discountTypes = ['% off', '$ off', 'BOGO', 'Free consultation', 'Exclusive service', 'Other'];

// Cincinnati addresses
const cincinnatiAddresses = [
  { street: '332 Boal street', zip: '45202' },
  { street: '123 Main Street', zip: '45202' },
  { street: '456 Vine Street', zip: '45202' },
  { street: '789 Walnut Street', zip: '45202' },
  { street: '321 Race Street', zip: '45202' },
  { street: '654 Elm Street', zip: '45219' },
  { street: '987 Oak Avenue', zip: '45219' },
  { street: '147 Pine Street', zip: '45219' },
  { street: '258 Maple Drive', zip: '45220' },
  { street: '369 Cedar Lane', zip: '45220' },
  { street: '741 Cherry Street', zip: '45220' },
  { street: '852 Birch Road', zip: '45206' },
  { street: '963 Willow Way', zip: '45206' },
  { street: '159 Spruce Court', zip: '45206' },
  { street: '357 Ash Boulevard', zip: '45208' },
  { street: '468 Poplar Place', zip: '45208' },
  { street: '579 Hickory Circle', zip: '45208' },
  { street: '680 Sycamore Street', zip: '45211' },
  { street: '791 Chestnut Avenue', zip: '45211' },
  { street: '802 Beech Drive', zip: '45211' },
];

function randomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function generateBusinesses() {
  console.log('📝 Generating 100 test businesses...\n');

  let successCount = 0;
  let errorCount = 0;

  for (let i = 0; i < 100; i++) {
    try {
      // Generate random business data
      const prefix = randomElement(businessNamePrefixes);
      const type = randomElement(businessTypes);
      const suffix = randomElement(businessNameSuffixes);
      const businessName = `${prefix} ${type} ${suffix}`;
      
      const firstName = randomElement(firstNames);
      const lastName = randomElement(lastNames);
      const ownerName = `${firstName} ${lastName}`;
      
      const email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@test-business.com`;
      const phone = `513${randomInt(1000000, 9999999)}`;
      
      // Select random category
      const categoryKeys = Object.keys(categories);
      const mainCategory = randomElement(categoryKeys);
      const subCategories = categories[mainCategory];
      const subCategory = randomElement(subCategories);
      
      // Random address
      const addressData = randomElement(cincinnatiAddresses);
      
      // Random service types (1-3 selected)
      const numServiceTypes = randomInt(1, 3);
      const shuffledServices = [...serviceTypes].sort(() => Math.random() - 0.5);
      const selectedServiceTypes = shuffledServices.slice(0, numServiceTypes);
      
      // Random price range
      const priceRange = randomElement(priceRanges);
      
      // Random deal data
      const discountType = randomElement(discountTypes);
      const discountValue = discountType === '% off' 
          ? `${randomInt(10, 60)}` // 10-60%
          : discountType === '$ off'
              ? `$${randomInt(5, 105)}` // $5-$105
              : '';
      
      const totalCodes = randomInt(50, 250); // 50-250 codes
      
      // Generate business ID
      const businessId = db.collection('Ultra Black Friday').doc().id;
      
      // Random code prefix
      const randomCodePrefix = businessName.replace(/\s+/g, '').toLowerCase() + 
          (100 + randomInt(0, 900)).toString();
      
      // Create deal data
      const dealData = {
        title: `Special ${discountType === '% off' ? discountValue + '%' : discountType} Offer`,
        description: `Exclusive deal for Ultra Black Friday participants. ${discountType === '% off' ? discountValue + '% off' : discountType} on selected services.`,
        terms: 'Valid for first-time customers only. Cannot be combined with other offers. Expires 30 days after claim.',
        discountType: discountType,
        discountValue: discountValue || null,
        totalCodes: totalCodes,
        redemptionInstructions: 'Present this code at checkout. Code must be verified by staff before discount is applied.',
      };
      
      // Create address data
      const addressDataMap = {
        street: addressData.street,
        city: 'Cincinnati',
        state: 'OH',
        zip: addressData.zip,
        mapLink: null,
      };
      
      // Create social data (mostly null, some random)
      const socialData = {
        instagram: Math.random() > 0.7 ? `https://instagram.com/${businessName.replace(/\s+/g, '').toLowerCase()}` : null,
        facebook: Math.random() > 0.7 ? `https://facebook.com/${businessName.replace(/\s+/g, '').toLowerCase()}` : null,
        tiktok: Math.random() > 0.8 ? `https://tiktok.com/@${businessName.replace(/\s+/g, '').toLowerCase()}` : null,
        linkedin: Math.random() > 0.8 ? `https://linkedin.com/company/${businessName.replace(/\s+/g, '').toLowerCase()}` : null,
        twitter: Math.random() > 0.8 ? `https://x.com/${businessName.replace(/\s+/g, '').toLowerCase()}` : null,
      };
      
      // Prepare business data
      const now = admin.firestore.FieldValue.serverTimestamp();
      const businessData = {
        address: addressDataMap,
        appVisibility: true,
        bookingLink: null,
        businessId: businessId,
        businessName: businessName,
        codeInventoryCount: totalCodes,
        dateCreated: now,
        deal: dealData,
        email: email,
        hours: null,
        lastUpdated: now,
        logoStoragePath: null,
        logoUrl: null,
        mainCategory: mainCategory,
        menuLink: null,
        ownerName: ownerName,
        phone: phone,
        priceRange: priceRange,
        randomCodePrefix: randomCodePrefix,
        serviceTypes: selectedServiceTypes,
        shortDescription: `Quality ${type.toLowerCase()} services in the Cincinnati area. ${businessName} is committed to excellence.`,
        social: socialData,
        subCategory: subCategory,
        website: Math.random() > 0.5 ? `https://www.${businessName.replace(/\s+/g, '').toLowerCase()}.com` : null,
      };
      
      // Save to Firestore
      // First, ensure the category document exists with Theme field
      const categoryRef = db.collection('Ultra Black Friday').doc(mainCategory);
      await categoryRef.set({
        Theme: mainCategory,
      }, { merge: true });
      
      // Then add the business to the businesses subcollection
      await categoryRef
          .collection('businesses')
          .doc(businessId)
          .set(businessData);
      
      successCount++;
      if ((i + 1) % 10 === 0) {
        console.log(`✅ Created ${i + 1}/100 businesses...`);
      }
    } catch (e) {
      errorCount++;
      console.error(`❌ Error creating business ${i + 1}:`, e.message);
    }
  }
  
  console.log('\n📊 Summary:');
  console.log(`✅ Successfully created: ${successCount} businesses`);
  console.log(`❌ Errors: ${errorCount} businesses`);
  console.log('\n🎉 Done! Test businesses have been uploaded to Firestore.');
  
  process.exit(0);
}

// Run the script
generateBusinesses().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});

