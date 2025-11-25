import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'widgets/code_claim_animation.dart';

class DealDetailScreen extends StatefulWidget {
  final String dealId;
  final String themeDocId;

  const DealDetailScreen({
    Key? key,
    required this.dealId,
    required this.themeDocId,
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
          .collection('Profiles')
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
            .collection('Ultra Black Friday')
            .doc(widget.themeDocId)
            .collection('businesses')
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

          final businessData = snapshot.data!.data() as Map<String, dynamic>;
          final businessName = businessData['businessName'] ?? 'Business';
          final logoUrl = businessData['logoUrl'];
          
          // Deal is nested within the business document
          final dealData = businessData['deal'] as Map<String, dynamic>?;
          if (dealData == null) {
            return Center(
              child: Text(
                'No deal available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }
          
          final description = dealData['description'] ?? '';
          final dealTitle = dealData['title'] ?? '';
          final discountType = dealData['discountType'] ?? '';
          final discountValue = dealData['discountValue'] ?? '';
          final discountText = discountValue.isNotEmpty && discountType.isNotEmpty
              ? '$discountValue$discountType'
              : dealTitle;
          final terms = dealData['terms'] ?? '';
          final redemptionInstructions = dealData['redemptionInstructions'] ?? '';
          
          final totalCodes = businessData['totalCodes'] ?? dealData['totalCodes'] ?? 0;
          final codeInventoryCount = businessData['codeInventoryCount'] ?? 0;
          final codesRemaining = codeInventoryCount > 0 ? codeInventoryCount : totalCodes;
          
          // Note: expiresAt might not be in the structure, so we'll skip expiration check for now
          final expiresAt = null;
          final isActive = businessData['appVisibility'] ?? false;

          final isExhausted = codesRemaining <= 0;
          final isExpired = false; // Can be updated if expiration is tracked
          final canClaim = isActive && !isExhausted && !isExpired && !_hasClaimedThisDeal;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deal Image (using logo or placeholder)
                if (logoUrl != null && logoUrl.isNotEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      image: DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.grey,
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
                          if (logoUrl != null && logoUrl.isNotEmpty)
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
                          if (logoUrl != null && logoUrl.isNotEmpty) const SizedBox(width: 16),
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

                      // Redemption Instructions (if available)
                      if (redemptionInstructions != null && redemptionInstructions.isNotEmpty) ...[
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
                                Icons.info_outline,
                                color: Color(0xFFFF6600),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  redemptionInstructions,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6600),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

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
                              ? () => _claimCode(businessData, dealData, discountText)
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

                      if (_hasClaimedThisDeal)
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
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF6600),
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Code Claimed!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View your code in "My Claimed Deals"',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
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

  Future<void> _claimCode(Map<String, dynamic> businessData, Map<String, dynamic> dealData, String discountText) async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique code using randomCodePrefix from business data
      final randomCodePrefix = businessData['randomCodePrefix'] ?? 
          (businessData['businessName'] ?? 'BIZ').toString().replaceAll(' ', '').toUpperCase();
      final randomNumber = Random().nextInt(99999).toString().padLeft(5, '0');
      final code = '$randomCodePrefix$randomNumber';

      final batch = FirebaseFirestore.instance.batch();

      // Add to user's claimed codes
      final claimedCodeRef = FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .collection('claimedCodes')
          .doc();

      batch.set(claimedCodeRef, {
        'dealId': widget.dealId,
        'businessName': businessData['businessName'],
        'businessId': businessData['businessId'],
        'code': code,
        'claimedAt': FieldValue.serverTimestamp(),
        'discountText': discountText,
        'logoUrl': businessData['logoUrl'],
        'isRedeemed': false,
        'themeDocId': widget.themeDocId,
      });

      // Decrement code inventory count
      final businessRef = FirebaseFirestore.instance
          .collection('Ultra Black Friday')
          .doc(widget.themeDocId)
          .collection('businesses')
          .doc(widget.dealId);

      batch.update(businessRef, {
        'codeInventoryCount': FieldValue.increment(-1),
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
            builder: (context) => const CodeClaimAnimationScreen(),
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


