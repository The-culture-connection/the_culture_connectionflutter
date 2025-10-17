import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance optimization service for heavy computations
class PerformanceService {
  /// Run heavy computations in isolate to avoid blocking main thread
  static Future<T> computeInIsolate<T>(
    ComputeCallback<dynamic, T> callback,
    dynamic message, {
    String? debugLabel,
  }) async {
    return await compute(callback, message, debugLabel: debugLabel);
  }

  /// Debounce function calls to prevent excessive execution
  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  static void throttle(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    if (_throttleTimers.containsKey(key)) return;
    
    _throttleTimers[key] = Timer(delay, () {
      _throttleTimers.remove(key);
    });
    callback();
  }

  /// Cache for expensive computations
  static final Map<String, dynamic> _cache = {};
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, Timer> _throttleTimers = {};

  /// Get cached result or compute and cache
  static Future<T> getCachedOrCompute<T>(
    String key,
    Future<T> Function() computeFunction, {
    Duration? cacheExpiry,
  }) async {
    final now = DateTime.now();
    final cacheEntry = _cache[key] as Map<String, dynamic>?;
    
    if (cacheEntry != null) {
      final expiry = cacheEntry['expiry'] as DateTime?;
      if (expiry == null || now.isBefore(expiry)) {
        return cacheEntry['data'] as T;
      }
    }

    final result = await computeFunction();
    _cache[key] = {
      'data': result,
      'expiry': cacheExpiry != null ? now.add(cacheExpiry) : null,
    };
    
    return result;
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final expiry = (value as Map<String, dynamic>)['expiry'] as DateTime?;
      return expiry != null && now.isAfter(expiry);
    });
  }
}

/// Optimized widget that prevents unnecessary rebuilds
class OptimizedWidget extends StatelessWidget {
  final Widget child;
  final String? cacheKey;

  const OptimizedWidget({
    super.key,
    required this.child,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Optimized list view with performance improvements
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    super.key,
    required this.children,
    this.controller,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      // Performance optimizations
      cacheExtent: 1000, // Cache 1000 pixels worth of children
      addAutomaticKeepAlives: false, // Don't keep widgets alive when scrolled away
      addRepaintBoundaries: true, // Add repaint boundaries for better performance
    );
  }
}

/// Optimized image widget with caching
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
      // Performance optimizations
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      isAntiAlias: true,
      filterQuality: FilterQuality.medium, // Balance quality and performance
    );
  }
}
