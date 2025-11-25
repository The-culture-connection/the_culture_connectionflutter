import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'black_card_detail_screen.dart';
import 'widgets/claimed_code_card.dart';

class MyBlackCardWalletScreen extends StatefulWidget {
  const MyBlackCardWalletScreen({Key? key}) : super(key: key);

  @override
  State<MyBlackCardWalletScreen> createState() =>
      _MyBlackCardWalletScreenState();
}

class _MyBlackCardWalletScreenState extends State<MyBlackCardWalletScreen> {
  String _filter = 'all'; // all, active, expired

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 64,
              color: Colors.grey[800],
            ),
            const SizedBox(height: 16),
            Text(
              'Please sign in to view your Black Card',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildFilterChip('All', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Active', 'active'),
              const SizedBox(width: 8),
              _buildFilterChip('Expired', 'expired'),
            ],
          ),
        ),

        // Claimed codes list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Profiles')
                .doc(user.uid)
                .collection('claimedCodes')
                .orderBy('claimedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading codes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6600),
                  ),
                );
              }

              var codes = snapshot.data!.docs;

              // Apply filter
              if (_filter == 'active') {
                codes = codes.where((doc) {
                  final expiresAt =
                      (doc.data() as Map<String, dynamic>)['expiresAt']
                          as Timestamp?;
                  return expiresAt != null &&
                      expiresAt.toDate().isAfter(DateTime.now());
                }).toList();
              } else if (_filter == 'expired') {
                codes = codes.where((doc) {
                  final expiresAt =
                      (doc.data() as Map<String, dynamic>)['expiresAt']
                          as Timestamp?;
                  return expiresAt == null ||
                      expiresAt.toDate().isBefore(DateTime.now());
                }).toList();
              }

              if (codes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filter == 'all'
                            ? 'No claimed codes yet'
                            : 'No $_filter codes',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start claiming deals to build your Black Card!',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: codes.length,
                itemBuilder: (context, index) {
                  final code = codes[index];
                  final data = code.data() as Map<String, dynamic>;

                  return ClaimedCodeCard(
                    code: data['code'] ?? '',
                    businessName: data['businessName'] ?? 'Business',
                    discountText: data['discountText'] ?? '',
                    logoUrl: data['logoUrl'] ?? '',
                    expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
                    isRedeemed: data['isRedeemed'] ?? false,
                    onRedeem: () => _showRedeemDialog(code.id, data),
                    onDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlackCardDetailScreen(
                            claimedCodeId: code.id,
                            dealId: data['dealId'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6600)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6600)
                : Colors.grey[800]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showRedeemDialog(String codeId, Map<String, dynamic> data) {
    final code = data['code'] ?? '';
    final businessName = data['businessName'] ?? 'Business';
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    final isExpired =
        expiresAt != null && expiresAt.isBefore(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpired ? Icons.error_outline : Icons.confirmation_number,
                  size: 64,
                  color: isExpired ? Colors.red : const Color(0xFFFF6600),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                businessName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (isExpired)
                const Text(
                  'This code has expired',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  'Show this code at checkout',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (!isExpired)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6600),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


