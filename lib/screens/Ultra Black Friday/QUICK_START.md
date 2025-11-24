# Ultra Black Friday - Quick Start Guide

## 📁 File Structure

```
lib/screens/Ultra Black Friday/
├── questionnaire_screen.dart          # Initial onboarding (9 questions)
├── black_card_home_screen.dart        # Main hub with tabs
├── deal_detail_screen.dart            # Individual deal view + claim
├── my_black_card_wallet_screen.dart   # User's claimed codes
├── black_card_detail_screen.dart      # Business info + contact
├── widgets/
│   ├── business_carousel.dart         # Horizontal business slider
│   ├── deal_card.dart                 # Deal grid/list item
│   ├── claimed_code_card.dart         # Wallet code card
│   └── code_claim_animation.dart      # Success animation
├── Readme                             # Original requirements
├── COMPONENTS_DOCUMENTATION.md        # Full documentation
└── QUICK_START.md                     # This file
```

## 🚀 Quick Integration

### Step 1: Add to Your Main Navigation
```dart
// In your main app navigation
ElevatedButton(
  child: Text('Ultra Black Friday'),
  onPressed: () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show login
      return;
    }
    
    // Check questionnaire status
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final completed = userDoc.data()?['ultraBlackFridayQuestionnaireCompleted'] ?? false;
    
    if (!completed) {
      // First time - show questionnaire
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuestionnaireScreen()),
      ).then((result) {
        if (result == true) {
          // Go to home after completion
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BlackCardHomeScreen()),
          );
        }
      });
    } else {
      // Already completed - go straight to home
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BlackCardHomeScreen()),
      );
    }
  },
)
```

### Step 2: Setup Firebase Collections

Create these collections in Firestore:

**Collection: `ultraBlackFriday/data/businesses`**
```json
{
  "businessId": "auto-generated",
  "name": "Soul Food Kitchen",
  "category": "Food & Restaurants",
  "description": "Authentic soul food...",
  "logoUrl": "https://...",
  "coverImageUrl": "https://...",
  "address": "123 Main St, City, State",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "phone": "+1234567890",
  "website": "https://...",
  "email": "info@...",
  "instagram": "https://instagram.com/...",
  "facebook": "https://facebook.com/...",
  "twitter": "https://twitter.com/...",
  "tiktok": "https://tiktok.com/@...",
  "isActive": true
}
```

**Collection: `ultraBlackFriday/data/deals`**
```json
{
  "dealId": "auto-generated",
  "businessId": "business123",
  "businessName": "Soul Food Kitchen",
  "discountText": "25% off your entire order",
  "description": "Get 25% off everything on the menu...",
  "terms": "Valid for dine-in only. Cannot be combined...",
  "logoUrl": "https://...",
  "imageUrl": "https://...",
  "totalCodes": 100,
  "claimedCount": 0,
  "expiresAt": "2025-11-30T23:59:59Z",
  "isActive": true
}
```

**Document: `ultraBlackFriday/settings`**
```json
{
  "todayTheme": "Wellness Wednesday"
}
```

### Step 3: Add Required Packages
```yaml
# pubspec.yaml
dependencies:
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  firebase_core: ^2.24.0
  url_launcher: ^6.2.0
  google_maps_flutter: ^2.5.0  # Optional

flutter:
  assets:
    - assets/Blackcardanimation.gif
```

Run:
```bash
flutter pub get
```

## 🎨 Color Palette

```dart
// Primary Brand Color
const primaryOrange = Color(0xFFFF6600);

// Backgrounds
const backgroundColor = Colors.black;
const cardBackground = Color(0xFF212121); // Colors.grey[900]

// Text
const primaryText = Colors.white;
const secondaryText = Color(0xFF9E9E9E); // Colors.grey[400]
```

## 🔥 Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ultraBlackFriday/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
    
    match /users/{userId}/claimedCodes/{codeId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## 📱 Screen Flow

```
Entry Point
    ↓
First Time User? → YES → QuestionnaireScreen (9 questions)
    ↓                           ↓
    NO                    Save preferences
    ↓                           ↓
BlackCardHomeScreen ←───────────┘
    ↓
Tab 1: Home                Tab 2: My Claimed Deals
    ↓                           ↓
- Today's Theme          MyBlackCardWalletScreen
- Business Carousel          ↓
- Deals Grid            ClaimedCodeCard (list)
    ↓                       ↓           ↓
DealDetailScreen        Redeem      Details
    ↓                   (Dialog)       ↓
Claim Code                    BlackCardDetailScreen
    ↓                         (Business info)
CodeClaimAnimationScreen
    ↓
Back to Home
```

## ⚡ Key Features

### Questionnaire Screen ✓
- 9 questions covering user preferences
- Beautiful UI with progress indicator
- Saves to Firebase user profile
- Only shows once

### Home Screen ✓
- Dynamic daily themes (Monday-Sunday)
- Recommended businesses carousel
- Active deals grid
- Real-time updates
- Pull to refresh

### Deal Details ✓
- Full deal information
- Time remaining badge
- Codes remaining counter
- One-tap code claiming
- Unique code generation

### Wallet ✓
- Filter: All / Active / Expired
- Status badges
- Quick redeem dialog
- Business details link

### Business Details ✓
- Contact information
- Google Maps integration
- Social media links
- One-tap call/email/directions

## 🔧 Testing Checklist

- [ ] User can complete questionnaire
- [ ] Questionnaire saves to Firestore
- [ ] Home screen loads deals
- [ ] Business carousel displays
- [ ] Can tap and view deal details
- [ ] Can claim a code successfully
- [ ] Animation plays after claiming
- [ ] Code appears in wallet
- [ ] Can filter wallet (All/Active/Expired)
- [ ] Can redeem code from wallet
- [ ] Business details screen works
- [ ] Map/directions work
- [ ] Phone/email/website links work
- [ ] Social media links work

## 📊 Analytics Setup (Optional)

Track user activity for business reports:

```dart
// Track views
FirebaseAnalytics.instance.logEvent(
  name: 'deal_viewed',
  parameters: {
    'deal_id': dealId,
    'business_id': businessId,
  },
);

// Track claims
FirebaseAnalytics.instance.logEvent(
  name: 'code_claimed',
  parameters: {
    'deal_id': dealId,
    'business_id': businessId,
    'code': code,
  },
);
```

## 🐛 Troubleshooting

**Deals not showing?**
- Check `isActive: true` in Firestore
- Check `expiresAt` is in the future
- Check user is authenticated

**Can't claim codes?**
- Check `totalCodes > claimedCount`
- Check deal not expired
- Check user hasn't already claimed

**Questionnaire not saving?**
- Check Firebase Auth is initialized
- Check user is logged in
- Check Firestore rules allow write

**Animation not showing?**
- Check asset path: `assets/Blackcardanimation.gif`
- Check pubspec.yaml includes asset
- Fallback gradient will show if GIF missing

## 📞 Support

For full documentation, see `COMPONENTS_DOCUMENTATION.md`

---

**Ready to launch! 🚀**

All UI components are created and ready to use. Just set up your Firebase data and you're good to go!


