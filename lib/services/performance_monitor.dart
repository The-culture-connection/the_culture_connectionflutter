import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance monitoring service
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _measurements = {};
  static final List<PerformanceEvent> _events = [];
  static Timer? _cleanupTimer;

  /// Start timing an operation
  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  /// End timing an operation
  static Duration? endTimer(String operation) {
    final timer = _timers.remove(operation);
    if (timer == null) return null;
    
    timer.stop();
    final duration = timer.elapsed;
    
    // Store measurement
    _measurements.putIfAbsent(operation, () => []).add(duration);
    
    // Log if operation took too long
    if (duration.inMilliseconds > 16) {
      _logEvent(PerformanceEvent(
        operation: operation,
        duration: duration,
        severity: PerformanceSeverity.warning,
        message: 'Operation took ${duration.inMilliseconds}ms (target: 16ms)',
      ));
    }
    
    return duration;
  }

  /// Measure a function execution time
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    startTimer(operation);
    try {
      final result = await function();
      endTimer(operation);
      return result;
    } catch (e) {
      endTimer(operation);
      _logEvent(PerformanceEvent(
        operation: operation,
        duration: Duration.zero,
        severity: PerformanceSeverity.error,
        message: 'Operation failed: $e',
      ));
      rethrow;
    }
  }

  /// Log a performance event
  static void _logEvent(PerformanceEvent event) {
    _events.add(event);
    
    // Keep only last 100 events
    if (_events.length > 100) {
      _events.removeAt(0);
    }
    
    if (kDebugMode) {
      print('Performance: ${event.operation} - ${event.message}');
    }
  }

  /// Get performance statistics
  static Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _measurements.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final total = durations.fold<Duration>(
          Duration.zero,
          (sum, duration) => sum + duration,
        );
        
        stats[entry.key] = {
          'count': durations.length,
          'total_ms': total.inMilliseconds,
          'average_ms': (total.inMilliseconds / durations.length).round(),
          'min_ms': durations.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b),
          'max_ms': durations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b),
        };
      }
    }
    
    return stats;
  }

  /// Get recent events
  static List<PerformanceEvent> getRecentEvents({int limit = 20}) {
    if (_events.length <= limit) {
      return List<PerformanceEvent>.from(_events);
    }
    return _events.sublist(_events.length - limit);
  }

  /// Clear all data
  static void clear() {
    _timers.clear();
    _measurements.clear();
    _events.clear();
  }

  /// Initialize cleanup timer
  static void initialize() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupOldData();
    });
  }

  /// Clean up old data
  static void _cleanupOldData() {
    // Remove measurements older than 1 hour
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    
    // Keep only recent events
    _events.removeWhere((event) => event.timestamp.isBefore(cutoff));
    
    // Clear old measurements
    for (final key in _measurements.keys.toList()) {
      _measurements[key]!.removeWhere((duration) => 
        duration.inMilliseconds > 300000); // 5 minutes
    }
  }

  /// Dispose resources
  static void dispose() {
    _cleanupTimer?.cancel();
    clear();
  }
}

/// Performance event data
class PerformanceEvent {
  final String operation;
  final Duration duration;
  final PerformanceSeverity severity;
  final String message;
  final DateTime timestamp;

  PerformanceEvent({
    required this.operation,
    required this.duration,
    required this.severity,
    required this.message,
  }) : timestamp = DateTime.now();
}

/// Performance severity levels
enum PerformanceSeverity {
  info,
  warning,
  error,
}

/// Performance monitoring widget
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      PerformanceMonitor.initialize();
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      PerformanceMonitor.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance overlay for debugging
class PerformanceOverlay extends StatelessWidget {
  const PerformanceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...PerformanceMonitor.getStats().entries.map((entry) {
              final stats = entry.value as Map<String, dynamic>;
              return Text(
                '${entry.key}: ${stats['average_ms']}ms avg',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              );
            }),
          ],
        ),
      ),
    );
  }
}
