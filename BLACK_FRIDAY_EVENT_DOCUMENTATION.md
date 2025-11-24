# The Real Black Friday Event - Implementation Documentation

## Overview

The Real Black Friday is a 5-day in-app event (November 28 - December 3, 2025) that showcases 10 Black creators, professionals, and brands each day. Users can bid on offers using either money or skill-for-skill trades.

## Features

### 1. **Landing Page**
- **Countdown Screen**: Shows before November 28, 2025
- **Active Event Screen**: Grid view of 10 daily offers with:
  - Creator profile photos
  - Offer titles and descriptions
  - Navigation to bid detail screen
  - "Bid Dashboard" button

### 2. **Bid Detail Screen**
- Video player for offer explanation
- Creator profile information
- Current highest money bid
- Most recent service bid
- Two bidding options:
  - **Money Bid**: Enter dollar amount
  - **Service Bid**: Describe skill exchange

### 3. **Bid Dashboard**
- List of user's active bids
- Bid status indicators:
  - **Pending**: Awaiting acceptance
  - **Accepted**: Bid won
  - **Outbid**: Higher bid placed
  - **Rejected**: Creator declined
  - **Expired**: Day ended without acceptance
  - **Cancelled**: User cancelled bid

### 4. **Payment Processing**
- Payment authorization (not charged) when money bid placed
- Automatic charge when bid is accepted
- Automatic cancellation when bid is rejected/outbid
- Automatic expiration at midnight for unaccepted bids

### 5. **Auto-Renewal**
- Daily content rotation at midnight ET
- Automatic expiration of previous day's bids
- Payment intent cancellation for expired bids

## Architecture

### Data Models

#### BlackFridayOffer
```dart
- id: String
- title: String
- description: String
- creatorId: String
- creatorName: String
- creatorPhotoUrl: String
- videoUrl: String
- basePrice: double
- offerType: String (service/product)
- eventDate: DateTime
- createdAt: DateTime
- isActive: bool
- category: String?
- metadata: Map?
```

#### BlackFridayBid
```dart
- id: String
- offerId: String
- bidderId: String
- bidderName: String
- bidderPhotoUrl: String
- bidType: BidType (money/service)
- moneyAmount: double? (for money bids)
- serviceDescription: String? (for service bids)
- serviceCategory: String? (for service bids)
- timestamp: DateTime
- status: BidStatus
- paymentIntentId: String? (Stripe payment intent)
- chargeId: String? (after acceptance)
- acceptedAt: DateTime?
- chargedAt: DateTime?
```

### Firebase Structure

```
The Real Black Friday/
  ├── November 28, 2025/
  │   └── offers/
  │       ├── {offerId}/
  │       │   ├── [offer data]
  │       │   └── bids/
  │       │       └── {bidId}/ [bid data]
  ├── November 29, 2025/
  │   └── offers/...
  ├── November 30, 2025/
  │   └── offers/...
  ├── December 1, 2025/
  │   └── offers/...
  ├── December 2, 2025/
  │   └── offers/...
  └── December 3, 2025/
      └── offers/...

payment_logs/
  └── {logId}/ [payment transaction logs]
```

### Services

#### BlackFridayService
- `streamTodaysOffers()`: Get current day's 10 offers
- `streamOffersForDate(DateTime)`: Get offers for specific date
- `streamOfferBids(dayKey, offerId)`: Stream all bids for an offer
- `getHighestMoneyBid(dayKey, offerId)`: Get current highest money bid
- `getMostRecentServiceBid(dayKey, offerId)`: Get latest service bid
- `placeBid(bid, dayKey)`: Place a new bid
- `acceptBid(dayKey, offerId, bidId)`: Accept a bid (creator action)
- `streamUserBids(userId)`: Get all user's bids
- `streamUserActiveBids(userId)`: Get user's pending/accepted bids
- `cancelBid(dayKey, offerId, bidId)`: Cancel a bid
- `isEventActive()`: Check if event is currently running
- `getDaysRemaining()`: Get days left in event
- `getTimeUntilReset()`: Time until next midnight reset

#### BidPaymentService
- `createPaymentIntent()`: Authorize payment (not charged)
- `capturePayment()`: Charge authorized payment (when bid accepted)
- `cancelPaymentIntent()`: Cancel authorization (when bid rejected)
- `refundPayment()`: Refund charged payment (if issue occurs)
- `processMoneyBid()`: Combined bid placement + payment authorization
- `handleBidAcceptance()`: Handle bid acceptance with payment capture
- `handleBidRejection()`: Handle rejection with payment cancellation

### Cloud Functions

#### Payment Functions (Firebase Cloud Functions + Stripe)

1. **createBidPaymentIntent**
   - Creates Stripe payment intent with manual capture
   - Authorizes payment without charging
   - Stores payment intent ID with bid

2. **captureBidPayment**
   - Captures (charges) previously authorized payment
   - Called when creator accepts bid
   - Logs transaction in payment_logs collection

3. **cancelBidPaymentIntent**
   - Cancels payment authorization
   - Called when bid is rejected, outbid, or cancelled
   - Releases hold on user's payment method

4. **refundBidPayment**
   - Refunds a captured payment
   - Called if issue occurs after acceptance
   - Logs refund in payment_logs collection

5. **expireBidPayments** (Scheduled - Runs at midnight ET)
   - Automatically expires unaccepted bids from previous day
   - Cancels payment intents for expired bids
   - Updates bid status to 'expired'

## Setup Instructions

### 1. Firebase Configuration

#### Firestore Indexes
Create the following composite indexes in Firestore:

```
Collection Group: bids
Fields:
- bidderId (Ascending)
- status (Ascending)
- timestamp (Descending)

Collection Group: bids
Fields:
- bidderId (Ascending)
- timestamp (Descending)

Collection Group: bids
Fields:
- bidType (Ascending)
- status (Ascending)
- moneyAmount (Descending)

Collection Group: bids
Fields:
- bidType (Ascending)
- status (Ascending)
- timestamp (Descending)
```

#### Firestore Security Rules
```javascript
// The Real Black Friday collection
match /The Real Black Friday/{dayKey} {
  // Anyone can read offers
  match /offers/{offerId} {
    allow read: if true;
    
    // Only authenticated users can read bids
    match /bids/{bidId} {
      allow read: if request.auth != null;
      // Users can create their own bids
      allow create: if request.auth != null && 
                      request.resource.data.bidderId == request.auth.uid;
      // Users can update their own bids (cancel)
      allow update: if request.auth != null && 
                      resource.data.bidderId == request.auth.uid;
    }
  }
}

// Payment logs - admin only
match /payment_logs/{logId} {
  allow read, write: if false;
}
```

### 2. Stripe Setup

1. **Create Stripe Account**: https://stripe.com
2. **Get API Keys**: Dashboard → Developers → API Keys
3. **Configure Firebase**:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_..."
   ```
4. **Test Cards**:
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`

### 3. Cloud Functions Deployment

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 4. Populate Test Data

Create test offers in Firestore:

```javascript
{
  "title": "App Creation",
  "description": "Create your app from start to finish with Flutter and Firebase",
  "creatorId": "user_id_here",
  "creatorName": "John Doe",
  "creatorPhotoUrl": "https://...",
  "videoUrl": "https://...",
  "basePrice": 100.00,
  "offerType": "service",
  "eventDate": Timestamp(November 28, 2025),
  "createdAt": Timestamp(now),
  "isActive": true
}
```

## User Flow

### Bidding Process

1. **Browse Offers**
   - User opens app during event dates
   - Sees grid of 10 daily offers
   - Taps offer card to view details

2. **View Offer Details**
   - Watches video explanation
   - Reviews current bids
   - Decides to bid with money or service

3. **Place Money Bid**
   - Enters bid amount (minimum: base price or highest bid + $1)
   - Payment method authorized (NOT charged)
   - Bid appears as "Pending" in dashboard

4. **Place Service Bid**
   - Enters service category and description
   - Bid placed immediately (no payment needed)
   - Appears as "Pending" in dashboard

5. **Bid Acceptance**
   - Creator reviews all bids
   - Accepts highest money bid OR most recent service bid
   - For money bids: Payment automatically captured
   - For service bids: Parties coordinate exchange
   - Winning bidder notified

6. **Daily Reset**
   - At midnight ET, day's offers end
   - Unaccepted bids marked "Expired"
   - Payment authorizations cancelled
   - New day's offers go live

## Testing Checklist

- [ ] Countdown screen shows before November 28
- [ ] Active event screen shows during event dates
- [ ] Grid displays 10 offers per day
- [ ] Video playback works in bid detail screen
- [ ] Money bid authorization (not charging)
- [ ] Service bid placement
- [ ] Bid dashboard shows user's bids
- [ ] Status updates (pending → accepted/outbid)
- [ ] Payment capture on acceptance
- [ ] Payment cancellation on rejection
- [ ] Daily expiration at midnight
- [ ] Proper timezone handling (ET)

## Troubleshooting

### "No offers available today"
- Check Firestore data exists for current date
- Verify date format: "Month Day, Year" (e.g., "November 28, 2025")
- Ensure `isActive` is true and `eventDate` is correct

### Payment Authorization Failing
- Verify Stripe API keys configured
- Check Cloud Functions deployed
- Review Cloud Functions logs: `firebase functions:log`
- Test with Stripe test cards

### Bids Not Showing
- Check Firestore composite indexes created
- Verify user is authenticated
- Review security rules allow read access

### Video Not Playing
- Ensure video URL is accessible
- Check video format compatibility
- Verify network connectivity

## Future Enhancements

- Push notifications for bid status changes
- In-app messaging between bidders and creators
- Bid history and analytics
- Featured categories filter
- Search functionality
- User ratings and reviews
- Automatic winner selection based on criteria
- Email notifications for bid updates

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review Cloud Functions logs
3. Verify Firestore data structure
4. Test Stripe integration in test mode first
5. Ensure all indexes are created

## License & Credits

The Real Black Friday Event
Culture Connection App
© 2025 All Rights Reserved




