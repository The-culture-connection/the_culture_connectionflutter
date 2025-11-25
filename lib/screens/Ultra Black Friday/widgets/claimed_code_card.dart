import 'package:flutter/material.dart';

class ClaimedCodeCard extends StatelessWidget {
  final String code;
  final String businessName;
  final String discountText;
  final String logoUrl;
  final DateTime? expiresAt;
  final bool isRedeemed;
  final VoidCallback onRedeem;
  final VoidCallback onDetails;

  const ClaimedCodeCard({
    Key? key,
    required this.code,
    required this.businessName,
    required this.discountText,
    required this.logoUrl,
    this.expiresAt,
    required this.isRedeemed,
    required this.onRedeem,
    required this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpired =
        expiresAt != null && expiresAt!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired
              ? Colors.red.withOpacity(0.5)
              : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Logo
                if (logoUrl.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (logoUrl.isNotEmpty) const SizedBox(width: 16),
                // Business Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              businessName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isExpired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: const Text(
                                'EXPIRED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isRedeemed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6600).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFF6600),
                                ),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Color(0xFFFF6600),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        discountText,
                        style: const TextStyle(
                          color: Color(0xFFFF6600),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (expiresAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isExpired ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? 'Expired ${_formatDate(expiresAt!)}'
                                  : 'Expires ${_formatDate(expiresAt!)}',
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetails,
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (isExpired || isRedeemed) ? null : onRedeem,
                    icon: Icon(
                      isExpired
                          ? Icons.block
                          : isRedeemed
                              ? Icons.check_circle
                              : Icons.qr_code,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isExpired
                          ? 'Expired'
                          : isRedeemed
                              ? 'Inactive'
                              : 'Redeem',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isExpired || isRedeemed)
                          ? Colors.grey[800]
                          : const Color(0xFFFF6600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inDays > 0) {
        return '${absDiff.inDays} day${absDiff.inDays > 1 ? 's' : ''} ago';
      } else if (absDiff.inHours > 0) {
        return '${absDiff.inHours} hour${absDiff.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'recently';
      }
    } else {
      if (difference.inDays > 0) {
        return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'soon';
      }
    }
  }
}


