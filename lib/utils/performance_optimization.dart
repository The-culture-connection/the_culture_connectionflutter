import 'package:flutter/material.dart';

/// PerformanceOptimization - Utility class for performance best practices
class PerformanceOptimization {
  
  /// Optimize ListView.builder for better performance
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    double? itemExtent,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemExtent: itemExtent, // Use when items have similar heights
      // Add cacheExtent for better scrolling performance
      cacheExtent: 1000.0,
    );
  }

  /// Optimize images with proper caching and sizing
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF7E00),
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(
          Icons.error_outline,
          color: Colors.white54,
          size: 48,
        );
      },
      // Enable caching
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }

  /// Create optimized container with pre-defined styles
  static Widget optimizedContainer({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  /// Optimize text widgets with const constructors
  static const TextStyle businessNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter',
  );

  static const TextStyle categoryStyle = TextStyle(
    color: Color(0xFFFF7E00),
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
  );

  static const TextStyle addressStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'Inter',
  );

  static const TextStyle phoneStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'Inter',
  );

  /// Optimize button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF7E00),
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2A2A2A),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  /// Optimize card decoration
  static const BoxDecoration cardDecoration = BoxDecoration(
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

  /// Optimize category decoration
  static const BoxDecoration categoryDecoration = BoxDecoration(
    color: Color(0x26FF7E00),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  /// Debounce function for search inputs
  static void debounce({
    required Duration delay,
    required VoidCallback action,
  }) {
    // Implementation would use Timer.periodic or similar
    // This is a placeholder for the concept
  }

  /// Optimize widget rebuilds with const constructors
  static const Widget loadingIndicator = Center(
    child: CircularProgressIndicator(
      color: Color(0xFFFF7E00),
      strokeWidth: 2,
    ),
  );

  static const Widget emptyState = Center(
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
      ],
    ),
  );
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static void logFrameTime(String operation, Duration duration) {
    if (duration.inMilliseconds > 16) { // More than one frame
      print('⚠️ Slow operation: $operation took ${duration.inMilliseconds}ms');
    }
  }

  static void logMemoryUsage(String context) {
    // This would use dart:developer or similar to log memory usage
    print('📊 Memory usage at: $context');
  }
}


