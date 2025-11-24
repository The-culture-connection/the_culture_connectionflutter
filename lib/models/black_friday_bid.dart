import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a bid on a Black Friday offer
class BlackFridayBid {
  final String id;
  final String offerId;
  final String bidderId;
  final String bidderName;
  final String bidderPhotoUrl;
  final BidType bidType;
  final double? moneyAmount; // For money bids
  final String? serviceDescription; // For service bids
  final String? serviceCategory;
  final DateTime timestamp;
  final BidStatus status;
  final String? paymentIntentId; // Stripe payment intent ID
  final String? chargeId; // Stripe charge ID after acceptance
  final DateTime? acceptedAt;
  final DateTime? chargedAt;

  BlackFridayBid({
    required this.id,
    required this.offerId,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhotoUrl,
    required this.bidType,
    this.moneyAmount,
    this.serviceDescription,
    this.serviceCategory,
    required this.timestamp,
    required this.status,
    this.paymentIntentId,
    this.chargeId,
    this.acceptedAt,
    this.chargedAt,
  });

  /// Create from Firestore document
  factory BlackFridayBid.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlackFridayBid(
      id: doc.id,
      offerId: data['offerId'] ?? '',
      bidderId: data['bidderId'] ?? '',
      bidderName: data['bidderName'] ?? '',
      bidderPhotoUrl: data['bidderPhotoUrl'] ?? '',
      bidType: BidType.values.firstWhere(
        (e) => e.toString() == 'BidType.${data['bidType']}',
        orElse: () => BidType.money,
      ),
      moneyAmount: data['moneyAmount']?.toDouble(),
      serviceDescription: data['serviceDescription'],
      serviceCategory: data['serviceCategory'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: BidStatus.values.firstWhere(
        (e) => e.toString() == 'BidStatus.${data['status']}',
        orElse: () => BidStatus.pending,
      ),
      paymentIntentId: data['paymentIntentId'],
      chargeId: data['chargeId'],
      acceptedAt: data['acceptedAt'] != null 
          ? (data['acceptedAt'] as Timestamp).toDate() 
          : null,
      chargedAt: data['chargedAt'] != null 
          ? (data['chargedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'offerId': offerId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'bidderPhotoUrl': bidderPhotoUrl,
      'bidType': bidType.name,
      'moneyAmount': moneyAmount,
      'serviceDescription': serviceDescription,
      'serviceCategory': serviceCategory,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
      'paymentIntentId': paymentIntentId,
      'chargeId': chargeId,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'chargedAt': chargedAt != null ? Timestamp.fromDate(chargedAt!) : null,
    };
  }

  /// Copy with method
  BlackFridayBid copyWith({
    String? id,
    String? offerId,
    String? bidderId,
    String? bidderName,
    String? bidderPhotoUrl,
    BidType? bidType,
    double? moneyAmount,
    String? serviceDescription,
    String? serviceCategory,
    DateTime? timestamp,
    BidStatus? status,
    String? paymentIntentId,
    String? chargeId,
    DateTime? acceptedAt,
    DateTime? chargedAt,
  }) {
    return BlackFridayBid(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      bidderId: bidderId ?? this.bidderId,
      bidderName: bidderName ?? this.bidderName,
      bidderPhotoUrl: bidderPhotoUrl ?? this.bidderPhotoUrl,
      bidType: bidType ?? this.bidType,
      moneyAmount: moneyAmount ?? this.moneyAmount,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      chargeId: chargeId ?? this.chargeId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      chargedAt: chargedAt ?? this.chargedAt,
    );
  }

  /// Get display amount for money bids
  String get displayAmount {
    if (bidType == BidType.money && moneyAmount != null) {
      return '\$${moneyAmount!.toStringAsFixed(2)}';
    }
    return 'Service Bid';
  }

  /// Check if this is the current highest money bid
  bool isHighestMoneyBid(List<BlackFridayBid> allBids) {
    if (bidType != BidType.money) return false;
    
    final moneyBids = allBids.where((b) => b.bidType == BidType.money).toList();
    if (moneyBids.isEmpty) return false;
    
    moneyBids.sort((a, b) => (b.moneyAmount ?? 0).compareTo(a.moneyAmount ?? 0));
    return moneyBids.first.id == id;
  }
}

/// Type of bid
enum BidType {
  money,
  service,
}

/// Status of bid
enum BidStatus {
  pending,      // Bid placed, payment authorized but not charged
  accepted,     // Bid accepted by creator, payment charged
  rejected,     // Bid rejected by creator
  outbid,       // Outbid by another bidder
  expired,      // Event day ended, bid not accepted
  cancelled,    // Cancelled by bidder
}




