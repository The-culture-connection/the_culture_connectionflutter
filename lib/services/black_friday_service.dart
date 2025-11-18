import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/black_friday_offer.dart';
import '../models/black_friday_bid.dart';

/// Service for The Real Black Friday event operations
class BlackFridayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _blackFridayCollection => 
      _firestore.collection('The Real Black Friday');

  /// Get the current day's date key (format: "November 28, 2025")
  String _getDayKey(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get today's date key
  String getTodayKey() {
    // TODO: Remove this line when ready for production
    return 'November 28, 2025'; // Force test date
    
    /* Uncomment this for production:
    return _getDayKey(DateTime.now());
    */
  }

  /// Get today's title from Firebase
  Future<String> getTodaysTitle() async {
    try {
      final doc = await _blackFridayCollection.doc(getTodayKey()).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['title'] ?? 'CAREER & BUSINESS GROWTH';
      }
      return 'CAREER & BUSINESS GROWTH';
    } catch (e) {
      print('Error getting today\'s title: $e');
      return 'CAREER & BUSINESS GROWTH';
    }
  }

  /// Stream today's title (real-time updates)
  Stream<String> streamTodaysTitle() {
    return _blackFridayCollection
        .doc(getTodayKey())
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>?;
            return data?['title'] ?? 'CAREER & BUSINESS GROWTH';
          }
          return 'CAREER & BUSINESS GROWTH';
        });
  }

  /// Stream today's offers (10 offers for the current day)
  Stream<List<BlackFridayOffer>> streamTodaysOffers() {
    // For testing, query without date filters to get all offers for the day
    return _blackFridayCollection
        .doc(getTodayKey())
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlackFridayOffer.fromFirestore(doc))
            .toList());
  }

  /// Stream offers for a specific date
  Stream<List<BlackFridayOffer>> streamOffersForDate(DateTime date) {
    final dayKey = _getDayKey(date);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _blackFridayCollection
        .doc(dayKey)
        .collection('offers')
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlackFridayOffer.fromFirestore(doc))
            .toList());
  }

  /// Get a specific offer
  Future<BlackFridayOffer?> getOffer(String dayKey, String offerId) async {
    try {
      final doc = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .get();
      
      if (!doc.exists) return null;
      return BlackFridayOffer.fromFirestore(doc);
    } catch (e) {
      print('Error getting offer: $e');
      return null;
    }
  }

  /// Stream bids for a specific offer
  Stream<List<BlackFridayBid>> streamOfferBids(String dayKey, String offerId) {
    return _blackFridayCollection
        .doc(dayKey)
        .collection('offers')
        .doc(offerId)
        .collection('bids')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlackFridayBid.fromFirestore(doc))
            .toList());
  }

  /// Get highest money bid for an offer
  Future<BlackFridayBid?> getHighestMoneyBid(String dayKey, String offerId) async {
    try {
      final snapshot = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .where('bidType', isEqualTo: 'money')
          .where('status', whereIn: ['pending', 'accepted'])
          .orderBy('moneyAmount', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return BlackFridayBid.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting highest money bid: $e');
      return null;
    }
  }

  /// Get most recent service bid for an offer
  Future<BlackFridayBid?> getMostRecentServiceBid(String dayKey, String offerId) async {
    try {
      final snapshot = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .where('bidType', isEqualTo: 'service')
          .where('status', whereIn: ['pending', 'accepted'])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return BlackFridayBid.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting most recent service bid: $e');
      return null;
    }
  }

  /// Place a bid on an offer
  Future<String> placeBid(BlackFridayBid bid, String dayKey) async {
    try {
      final docRef = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(bid.offerId)
          .collection('bids')
          .add(bid.toFirestore());

      // Update outbid status for other money bids if this is a money bid
      if (bid.bidType == BidType.money) {
        await _updateOutbidBids(dayKey, bid.offerId, bid.moneyAmount ?? 0, docRef.id);
      }

      return docRef.id;
    } catch (e) {
      print('Error placing bid: $e');
      rethrow;
    }
  }

  /// Update status of bids that have been outbid
  Future<void> _updateOutbidBids(String dayKey, String offerId, double newBidAmount, String newBidId) async {
    try {
      final snapshot = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .where('bidType', isEqualTo: 'money')
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        if (doc.id != newBidId) {
          final bid = BlackFridayBid.fromFirestore(doc);
          if (bid.moneyAmount != null && bid.moneyAmount! < newBidAmount) {
            batch.update(doc.reference, {'status': 'outbid'});
          }
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error updating outbid bids: $e');
    }
  }

  /// Accept a bid (called by offer creator)
  Future<void> acceptBid(String dayKey, String offerId, String bidId) async {
    try {
      await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .doc(bidId)
          .update({
        'status': 'accepted',
        'acceptedAt': Timestamp.now(),
      });

      // Reject all other bids for this offer
      await _rejectOtherBids(dayKey, offerId, bidId);
    } catch (e) {
      print('Error accepting bid: $e');
      rethrow;
    }
  }

  /// Reject other bids when one is accepted
  Future<void> _rejectOtherBids(String dayKey, String offerId, String acceptedBidId) async {
    try {
      final snapshot = await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        if (doc.id != acceptedBidId) {
          batch.update(doc.reference, {'status': 'rejected'});
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error rejecting other bids: $e');
    }
  }

  /// Update bid with payment information
  Future<void> updateBidPayment(String dayKey, String offerId, String bidId, 
      String paymentIntentId, {String? chargeId, DateTime? chargedAt}) async {
    try {
      final updateData = <String, dynamic>{
        'paymentIntentId': paymentIntentId,
      };

      if (chargeId != null) {
        updateData['chargeId'] = chargeId;
      }
      if (chargedAt != null) {
        updateData['chargedAt'] = Timestamp.fromDate(chargedAt);
      }

      await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .doc(bidId)
          .update(updateData);
    } catch (e) {
      print('Error updating bid payment: $e');
      rethrow;
    }
  }

  /// Stream user's bids across all days
  Stream<List<BlackFridayBid>> streamUserBids(String userId) {
    // This requires a collection group query
    return _firestore
        .collectionGroup('bids')
        .where('bidderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlackFridayBid.fromFirestore(doc))
            .toList());
  }

  /// Get user's active bids (pending or accepted)
  Stream<List<BlackFridayBid>> streamUserActiveBids(String userId) {
    return _firestore
        .collectionGroup('bids')
        .where('bidderId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlackFridayBid.fromFirestore(doc))
            .toList());
  }

  /// Cancel a bid (before it's accepted)
  Future<void> cancelBid(String dayKey, String offerId, String bidId) async {
    try {
      await _blackFridayCollection
          .doc(dayKey)
          .collection('offers')
          .doc(offerId)
          .collection('bids')
          .doc(bidId)
          .update({
        'status': 'cancelled',
      });
    } catch (e) {
      print('Error cancelling bid: $e');
      rethrow;
    }
  }

  /// Check if event is currently active
  bool isEventActive() {
    // TODO: Remove this line when ready for production
    return true; // Force active for testing
    
    /* Uncomment this for production:
    final now = DateTime.now();
    final startDate = DateTime(2025, 11, 28);
    final endDate = DateTime(2025, 12, 3, 23, 59, 59);
    return now.isAfter(startDate) && now.isBefore(endDate);
    */
  }

  /// Get days remaining in event
  int getDaysRemaining() {
    final now = DateTime.now();
    final endDate = DateTime(2025, 12, 3, 23, 59, 59);
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  /// Get time until next daily reset (midnight ET)
  Duration getTimeUntilReset() {
    final now = DateTime.now();
    // Convert to ET (UTC-5 or UTC-4 depending on DST)
    // For simplicity, using UTC-5 (EST)
    final nowET = now.toUtc().subtract(const Duration(hours: 5));
    final nextMidnightET = DateTime(nowET.year, nowET.month, nowET.day + 1);
    return nextMidnightET.difference(nowET);
  }
}

