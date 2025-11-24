# Ultra Black Friday - UI Components Documentation

## Overview
This document describes all the UI components created for the Ultra Black Friday in-app event feature. All components are located in the `lib/screens/Ultra Black Friday/` directory.

## Created Files

### Main Screens

#### 1. `questionnaire_screen.dart`
**Purpose**: Initial onboarding questionnaire that collects user preferences

**Features**:
- 9-question survey covering:
  - Business interests (multi-select)
  - Top goals (multi-select)
  - Online vs in-person preference (single select)
  - Shopping frequency (single select)
  - Spending areas (multi-select, max 3)
  - Life stages (multi-select)
  - Price range (slider, 1-5 dollar signs)
  - Event preferences (multi-select)
  - Upcoming plans (multi-select)
- Progress indicator showing current question (X/9)
- Beautiful black theme with orange (#FF6600) accents
- Saves responses to Firebase user profile
- Only shown on first visit

**Firebase Structure**:
```
users/{userId}
  └─ ultraBlackFridayPreferences: {
       businessInterests: [...],
       topGoals: [...],
       preferredMode: "...",
       shoppingFrequency: "...",
       spendingAreas: [...],
       lifeStages: [...],
       priceRange: 1-5,
       eventPreferences: [...],
       upcomingPlans: [...],
       completedAt: Timestamp
     }
  └─ ultraBlackFridayQuestionnaireCompleted: true
```

---

#### 2. `black_card_home_screen.dart`
**Purpose**: Main hub with two tabs - Home and My Claimed Deals

**Features**:
- Tab 1: Home
  - Dynamic "Today's Theme" header (changes by day of week)
  - "Businesses You Might Like" horizontal carousel
  - Grid view of today's active deals
  - Pull-to-refresh functionality
  - Time-left badges on deals
- Tab 2: My Claimed Deals (embeds MyBlackCardWalletScreen)
- Real-time updates via Firestore streams

**Firebase Collections Used**:
```
ultraBlackFriday/settings
  └─ todayTheme: "Wellness Wednesday"

ultraBlackFriday/data/businesses
  └─ {businessId}: {
       name, category, logoUrl, coverImageUrl, description, isActive
     }

ultraBlackFriday/data/deals
  └─ {dealId}: {
       businessId, businessName, discountText, description, terms,
       logoUrl, imageUrl, totalCodes, claimedCount, expiresAt, isActive
     }
```

---

#### 3. `deal_detail_screen.dart`
**Purpose**: Shows full details of a specific deal with claim functionality

**Features**:
- Business logo and name
- Deal image and discount text
- Time remaining badge (color changes when < 24h left)
- Codes remaining counter
- Full description and terms & conditions
- "Claim Code" button (disabled if exhausted/claimed/expired)
- Generates unique code: `BUSINESSNAME12345` format
- Shows claimed code if already claimed
- Triggers animation screen after successful claim

**Code Generation**:
- Format: Business name (uppercase, no spaces) + 5-digit random number
- Example: `SOULFOODS42158`

**Claim Process**:
1. User taps "Claim Code"
2. System generates unique code
3. Adds to user's claimedCodes subcollection
4. Increments deal's claimedCount
5. Shows CodeClaimAnimationScreen
6. Returns to detail view

---

#### 4. `my_black_card_wallet_screen.dart`
**Purpose**: Lists all claimed codes with filtering options

**Features**:
- Filter chips: All / Active / Expired
- List of claimed codes with:
  - Business logo and name
  - Discount text
  - Status badges (ACTIVE, EXPIRED, REDEEMED)
  - Expiration date/time
  - Two action buttons: Details & Redeem
- "Redeem" button opens dialog showing:
  - Large code display
  - Business name
  - "Done" button to close
- Empty states for no codes

**User Claimed Codes Structure**:
```
users/{userId}/claimedCodes/{codeId}
  └─ dealId: "..."
  └─ businessName: "..."
  └─ businessId: "..."
  └─ code: "BUSINESSNAME12345"
  └─ claimedAt: Timestamp
  └─ expiresAt: Timestamp
  └─ discountText: "..."
  └─ logoUrl: "..."
  └─ isRedeemed: false
```

---

#### 5. `black_card_detail_screen.dart`
**Purpose**: Full business information and redeem location details

**Features**:
- Business cover image and logo
- Business name and category badge
- About section with full description
- "Where to Redeem" section with:
  - Full address
  - "Get Directions" button (opens Google Maps)
- Contact information:
  - Phone (tap to call)
  - Website (tap to open)
  - Email (tap to email)
- Social media buttons:
  - Instagram
  - Facebook
  - Twitter
  - TikTok

**Business Data Structure**:
```
ultraBlackFriday/data/businesses/{businessId}
  └─ name: "..."
  └─ category: "Food & Restaurants"
  └─ description: "..."
  └─ logoUrl: "..."
  └─ coverImageUrl: "..."
  └─ address: "..."
  └─ latitude: 40.7128
  └─ longitude: -74.0060
  └─ phone: "+1234567890"
  └─ website: "https://..."
  └─ email: "..."
  └─ instagram: "https://..."
  └─ facebook: "https://..."
  └─ twitter: "https://..."
  └─ tiktok: "https://..."
  └─ isActive: true
```

---

### Reusable Widget Components

#### 1. `widgets/business_carousel.dart`
**Purpose**: Horizontal scrolling carousel of recommended businesses

**Features**:
- Card design with cover image and logo overlay
- Business name and category
- Tap to show quick view bottom sheet with:
  - Full logo and business name
  - Category
  - Description
  - "Got it!" button

---

#### 2. `widgets/deal_card.dart`
**Purpose**: Individual deal card for grid/list views

**Features**:
- Deal image with gradient overlay
- Business logo overlay (bottom-left corner)
- Time remaining badge (top-right)
  - Red background when < 24h remaining
- Business name and discount text
- "X codes left" indicator
  - Red color when < 10 codes remaining
- Tap to open deal detail screen

---

#### 3. `widgets/claimed_code_card.dart`
**Purpose**: Card displaying a claimed code in the wallet

**Features**:
- Business logo and name
- Status badge: ACTIVE / EXPIRED / REDEEMED
- Discount text in orange
- Expiration date with icon
- Two action buttons:
  - "Details" - Opens business detail screen
  - "Redeem" - Shows code in dialog (disabled if expired)
- Visual distinction for expired codes (red border)

---

#### 4. `widgets/code_claim_animation.dart`
**Purpose**: Celebratory animation after claiming a code

**Features**:
- Black background with animated GIF (assets/Blackcardanimation.gif)
- Animated checkmark with scale and fade effects
- "Code Claimed!" text
- Displays the unique code
- Instruction text: "Check 'My Claimed Deals' to redeem"
- Auto-closes after 3 seconds
- Close button (X) in top-right corner

**Fallback**: If GIF is missing, shows radial gradient animation

---

## Color Scheme

### Primary Colors
- **Orange Accent**: `#FF6600` (main brand color)
- **Secondary Orange**: `#FF8833` (gradients)

### Background Colors
- **Primary Background**: `Colors.black`
- **Card Background**: `Colors.grey[900]`
- **Border**: `Colors.grey[800]`

### Text Colors
- **Primary Text**: `Colors.white`
- **Secondary Text**: `Colors.grey[400]`
- **Tertiary Text**: `Colors.grey[600]`

### Status Colors
- **Active/Success**: Orange (`#FF6600`)
- **Redeemed**: `Colors.green`
- **Expired/Error**: `Colors.red`
- **Warning**: `Colors.yellow` / `Colors.orange`

---

## Integration Guide

### 1. Navigation to Questionnaire
```dart
// Check if user has completed questionnaire
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();

final completed = userDoc.data()?['ultraBlackFridayQuestionnaireCompleted'] ?? false;

if (!completed) {
  // Show questionnaire
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const QuestionnaireScreen(),
    ),
  );
  
  if (result == true) {
    // Questionnaire completed, show home screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BlackCardHomeScreen(),
      ),
    );
  }
} else {
  // Go directly to home screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BlackCardHomeScreen(),
    ),
  );
}
```

### 2. Required Dependencies
Add these to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^latest_version
  firebase_auth: ^latest_version
  firebase_core: ^latest_version
  url_launcher: ^latest_version
  google_maps_flutter: ^latest_version  # Optional, for maps
```

### 3. Asset Configuration
Ensure this asset is in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/Blackcardanimation.gif
```

---

## Firebase Security Rules

### Recommended Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Ultra Black Friday public data (read-only)
    match /ultraBlackFriday/data/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via backend
    }
    
    // Ultra Black Friday settings (read-only)
    match /ultraBlackFriday/settings {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via backend
    }
    
    // User's claimed codes (private)
    match /users/{userId}/claimedCodes/{codeId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User preferences
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Business Analytics Integration

### Track User Interactions
To generate reports for businesses based on customer activity:

```dart
// Track deal view
await FirebaseFirestore.instance
    .collection('analytics')
    .doc('ultraBlackFriday')
    .collection('dealViews')
    .add({
  'userId': userId,
  'dealId': dealId,
  'businessId': businessId,
  'timestamp': FieldValue.serverTimestamp(),
});

// Track code claim
await FirebaseFirestore.instance
    .collection('analytics')
    .doc('ultraBlackFriday')
    .collection('codeClaims')
    .add({
  'userId': userId,
  'dealId': dealId,
  'businessId': businessId,
  'code': generatedCode,
  'timestamp': FieldValue.serverTimestamp(),
});

// Track code redemption
await FirebaseFirestore.instance
    .collection('analytics')
    .doc('ultraBlackFriday')
    .collection('codeRedemptions')
    .add({
  'userId': userId,
  'dealId': dealId,
  'businessId': businessId,
  'code': code,
  'timestamp': FieldValue.serverTimestamp(),
});
```

---

## Daily Theme Schedule

The home screen automatically displays a different theme based on the day of the week:

| Day | Theme |
|-----|-------|
| Monday | Motivation Monday |
| Tuesday | Tasty Tuesday |
| Wednesday | Wellness Wednesday |
| Thursday | Thrifty Thursday |
| Friday | Feel Good Friday |
| Saturday | Self-Care Saturday |
| Sunday | Support Sunday |

You can override this by setting a custom theme in Firestore:
```
ultraBlackFriday/settings
  └─ todayTheme: "Your Custom Theme"
```

---

## Future Enhancements

### Recommended Features
1. **Push Notifications**: Notify users when new deals match their preferences
2. **Deal Favorites**: Allow users to save businesses for later
3. **Search & Filters**: Search businesses by name, category, or location
4. **Social Sharing**: Share deals with friends
5. **Referral System**: Earn bonus codes for referring friends
6. **Business Dashboard**: Separate app/web portal for businesses to:
   - View analytics
   - See customer demographics
   - Track code redemptions
   - Export reports

### Possible Improvements
1. Add animations between screens
2. Implement skeleton loading screens
3. Add haptic feedback on interactions
4. Support for multiple languages
5. Dark/Light theme toggle (currently light-only per user preference [[memory:11443408]])
6. Offline caching for better performance

---

## Support & Maintenance

### Common Issues

**Issue**: "No deals showing"
- **Check**: Verify deals exist in Firestore with `isActive: true` and future `expiresAt` dates

**Issue**: "Questionnaire not saving"
- **Check**: User authentication status and Firestore permissions

**Issue**: "Animation GIF not playing"
- **Check**: Asset path in pubspec.yaml and file exists in assets folder

**Issue**: "Can't claim codes"
- **Check**: Deal hasn't reached `totalCodes` limit and isn't expired

---

## Credits

Built with ❤️ using Flutter and Firebase.

All UI components follow Material Design principles with a custom black and orange theme.

---

**Last Updated**: November 24, 2025
**Version**: 1.0.0


