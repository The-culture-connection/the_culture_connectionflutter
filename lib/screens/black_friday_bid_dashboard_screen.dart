import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/black_friday_bid.dart';
import '../services/black_friday_service.dart';

class BlackFridayBidDashboardScreen extends StatefulWidget {
  const BlackFridayBidDashboardScreen({super.key});

  @override
  State<BlackFridayBidDashboardScreen> createState() => _BlackFridayBidDashboardScreenState();
}

class _BlackFridayBidDashboardScreenState extends State<BlackFridayBidDashboardScreen> {
  final BlackFridayService _service = BlackFridayService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1D1D1E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('BID DASHBOARD'),
          centerTitle: false,
        ),
        body: Center(
          child: Text(
            'Please log in to view your bids',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BID DASHBOARD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Bids List
            Expanded(
              child: StreamBuilder<List<BlackFridayBid>>(
                stream: _service.streamUserActiveBids(_currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.electricOrange,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading bids',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  }

                  final bids = snapshot.data ?? [];

                  if (bids.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gavel,
                            size: 64,
                            color: AppColors.electricOrange.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active bids',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start bidding on offers to see them here',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: bids.length,
                    itemBuilder: (context, index) {
                      return _buildBidCard(bids[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(BlackFridayBid bid) {
    // Determine status color and text
    Color statusColor;
    String statusText;
    
    switch (bid.status) {
      case BidStatus.pending:
        statusColor = AppColors.electricOrange;
        statusText = 'Pending';
        break;
      case BidStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case BidStatus.outbid:
        statusColor = Colors.red;
        statusText = 'Outbid';
        break;
      case BidStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      case BidStatus.expired:
        statusColor = Colors.grey;
        statusText = 'Expired';
        break;
      case BidStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Photo
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.deepPurple.withOpacity(0.3),
            backgroundImage: bid.bidderPhotoUrl.isNotEmpty
                ? NetworkImage(bid.bidderPhotoUrl)
                : null,
            child: bid.bidderPhotoUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),

          // Bid Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offer ID (we'll need to fetch offer details in a real app)
                Text(
                  'Offer #${bid.offerId.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Bid type and amount
                Row(
                  children: [
                    Icon(
                      bid.bidType == BidType.money 
                          ? Icons.attach_money 
                          : Icons.handshake,
                      size: 16,
                      color: AppColors.electricOrange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bid.bidType == BidType.money
                            ? '\$${bid.moneyAmount!.toStringAsFixed(2)}'
                            : bid.serviceDescription ?? 'Service Bid',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.electricOrange,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Timestamp
                Text(
                  _formatTimestamp(bid.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor,
                width: 1,
              ),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

