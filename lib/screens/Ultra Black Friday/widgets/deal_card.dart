import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DealCard extends StatelessWidget {
  final QueryDocumentSnapshot deal;
  final VoidCallback onTap;

  const DealCard({
    Key? key,
    required this.deal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = deal.data() as Map<String, dynamic>;
    final businessName = data['businessName'] ?? 'Business';
    final logoUrl = data['logoUrl'];
    
    // Deal is nested within the business document
    final dealData = data['deal'] as Map<String, dynamic>?;
    if (dealData == null) {
      // No deal available, return empty container
      return const SizedBox.shrink();
    }
    
    final dealTitle = dealData['title'] ?? '';
    final discountType = dealData['discountType'] ?? '';
    final discountValue = dealData['discountValue'] ?? '';
    final discountText = discountValue.isNotEmpty && discountType.isNotEmpty
        ? '$discountValue$discountType'
        : dealTitle;
    
    final totalCodes = data['totalCodes'] ?? dealData['totalCodes'] ?? 0;
    final codeInventoryCount = data['codeInventoryCount'] ?? 0;
    final codesRemaining = codeInventoryCount > 0 ? codeInventoryCount : totalCodes;
    
    // Note: expiresAt might not be in the deal structure, so we'll skip time badge for now
    final expiresAt = null; // Can be added later if expiration is tracked

    final isLowStock = codesRemaining < 10;
    final isExpiringSoon = false; // Can be updated if expiration is tracked

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image with badges
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Colors.grey[800],
                    image: (logoUrl != null && logoUrl.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (logoUrl == null || logoUrl.isEmpty)
                      ? Center(
                          child: Icon(
                            Icons.card_giftcard,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                        )
                      : null,
                ),
                // Gradient overlay
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Time badge
                if (expiresAt != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isExpiringSoon
                            ? Colors.red.withOpacity(0.9)
                            : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeRemaining(expiresAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Logo
                if (logoUrl != null && logoUrl.isNotEmpty)
                  Positioned(
                    bottom: -15,
                    left: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey[900]!,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(logoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Deal Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (logoUrl != null && logoUrl.isNotEmpty) const SizedBox(height: 18),
                    Text(
                      businessName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        discountText,
                        style: const TextStyle(
                          color: Color(0xFFFF6600),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stock indicator
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 12,
                          color: isLowStock ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$codesRemaining left',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.grey[600],
                              fontSize: 10,
                              fontWeight:
                                  isLowStock ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Expired';
    }
  }
}


