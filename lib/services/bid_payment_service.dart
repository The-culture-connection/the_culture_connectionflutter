import 'package:cloud_functions/cloud_functions.dart';
import '../models/black_friday_bid.dart';

/// Service for handling payment processing for Black Friday bids
/// Uses Stripe via Cloud Functions for secure payment processing
class BidPaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Create a payment intent to authorize payment for a bid
  /// The payment will be held but not charged until the bid is accepted
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String bidId,
    required String offerId,
    required String userId,
    String currency = 'usd',
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('createBidPaymentIntent');
      final result = await callable.call({
        'amount': (amount * 100).toInt(), // Convert to cents
        'currency': currency,
        'bidId': bidId,
        'offerId': offerId,
        'userId': userId,
        'capture_method': 'manual', // Don't charge immediately
      });

      return {
        'success': true,
        'paymentIntentId': result.data['paymentIntentId'],
        'clientSecret': result.data['clientSecret'],
      };
    } catch (e) {
      print('Error creating payment intent: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Capture (charge) a previously authorized payment
  /// Called when a bid is accepted by the offer creator
  Future<Map<String, dynamic>> capturePayment({
    required String paymentIntentId,
    required String bidId,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('captureBidPayment');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
        'bidId': bidId,
      });

      return {
        'success': true,
        'chargeId': result.data['chargeId'],
        'amount': result.data['amount'],
      };
    } catch (e) {
      print('Error capturing payment: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Cancel a payment intent
  /// Called when a bid is rejected, outbid, or cancelled
  Future<Map<String, dynamic>> cancelPaymentIntent({
    required String paymentIntentId,
    required String bidId,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('cancelBidPaymentIntent');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
        'bidId': bidId,
      });

      return {
        'success': true,
        'message': 'Payment authorization cancelled',
      };
    } catch (e) {
      print('Error cancelling payment intent: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Refund a payment
  /// Called if there's an issue after a payment has been captured
  Future<Map<String, dynamic>> refundPayment({
    required String chargeId,
    required String bidId,
    String? reason,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('refundBidPayment');
      final result = await callable.call({
        'chargeId': chargeId,
        'bidId': bidId,
        'reason': reason,
      });

      return {
        'success': true,
        'refundId': result.data['refundId'],
      };
    } catch (e) {
      print('Error refunding payment: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process a money bid with payment authorization
  /// This combines bid placement with payment intent creation
  Future<Map<String, dynamic>> processMoneyBid({
    required BlackFridayBid bid,
    required String dayKey,
    required Function(BlackFridayBid, String) onBidPlaced,
  }) async {
    try {
      // First, create payment intent
      final paymentResult = await createPaymentIntent(
        amount: bid.moneyAmount!,
        bidId: bid.id,
        offerId: bid.offerId,
        userId: bid.bidderId,
      );

      if (!paymentResult['success']) {
        return {
          'success': false,
          'error': 'Failed to authorize payment: ${paymentResult['error']}',
        };
      }

      // Update bid with payment intent ID
      final updatedBid = bid.copyWith(
        paymentIntentId: paymentResult['paymentIntentId'],
      );

      // Place the bid
      await onBidPlaced(updatedBid, dayKey);

      return {
        'success': true,
        'bid': updatedBid,
        'message': 'Bid placed successfully. Payment will be charged if accepted.',
      };
    } catch (e) {
      print('Error processing money bid: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle bid acceptance and charge payment
  Future<Map<String, dynamic>> handleBidAcceptance({
    required BlackFridayBid bid,
    required String dayKey,
    required Function(String, String, String, String, DateTime) onPaymentCaptured,
  }) async {
    if (bid.bidType == BidType.service) {
      // Service bids don't require payment processing
      return {
        'success': true,
        'message': 'Service bid accepted',
      };
    }

    if (bid.paymentIntentId == null) {
      return {
        'success': false,
        'error': 'No payment intent found for this bid',
      };
    }

    try {
      // Capture the payment
      final captureResult = await capturePayment(
        paymentIntentId: bid.paymentIntentId!,
        bidId: bid.id,
      );

      if (!captureResult['success']) {
        return {
          'success': false,
          'error': 'Failed to charge payment: ${captureResult['error']}',
        };
      }

      // Update bid with charge information
      await onPaymentCaptured(
        dayKey,
        bid.offerId,
        bid.id,
        captureResult['chargeId'],
        DateTime.now(),
      );

      return {
        'success': true,
        'message': 'Payment charged successfully',
        'chargeId': captureResult['chargeId'],
      };
    } catch (e) {
      print('Error handling bid acceptance: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle bid rejection and cancel payment authorization
  Future<Map<String, dynamic>> handleBidRejection({
    required BlackFridayBid bid,
  }) async {
    if (bid.bidType == BidType.service || bid.paymentIntentId == null) {
      // No payment to cancel
      return {
        'success': true,
        'message': 'Bid rejected',
      };
    }

    try {
      // Cancel the payment intent
      final cancelResult = await cancelPaymentIntent(
        paymentIntentId: bid.paymentIntentId!,
        bidId: bid.id,
      );

      return cancelResult;
    } catch (e) {
      print('Error handling bid rejection: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}




