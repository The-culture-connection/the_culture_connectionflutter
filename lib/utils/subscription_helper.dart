import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../screens/paywall_screen.dart';

class SubscriptionHelper {
  static final SubscriptionService _subscriptionService = SubscriptionService();
  
  /// Check if user has active subscription and navigate accordingly
  /// Returns true if user has subscription, false if they need to subscribe
  static Future<bool> checkSubscriptionAndNavigate({
    required BuildContext context,
    required Widget destinationScreen,
    required String screenName,
  }) async {
    print('SubscriptionHelper: checkSubscriptionAndNavigate called for $screenName');
    
    try {
      // Initialize subscription service
      print('SubscriptionHelper: Initializing subscription service...');
      await _subscriptionService.initialize();
      print('SubscriptionHelper: Subscription service initialized');
      
      // Check if user has active subscription
      print('SubscriptionHelper: Checking active subscription...');
      final hasActiveSubscription = await _subscriptionService.checkActiveSubscription();
      print('SubscriptionHelper: Has active subscription: $hasActiveSubscription');
      
      if (hasActiveSubscription) {
        // User has subscription, navigate to destination
        print('SubscriptionHelper: User has subscription, navigating to destination');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => destinationScreen,
          ),
        );
        print('SubscriptionHelper: Navigation completed');
        return true;
      } else {
        // User doesn't have subscription, show paywall
        print('SubscriptionHelper: User needs subscription, showing paywall');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaywallScreen(
              destinationScreen: destinationScreen,
              screenName: screenName,
            ),
          ),
        );
        print('SubscriptionHelper: Paywall navigation completed');
        return false;
      }
    } catch (e) {
      print('SubscriptionHelper: Error occurred: $e');
      print('SubscriptionHelper: Error type: ${e.runtimeType}');
      // Fallback: navigate directly to destination
      print('SubscriptionHelper: Fallback - navigating directly to destination');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => destinationScreen,
        ),
      );
      return true;
    }
  }
  
  /// Check subscription status without navigation
  static Future<bool> hasActiveSubscription() async {
    await _subscriptionService.initialize();
    return await _subscriptionService.checkActiveSubscription();
  }
}

