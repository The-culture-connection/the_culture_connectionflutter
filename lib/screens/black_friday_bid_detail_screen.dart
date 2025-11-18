import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/black_friday_offer.dart';
import '../models/black_friday_bid.dart';
import '../services/black_friday_service.dart';
import '../services/firestore_service.dart';

class BlackFridayBidDetailScreen extends StatefulWidget {
  final BlackFridayOffer offer;
  final String dayKey;

  const BlackFridayBidDetailScreen({
    super.key,
    required this.offer,
    required this.dayKey,
  });

  @override
  State<BlackFridayBidDetailScreen> createState() => _BlackFridayBidDetailScreenState();
}

class _BlackFridayBidDetailScreenState extends State<BlackFridayBidDetailScreen> {
  final BlackFridayService _service = BlackFridayService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  BlackFridayBid? _highestMoneyBid;
  BlackFridayBid? _latestServiceBid;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadBidInfo();
  }

  void _initializeVideo() async {
    if (widget.offer.videoUrl.isNotEmpty) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.offer.videoUrl),
        );
        await _videoController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController!.setLooping(true);
        _videoController!.play();
      } catch (e) {
        print('Error initializing video: $e');
      }
    }
  }

  void _loadBidInfo() async {
    final highestMoney = await _service.getHighestMoneyBid(widget.dayKey, widget.offer.id);
    final latestService = await _service.getMostRecentServiceBid(widget.dayKey, widget.offer.id);
    
    setState(() {
      _highestMoneyBid = highestMoney;
      _latestServiceBid = latestService;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.offer.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Video or Image
                    Container(
                      height: 300,
                      color: Colors.black,
                      child: _isVideoInitialized && _videoController != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Icon(
                                        _videoController!.value.isPlaying
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: AppColors.deepPurple.withOpacity(0.3),
                                backgroundImage: widget.offer.creatorPhotoUrl.isNotEmpty
                                    ? NetworkImage(widget.offer.creatorPhotoUrl)
                                    : null,
                                child: widget.offer.creatorPhotoUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                    ),

                    // Offer Details
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Creator Info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.deepPurple.withOpacity(0.3),
                                backgroundImage: widget.offer.creatorPhotoUrl.isNotEmpty
                                    ? NetworkImage(widget.offer.creatorPhotoUrl)
                                    : null,
                                child: widget.offer.creatorPhotoUrl.isEmpty
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.offer.creatorName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      widget.offer.offerType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.electricOrange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'About',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.offer.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Base Price
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.deepPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.electricOrange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Starting Price',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${widget.offer.basePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.electricOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current Bids Info
                          if (_highestMoneyBid != null || _latestServiceBid != null) ...[
                            const Text(
                              'Current Bids',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (_highestMoneyBid != null)
                            _buildBidInfo(
                              'Highest Money Bid',
                              '\$${_highestMoneyBid!.moneyAmount!.toStringAsFixed(2)}',
                              _highestMoneyBid!.bidderName,
                            ),

                          if (_latestServiceBid != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _buildBidInfo(
                                'Latest Service Bid',
                                _latestServiceBid!.serviceDescription ?? 'Service Exchange',
                                _latestServiceBid!.bidderName,
                              ),
                            ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bid Buttons (Fixed at bottom)
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showServiceBidDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Service',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showMoneyBidDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Money',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidInfo(String label, String value, String bidder) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.electricOrange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by $bidder',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoneyBidDialog() {
    final minBid = _highestMoneyBid != null 
        ? (_highestMoneyBid!.moneyAmount! + 1) 
        : widget.offer.basePrice;
    
    final TextEditingController amountController = TextEditingController(
      text: minBid.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Place Money Bid',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum bid: \$${minBid.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Bid Amount (\$)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.electricOrange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.electricOrange),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment method will be authorized but not charged until your bid is accepted.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount >= minBid) {
                Navigator.pop(context);
                _placeMoneyBid(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter an amount of at least \$${minBid.toStringAsFixed(2)}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricOrange,
            ),
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  void _showServiceBidDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Place Service Bid',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offer a skill or service in exchange for this offer',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Service Category',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                hintText: 'e.g., Web Development, Design, Marketing',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Service Description',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                hintText: 'Describe what you\'re offering...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.deepPurple),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty && 
                  categoryController.text.isNotEmpty) {
                Navigator.pop(context);
                _placeServiceBid(
                  descriptionController.text,
                  categoryController.text,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPurple,
            ),
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeMoneyBid(double amount) async {
    if (_currentUser == null) {
      _showError('You must be logged in to place a bid');
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.electricOrange),
        ),
      );

      // Get user profile
      final userProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
      if (userProfile == null) {
        Navigator.pop(context);
        _showError('User profile not found');
        return;
      }

      // Create bid
      final bid = BlackFridayBid(
        id: '',
        offerId: widget.offer.id,
        bidderId: _currentUser!.uid,
        bidderName: userProfile.fullName,
        bidderPhotoUrl: userProfile.photoURL,
        bidType: BidType.money,
        moneyAmount: amount,
        timestamp: DateTime.now(),
        status: BidStatus.pending,
      );

      // Place bid
      await _service.placeBid(bid, widget.dayKey);

      // Close loading and show success
      Navigator.pop(context);
      _showSuccess('Bid placed successfully!');

      // Reload bid info
      _loadBidInfo();
    } catch (e) {
      Navigator.pop(context);
      _showError('Failed to place bid: $e');
    }
  }

  Future<void> _placeServiceBid(String description, String category) async {
    if (_currentUser == null) {
      _showError('You must be logged in to place a bid');
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.deepPurple),
        ),
      );

      // Get user profile
      final userProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
      if (userProfile == null) {
        Navigator.pop(context);
        _showError('User profile not found');
        return;
      }

      // Create bid
      final bid = BlackFridayBid(
        id: '',
        offerId: widget.offer.id,
        bidderId: _currentUser!.uid,
        bidderName: userProfile.fullName,
        bidderPhotoUrl: userProfile.photoURL,
        bidType: BidType.service,
        serviceDescription: description,
        serviceCategory: category,
        timestamp: DateTime.now(),
        status: BidStatus.pending,
      );

      // Place bid
      await _service.placeBid(bid, widget.dayKey);

      // Close loading and show success
      Navigator.pop(context);
      _showSuccess('Service bid placed successfully!');

      // Reload bid info
      _loadBidInfo();
    } catch (e) {
      Navigator.pop(context);
      _showError('Failed to place bid: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

