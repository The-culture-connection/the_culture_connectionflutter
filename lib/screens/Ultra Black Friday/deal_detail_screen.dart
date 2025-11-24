import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'widgets/code_claim_animation.dart';

class DealDetailScreen extends StatefulWidget {
  final String dealId;

  const DealDetailScreen({
    Key? key,
    required this.dealId,
  }) : super(key: key);

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  bool _isClaiming = false;
  bool _hasClaimedThisDeal = false;
  String? _claimedCode;

  @override
  void initState() {
    super.initState();
    _checkIfClaimed();
  }

  Future<void> _checkIfClaimed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final claimedCodes = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('claimedCodes')
          .where('dealId', isEqualTo: widget.dealId)
          .limit(1)
          .get();

      if (claimedCodes.docs.isNotEmpty) {
        setState(() {
          _hasClaimedThisDeal = true;
          _claimedCode = claimedCodes.docs.first.data()['code'];
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ultraBlackFriday')
            .doc('data')
            .collection('deals')
            .doc(widget.dealId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading deal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6600),
              ),
            );
          }

          final deal = snapshot.data!.data() as Map<String, dynamic>;
          final businessName = deal['businessName'] ?? 'Business';
          final description = deal['description'] ?? '';
          final discountText = deal['discountText'] ?? '';
          final terms = deal['terms'] ?? '';
          final logoUrl = deal['logoUrl'] ?? '';
          final imageUrl = deal['imageUrl'] ?? '';
          final totalCodes = deal['totalCodes'] ?? 0;
          final claimedCount = deal['claimedCount'] ?? 0;
          final expiresAt = (deal['expiresAt'] as Timestamp?)?.toDate();
          final isActive = deal['isActive'] ?? false;

          final codesRemaining = totalCodes - claimedCount;
          final isExhausted = codesRemaining <= 0;
          final isExpired =
              expiresAt != null && expiresAt.isBefore(DateTime.now());
          final canClaim =
              isActive && !isExhausted && !isExpired && !_hasClaimedThisDeal;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deal Image
                if (imageUrl.isNotEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Logo and Name
                      Row(
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  discountText,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6600),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Time Remaining
                      if (expiresAt != null && !isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6600).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFF6600),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFFFF6600),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getTimeRemaining(expiresAt),
                                style: const TextStyle(
                                  color: Color(0xFFFF6600),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (expiresAt != null && !isExpired)
                        const SizedBox(height: 16),

                      // Codes Remaining
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$codesRemaining codes remaining',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        terms,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Claim Code Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canClaim && !_isClaiming
                              ? () => _claimCode(deal)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canClaim
                                ? const Color(0xFFFF6600)
                                : Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isClaiming
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _hasClaimedThisDeal
                                      ? 'Already Claimed'
                                      : isExhausted
                                          ? 'Codes Exhausted'
                                          : isExpired
                                              ? 'Deal Expired'
                                              : 'Claim Code',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      if (_hasClaimedThisDeal && _claimedCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6600),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Your Code',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _claimedCode!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6600),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Expired';
    }
  }

  Future<void> _claimCode(Map<String, dynamic> deal) async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique code
      final businessName = deal['businessName'] ?? 'BIZ';
      final randomNumber = Random().nextInt(99999).toString().padLeft(5, '0');
      final code = '${businessName.replaceAll(' ', '').toUpperCase()}$randomNumber';

      final batch = FirebaseFirestore.instance.batch();

      // Add to user's claimed codes
      final claimedCodeRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('claimedCodes')
          .doc();

      batch.set(claimedCodeRef, {
        'dealId': widget.dealId,
        'businessName': deal['businessName'],
        'businessId': deal['businessId'],
        'code': code,
        'claimedAt': FieldValue.serverTimestamp(),
        'expiresAt': deal['expiresAt'],
        'discountText': deal['discountText'],
        'logoUrl': deal['logoUrl'],
        'isRedeemed': false,
      });

      // Increment claimed count
      final dealRef = FirebaseFirestore.instance
          .collection('ultraBlackFriday')
          .doc('data')
          .collection('deals')
          .doc(widget.dealId);

      batch.update(dealRef, {
        'claimedCount': FieldValue.increment(1),
      });

      await batch.commit();

      setState(() {
        _hasClaimedThisDeal = true;
        _claimedCode = code;
      });

      if (mounted) {
        // Show animation screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeClaimAnimationScreen(code: code),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error claiming code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }
}


