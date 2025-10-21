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

  // Getters
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  String? get queryProductError => _queryProductError;

  // Initialize the subscription service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
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
  }

  // Load available products from the store
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final Set<String> productIds = {_monthlySubscriptionId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      _queryProductError = response.error!.message;
      debugPrint('Error querying products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('Loaded ${_products.length} products');
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
        'message': 'In-app purchases not available',
      };
    }

    final product = monthlySubscription;
    if (product == null) {
      return {
        'success': false,
        'message': 'Monthly subscription product not found',
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
      return {
        'success': true,
        'message': 'Purchases restored successfully',
      };
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      return {
        'success': false,
        'message': 'Failed to restore purchases: $e',
      };
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    // TODO: Implement check with your backend
    // This should verify the user's subscription status from your database
    return false;
  }

  // Get subscription info
  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    // TODO: Implement to get subscription details from your backend
    return null;
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
