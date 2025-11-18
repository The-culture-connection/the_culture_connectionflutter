# The Real Black Friday - Setup Guide

## Quick Start

Follow these steps to get The Real Black Friday event up and running.

## Step 1: Install Dependencies

### Flutter Dependencies
```bash
flutter pub get
```

### Cloud Functions Dependencies
```bash
cd functions
npm install
cd ..
```

## Step 2: Configure Stripe

### 2.1 Get Stripe Keys
1. Sign up at https://stripe.com
2. Go to Dashboard → Developers → API Keys
3. Copy your Secret Key (starts with `sk_test_...` for test mode)

### 2.2 Configure Firebase Functions
```bash
# Set Stripe secret key
firebase functions:config:set stripe.secret_key="YOUR_STRIPE_SECRET_KEY_HERE"

# Verify configuration
firebase functions:config:get
```

## Step 3: Create Firestore Indexes

### 3.1 Via Firebase Console
1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index" for each of the following:

**Index 1: User Bids by Status**
- Collection Group: `bids`
- Fields:
  - `bidderId` - Ascending
  - `status` - Ascending  
  - `timestamp` - Descending

**Index 2: User All Bids**
- Collection Group: `bids`
- Fields:
  - `bidderId` - Ascending
  - `timestamp` - Descending

**Index 3: Money Bids by Amount**
- Collection Group: `bids`
- Fields:
  - `bidType` - Ascending
  - `status` - Ascending
  - `moneyAmount` - Descending

**Index 4: Service Bids by Time**
- Collection Group: `bids`
- Fields:
  - `bidType` - Ascending
  - `status` - Ascending
  - `timestamp` - Descending

### 3.2 Via Firebase CLI (Alternative)
The indexes will be auto-created when you first query them, or you can use the Firebase Console.

## Step 4: Update Firestore Security Rules

Add these rules to your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Existing rules...
    
    // The Real Black Friday collection
    match /The Real Black Friday/{dayKey} {
      // Anyone can read offers
      match /offers/{offerId} {
        allow read: if true;
        
        // Bids subcollection
        match /bids/{bidId} {
          // Authenticated users can read bids
          allow read: if request.auth != null;
          
          // Users can create their own bids
          allow create: if request.auth != null && 
                          request.resource.data.bidderId == request.auth.uid;
          
          // Users can update/delete their own pending bids
          allow update, delete: if request.auth != null && 
                                   resource.data.bidderId == request.auth.uid &&
                                   resource.data.status == 'pending';
          
          // Offer creators can update bid status (accept/reject)
          allow update: if request.auth != null &&
                          get(/databases/$(database)/documents/The\ Real\ Black\ Friday/$(dayKey)/offers/$(offerId)).data.creatorId == request.auth.uid;
        }
      }
    }
    
    // Payment logs - read-only for admins
    match /payment_logs/{logId} {
      allow read, write: if false;
    }
  }
}
```

Deploy the rules:
```bash
firebase deploy --only firestore:rules
```

## Step 5: Deploy Cloud Functions

```bash
firebase deploy --only functions
```

This will deploy:
- `createBidPaymentIntent`
- `captureBidPayment`
- `cancelBidPaymentIntent`
- `refundBidPayment`
- `expireBidPayments` (scheduled)

## Step 6: Add Sample Offers to Firestore

### Option A: Via Firebase Console

1. Go to Firestore Database
2. Create collection: `The Real Black Friday`
3. Add document with ID: `November 28, 2025`
4. Inside that document, create subcollection: `offers`
5. Add 10 offer documents with this structure:

```json
{
  "title": "Professional App Development",
  "description": "Get a fully functional mobile app built from scratch using Flutter and Firebase",
  "creatorId": "YOUR_USER_ID",
  "creatorName": "John Developer",
  "creatorPhotoUrl": "https://example.com/photo.jpg",
  "videoUrl": "https://example.com/video.mp4",
  "basePrice": 150.00,
  "offerType": "service",
  "eventDate": "November 28, 2025 00:00:00 UTC",
  "createdAt": "[Current Timestamp]",
  "isActive": true,
  "category": "Technology"
}
```

**Important**: Set `eventDate` as a Timestamp type, not string!

### Option B: Programmatically (Recommended for multiple entries)

Create a script file `scripts/add_sample_offers.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  final dayKey = 'November 28, 2025';
  
  final offers = [
    {
      'title': 'Professional App Development',
      'description': 'Get a fully functional mobile app built from scratch',
      'creatorId': 'user123',
      'creatorName': 'John Developer',
      'creatorPhotoUrl': '',
      'videoUrl': '',
      'basePrice': 150.0,
      'offerType': 'service',
      'eventDate': Timestamp.fromDate(DateTime(2025, 11, 28)),
      'createdAt': Timestamp.now(),
      'isActive': true,
      'category': 'Technology',
    },
    {
      'title': 'Brand Identity Design',
      'description': 'Complete brand identity package with logo and style guide',
      'creatorId': 'user456',
      'creatorName': 'Sarah Designer',
      'creatorPhotoUrl': '',
      'videoUrl': '',
      'basePrice': 200.0,
      'offerType': 'service',
      'eventDate': Timestamp.fromDate(DateTime(2025, 11, 28)),
      'createdAt': Timestamp.now(),
      'isActive': true,
      'category': 'Design',
    },
    // Add 8 more offers...
  ];
  
  for (final offer in offers) {
    await firestore
        .collection('The Real Black Friday')
        .doc(dayKey)
        .collection('offers')
        .add(offer);
    print('Added offer: ${offer['title']}');
  }
  
  print('All offers added successfully!');
}
```

## Step 7: Test the Application

### 7.1 Before Event (Countdown Screen)
1. Ensure current date is before November 28, 2025
2. Launch app and navigate to Black Friday screen
3. Should see countdown timer

### 7.2 During Event (Active Screen)
**To test now, temporarily change the date check:**

In `lib/services/black_friday_service.dart`, modify `isEventActive()`:
```dart
bool isEventActive() {
  return true; // Force active for testing
}
```

Then:
1. Launch app
2. Should see grid of offers
3. Tap an offer to see details
4. Try placing a money bid (use Stripe test card: 4242 4242 4242 4242)
5. Try placing a service bid
6. Check bid dashboard

### 7.3 Test Payment Flow
```dart
// Test cards
4242 4242 4242 4242 - Success
4000 0000 0000 0002 - Card declined
4000 0000 0000 9995 - Insufficient funds
```

## Step 8: Configure for Each Day

Repeat the offer creation process for each event day:
- November 28, 2025 (Day 1)
- November 29, 2025 (Day 2)
- November 30, 2025 (Day 3)
- December 1, 2025 (Day 4)
- December 2, 2025 (Day 5)
- December 3, 2025 (Day 6)

Each day should have 10 unique offers.

## Monitoring & Maintenance

### Check Cloud Functions Logs
```bash
firebase functions:log --only expireBidPayments
firebase functions:log --only createBidPaymentIntent
```

### Monitor Firestore Usage
1. Go to Firebase Console
2. Check Firestore usage and limits
3. Monitor read/write operations

### Stripe Dashboard
1. Monitor test payments at https://dashboard.stripe.com/test/payments
2. Check for failed authorizations
3. Review disputes/refunds

## Production Deployment

### 1. Switch to Production Stripe Keys
```bash
firebase functions:config:set stripe.secret_key="sk_live_..."
```

### 2. Test Thoroughly
- Complete end-to-end user flows
- Test all payment scenarios
- Verify midnight expiration works
- Check timezone handling

### 3. Final Deployment
```bash
firebase deploy --only functions
flutter build apk --release  # For Android
flutter build ipa --release  # For iOS
```

### 4. Monitor Launch
- Watch Cloud Functions logs
- Monitor error rates
- Check user feedback
- Track payment success rates

## Troubleshooting

### Issue: "No offers available today"
**Solution**: 
- Verify date key format exactly matches: "Month Day, Year"
- Check `eventDate` field is set correctly
- Ensure `isActive` is true

### Issue: Payment authorization fails
**Solution**:
- Check Stripe API key is configured
- Verify Cloud Functions are deployed
- Test with Stripe test cards first
- Check Firebase Functions logs

### Issue: Bids not appearing
**Solution**:
- Ensure Firestore indexes are created
- Check security rules allow read access
- Verify user is authenticated

### Issue: Video not playing
**Solution**:
- Check video URL is publicly accessible
- Verify video format (MP4 recommended)
- Test with sample video first

## Support Resources

- **Stripe Documentation**: https://stripe.com/docs
- **Firebase Functions**: https://firebase.google.com/docs/functions
- **Flutter Video Player**: https://pub.dev/packages/video_player

## Checklist

- [ ] Flutter dependencies installed
- [ ] Cloud Functions dependencies installed
- [ ] Stripe account created and configured
- [ ] Firestore indexes created
- [ ] Security rules deployed
- [ ] Cloud Functions deployed
- [ ] Sample offers added for all 6 days
- [ ] Test bidding flow completed
- [ ] Payment testing completed
- [ ] Scheduled function tested
- [ ] Production keys configured (when ready)
- [ ] App built and tested

## Next Steps

1. Add real creator profiles
2. Upload professional videos for each offer
3. Set up push notifications for bid updates
4. Create admin dashboard for monitoring
5. Add analytics tracking
6. Prepare marketing materials
7. Test with beta users

---

**Questions?** Review the main documentation in `BLACK_FRIDAY_EVENT_DOCUMENTATION.md`

