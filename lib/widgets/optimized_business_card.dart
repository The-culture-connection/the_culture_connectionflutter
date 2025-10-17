import 'package:flutter/material.dart';
import '../models/business.dart';

/// OptimizedBusinessCard - Performance-optimized business card widget
class OptimizedBusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onCall;
  final VoidCallback? onWebsite;

  const OptimizedBusinessCard({
    super.key,
    required this.business,
    this.onCall,
    this.onWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Business Name - Single Text widget
          Text(
            business.name,
            style: _businessNameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Category - Only render if not empty
          if (business.category.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: _categoryDecoration,
              child: Text(
                business.category,
                style: _categoryStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Address - Only render if not empty
          if (business.address.isNotEmpty) ...[
            Text(
              business.address,
              style: _addressStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          
          // Hours - Only render if not empty
          if (business.hours.isNotEmpty) ...[
            Text(
              business.hours,
              style: _hoursStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          
          // Phone - Only render if not empty
          if (business.phone.isNotEmpty) ...[
            Text(
              business.phone,
              style: _phoneStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          // Action Buttons - Only render if needed
          if (business.phone.isNotEmpty || business.website != null) ...[
            Row(
              children: [
                if (business.phone.isNotEmpty) ...[
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone,
                      label: 'Call',
                      onPressed: onCall,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (business.website != null) ...[
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.language,
                      label: 'Website',
                      onPressed: onWebsite,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF7E00),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Pre-defined styles to avoid recreation
  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Color(0xFF2A2A2A),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const BoxDecoration _categoryDecoration = BoxDecoration(
    color: Color(0x26FF7E00),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const TextStyle _businessNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter',
  );

  static const TextStyle _categoryStyle = TextStyle(
    color: Color(0xFFFF7E00),
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
  );

  static const TextStyle _addressStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'Inter',
  );

  static const TextStyle _hoursStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'Inter',
  );

  static const TextStyle _phoneStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'Inter',
  );
}


