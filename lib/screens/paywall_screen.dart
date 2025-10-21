import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  final Widget destinationScreen;
  final String screenName;
  
  const PaywallScreen({
    super.key,
    required this.destinationScreen,
    required this.screenName,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _price;

  @override
  void initState() {
    super.initState();
    _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    await _subscriptionService.initialize();
    if (mounted) {
      setState(() {
        final product = _subscriptionService.monthlySubscription;
        _price = product?.price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Loginimage1-3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header with logo
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // Main content
                  _buildMainContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Premium features
                  _buildPremiumFeatures(),
                  
                  const SizedBox(height: 40),
                  
                  // Subscription details
                  _buildSubscriptionDetails(),
                  
                  const SizedBox(height: 30),
                  
                  // Action buttons
                  _buildActionButtons(context),
                  
                  const SizedBox(height: 20),
                  
                  // Legal text
                  _buildLegalText(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Image.asset(
          'assets/CC_PrimaryLogo_SilverPurple.png',
          width: 120,
          height: 60,
        ),
        const SizedBox(height: 20),
        
        // Title
        const Text(
          'UNLOCK PREMIUM',
          style: TextStyle(
            color: Color(0xFFFF7E00),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Access ${widget.screenName} and connect with your community',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF7E00), width: 2),
      ),
      child: Column(
        children: [
          // Free trial offer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF7E00).withOpacity(0.2),
                  const Color(0xFFFF7E00).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF7E00), width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFFFF7E00),
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  '1-MONTH FREE TRIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your free trial today - no commitment, cancel anytime!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      {
        'icon': Icons.people,
        'title': 'Unlimited Connections',
        'description': 'Connect with unlimited people in your community',
      },
      {
        'icon': Icons.event,
        'title': 'Event RSVPs & Networking',
        'description': 'RSVP to events and connect with other attendees',
      },
      {
        'icon': Icons.star,
        'title': 'Rewards & Points',
        'description': 'Earn points for activities and unlock rewards',
      },
      {
        'icon': Icons.location_on,
        'title': 'Location-Based Matching',
        'description': 'Find people and events near you',
      },
      {
        'icon': Icons.business,
        'title': 'Black-Owned Business Directory',
        'description': 'Discover and support local Black-owned businesses',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PREMIUM FEATURES',
          style: TextStyle(
            color: Color(0xFFFF7E00),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        
        ...features.map((feature) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1d1d1e).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7E00).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7E00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: const Color(0xFFFF7E00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSubscriptionDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7E00), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'MONTHLY SUB RENEWING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _price ?? '\$8.99',
                style: const TextStyle(
                  color: Color(0xFFFF7E00),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Duration: one month',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'After 1-month free trial',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Start Free Trial Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _startFreeTrial(context),
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.card_giftcard, color: Colors.white),
            label: Text(
              _isLoading ? 'PROCESSING...' : 'START FREE TRIAL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading 
                  ? const Color(0xFFFF7E00).withOpacity(0.7)
                  : const Color(0xFFFF7E00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Restore Purchases Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _restorePurchases(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
              side: BorderSide(
                color: _isLoading ? Colors.white.withOpacity(0.5) : Colors.white, 
                width: 1
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isLoading ? 'PROCESSING...' : 'RESTORE PURCHASES',
              style: TextStyle(
                color: _isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalText() {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'By subscribing, you agree to our ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => _openTermsOfUse(),
                  child: const Text(
                    'Terms of Use',
                    style: TextStyle(
                      color: Color(0xFFFF7E00),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: ' and ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => _openPrivacyPolicy(),
                  child: const Text(
                    'Privacy Policy.',
                    style: TextStyle(
                      color: Color(0xFFFF7E00),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _startFreeTrial(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _subscriptionService.purchaseMonthlySubscription();
      
      if (mounted) {
        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Welcome to Premium! Your subscription is active.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate to destination screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => widget.destinationScreen,
            ),
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Purchase failed';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _subscriptionService.restorePurchases();
      
      if (mounted) {
        if (result['success'] == true) {
          // Check if user has active subscription
          final hasActiveSubscription = await _subscriptionService.hasActiveSubscription();
          
          if (hasActiveSubscription) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Purchases restored! Your subscription is active.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Navigate to destination screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => widget.destinationScreen,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No active subscriptions found to restore.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Restore failed';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openTermsOfUse() async {
    const url = 'https://www.the-culture-connection.com/privacy-policy';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://www.the-culture-connection.com/privacy-policy';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
