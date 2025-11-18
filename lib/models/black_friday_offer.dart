import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a featured offer in The Real Black Friday event
class BlackFridayOffer {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl;
  final String videoUrl;
  final double basePrice;
  final String offerType; // 'service' or 'product'
  final DateTime eventDate; // The day this offer is featured (e.g., Nov 28, 2025)
  final DateTime createdAt;
  final bool isActive;
  final String? category;
  final Map<String, dynamic>? metadata;

  BlackFridayOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhotoUrl,
    required this.videoUrl,
    required this.basePrice,
    required this.offerType,
    required this.eventDate,
    required this.createdAt,
    this.isActive = true,
    this.category,
    this.metadata,
  });

  /// Create from Firestore document
  factory BlackFridayOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlackFridayOffer(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhotoUrl: data['creatorPhotoUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      offerType: data['offerType'] ?? 'service',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      category: data['category'],
      metadata: data['metadata'],
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'videoUrl': videoUrl,
      'basePrice': basePrice,
      'offerType': offerType,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'category': category,
      'metadata': metadata,
    };
  }

  /// Copy with method
  BlackFridayOffer copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? creatorName,
    String? creatorPhotoUrl,
    String? videoUrl,
    double? basePrice,
    String? offerType,
    DateTime? eventDate,
    DateTime? createdAt,
    bool? isActive,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return BlackFridayOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorPhotoUrl: creatorPhotoUrl ?? this.creatorPhotoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      basePrice: basePrice ?? this.basePrice,
      offerType: offerType ?? this.offerType,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}

