import 'package:flutter/material.dart';
import '../models/business.dart';
import 'optimized_business_card.dart';

/// OptimizedBusinessList - Performance-optimized list widget for businesses
class OptimizedBusinessList extends StatelessWidget {
  final List<Business> businesses;
  final Function(Business)? onCall;
  final Function(Business)? onWebsite;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const OptimizedBusinessList({
    super.key,
    required this.businesses,
    this.onCall,
    this.onWebsite,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: businesses.length,
      // Use itemExtent for better performance when items have similar heights
      itemExtent: null, // Let Flutter calculate dynamically
      itemBuilder: (context, index) {
        final business = businesses[index];
        return OptimizedBusinessCard(
          business: business,
          onCall: onCall != null ? () => onCall!(business) : null,
          onWebsite: onWebsite != null ? () => onWebsite!(business) : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'No businesses found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OptimizedBusinessGrid - For grid layouts (if needed)
class OptimizedBusinessGrid extends StatelessWidget {
  final List<Business> businesses;
  final Function(Business)? onCall;
  final Function(Business)? onWebsite;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const OptimizedBusinessGrid({
    super.key,
    required this.businesses,
    this.onCall,
    this.onWebsite,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return const Center(
        child: Text(
          'No businesses found',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return OptimizedBusinessCard(
          business: business,
          onCall: onCall != null ? () => onCall!(business) : null,
          onWebsite: onWebsite != null ? () => onWebsite!(business) : null,
        );
      },
    );
  }
}


