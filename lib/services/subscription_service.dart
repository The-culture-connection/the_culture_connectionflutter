import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../constants/app_colors.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Your Apple App Store subscription product ID
  static const String _monthlySubscriptionId = 'com.cultureconnect.premium.monthly3';
  
  // Available products
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;
  
  // Subscription state
  bool _hasActiveSubscription = false;
  DateTime? _subscriptionExpirationDate;
  String? _activeProductId;

  // Getters
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  String? get queryProductError => _queryProductError;
  bool get hasActiveSubscription => _hasActiveSubscription;
  DateTime? get subscriptionExpirationDate => _subscriptionExpirationDate;
  String? get activeProductId => _activeProductId;

  // Initialize the subscription service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      debugPrint('Note: IAP testing requires a physical device, not simulator');
      debugPrint('For development: IAP will be disabled until product is configured');
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );

    // Load products
    await _loadProducts();
    
    // Check for existing purchases
    await _checkExistingPurchases();
  }

  // Check for existing purchases
  Future<void> _checkExistingPurchases() async {
    if (!_isAvailable) return;
    
    try {
      // For now, we'll skip checking past purchases during initialization
      // This will be handled when the user tries to restore purchases
      debugPrint('Skipping past purchases check during initialization');
      debugPrint('Past purchases will be checked when user restores purchases');
    } catch (e) {
      debugPrint('Error checking existing purchases: $e');
    }
  }

  // Load available products from the store
  Future<void> _loadProducts() async {
    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    final Set<String> productIds = {_monthlySubscriptionId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
      debugPrint('Make sure the product ID is configured in App Store Connect');
    }

    if (response.error != null) {
      _queryProductError = response.error!.message;
      debugPrint('Error querying products: ${response.error}');
      debugPrint('This might be because:');
      debugPrint('1. Product not created in App Store Connect');
      debugPrint('2. App not configured for in-app purchases');
      debugPrint('3. Testing on simulator (use device for testing IAP)');
      return;
    }

    _products = response.productDetails;
    debugPrint('Loaded ${_products.length} products');
    
    if (_products.isEmpty) {
      debugPrint('No products loaded. Check App Store Connect configuration.');
    }
  }

  // Get the monthly subscription product
  ProductDetails? get monthlySubscription {
    try {
      return _products.firstWhere(
        (product) => product.id == _monthlySubscriptionId,
      );
    } catch (e) {
      debugPrint('Monthly subscription product not found: $e');
      return null;
    }
  }

  // Purchase the monthly subscription
  Future<Map<String, dynamic>> purchaseMonthlySubscription() async {
    if (!_isAvailable) {
      return {
        'success': false,
        'message': 'In-app purchases not available. Please test on a physical device.',
      };
    }

    final product = monthlySubscription;
    if (product == null) {
      return {
        'success': false,
        'message': 'Subscription not available yet. Please set up the product in App Store Connect.',
      };
    }

    try {
      _purchasePending = true;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        return {
          'success': true,
          'message': 'Purchase initiated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to initiate purchase',
        };
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      return {
        'success': false,
        'message': 'Purchase failed: $e',
      };
    } finally {
      _purchasePending = false;
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  // Handle individual purchase update
  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      debugPrint('Purchase pending: ${purchaseDetails.productID}');
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('Purchase error: ${purchaseDetails.error}');
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      debugPrint('Purchase successful: ${purchaseDetails.productID}');
      
      // Verify the purchase
      final bool valid = await _verifyPurchase(purchaseDetails);
      if (valid) {
        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        
        // Update subscription state
        _hasActiveSubscription = true;
        _activeProductId = purchaseDetails.productID;
        // Set expiration date to 30 days from now for monthly subscription
        _subscriptionExpirationDate = DateTime.now().add(const Duration(days: 30));
        
        debugPrint('Subscription activated: ${purchaseDetails.productID}');
        
        // Update user's subscription status in your backend
        await _updateSubscriptionStatus(purchaseDetails);
      }
    }
  }

  // Verify purchase with Apple App Store
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a real app, you should verify the purchase with your backend
    // For now, we'll just return true
    // You should implement server-side verification for production
    return true;
  }

  // Update subscription status in your backend
  Future<void> _updateSubscriptionStatus(PurchaseDetails purchaseDetails) async {
    // TODO: Implement backend integration to update user's subscription status
    // This should call your Firebase Cloud Function or API endpoint
    debugPrint('Updating subscription status for user');
  }

  // Restore purchases
  Future<Map<String, dynamic>> restorePurchases() async {
    if (!_isAvailable) {
      return {
        'success': false,
        'message': 'In-app purchases not available',
      };
    }

    try {
      await _inAppPurchase.restorePurchases();
      
      // The purchase stream will handle the restoration
      // We'll wait a moment for the stream to process
      await Future.delayed(const Duration(seconds: 2));
      
      if (_hasActiveSubscription) {
        return {
          'success': true,
          'message': 'Subscription restored successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'No active subscription found',
        };
      }
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      return {
        'success': false,
        'message': 'Failed to restore purchases: $e',
      };
    }
  }

  // Check if user has active subscription (with expiration check)
  Future<bool> checkActiveSubscription() async {
    // Check if subscription is expired
    if (_hasActiveSubscription && _subscriptionExpirationDate != null) {
      if (DateTime.now().isAfter(_subscriptionExpirationDate!)) {
        _hasActiveSubscription = false;
        _activeProductId = null;
        _subscriptionExpirationDate = null;
        debugPrint('Subscription expired');
        return false;
      }
    }
    
    return _hasActiveSubscription;
  }

  // Get subscription info
  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    if (!_hasActiveSubscription) {
      return null;
    }
    
    return {
      'isActive': _hasActiveSubscription,
      'productId': _activeProductId,
      'expirationDate': _subscriptionExpirationDate?.toIso8601String(),
      'isExpired': _subscriptionExpirationDate != null && DateTime.now().isAfter(_subscriptionExpirationDate!),
    };
  }

  // Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}

// Helper class for subscription status
class SubscriptionStatus {
  final bool isActive;
  final String? productId;
  final DateTime? expirationDate;
  final bool isTrial;
  final bool isAutoRenewing;

  SubscriptionStatus({
    required this.isActive,
    this.productId,
    this.expirationDate,
    this.isTrial = false,
    this.isAutoRenewing = false,
  });

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool get isTrialExpired {
    if (!isTrial || expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }
}
