import 'package:cloud_firestore/cloud_firestore.dart';

/// Business Model for Green Book Directory
class Business {
  final String businessId;
  final String businessName;
  final String businessCategory;
  final String? businessDescription;
  final String ownerUserId;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;
  final String? businessAddress;
  final DateTime createdAt;

  Business({
    required this.businessId,
    required this.businessName,
    required this.businessCategory,
    this.businessDescription,
    required this.ownerUserId,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
    this.businessAddress,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      businessId: doc.id,
      businessName: data['businessName'] ?? '',
      businessCategory: data['businessCategory'] ?? '',
      businessDescription: data['businessDescription'],
      ownerUserId: data['ownerUserId'] ?? '',
      businessPhone: data['businessPhone'],
      businessEmail: data['businessEmail'],
      businessWebsite: data['businessWebsite'],
      businessAddress: data['businessAddress'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'businessName': businessName,
      'businessCategory': businessCategory,
      'businessDescription': businessDescription,
      'ownerUserId': ownerUserId,
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'businessWebsite': businessWebsite,
      'businessAddress': businessAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Business copyWith({
    String? businessName,
    String? businessCategory,
    String? businessDescription,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    String? businessAddress,
  }) {
    return Business(
      businessId: businessId,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      businessDescription: businessDescription ?? this.businessDescription,
      ownerUserId: ownerUserId,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      businessAddress: businessAddress ?? this.businessAddress,
      createdAt: createdAt,
    );
  }
}
