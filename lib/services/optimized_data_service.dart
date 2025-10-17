import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'performance_service.dart';

/// Optimized data service with caching and performance improvements
class OptimizedDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get user profiles with caching and optimization
  static Future<List<UserProfile>> getProfilesOptimized({
    required String collection,
    String? connectionPreference,
    int? minAge,
    int? maxAge,
    String? genderPrefs,
    int limit = 20,
  }) async {
    final cacheKey = '${collection}_${connectionPreference}_${minAge}_${maxAge}_${genderPrefs}_$limit';
    
    return await PerformanceService.getCachedOrCompute(
      cacheKey,
      () async => await _fetchProfilesInIsolate({
        'collection': collection,
        'connectionPreference': connectionPreference,
        'minAge': minAge,
        'maxAge': maxAge,
        'genderPrefs': genderPrefs,
        'limit': limit,
      }),
      cacheExpiry: _cacheExpiry,
    );
  }

  /// Fetch profiles in isolate to avoid blocking main thread
  static Future<List<UserProfile>> _fetchProfilesInIsolate(Map<String, dynamic> params) async {
    return await _fetchProfilesCompute(params);
  }

  /// Compute function for profile fetching
  static Future<List<UserProfile>> _fetchProfilesCompute(Map<String, dynamic> params) async {
    try {
      final collection = params['collection'] as String;
      final connectionPreference = params['connectionPreference'] as String?;
      final minAge = params['minAge'] as int?;
      final maxAge = params['maxAge'] as int?;
      final genderPrefs = params['genderPrefs'] as String?;
      final limit = params['limit'] as int;

      Query query = _db.collection(collection).limit(limit);

      if (connectionPreference != null) {
        query = query.where('Connection Preference', isEqualTo: connectionPreference);
      }

      if (minAge != null) {
        query = query.where('Age', isGreaterThanOrEqualTo: minAge);
      }

      if (maxAge != null) {
        query = query.where('Age', isLessThanOrEqualTo: maxAge);
      }

      if (genderPrefs != null && genderPrefs != 'Everyone') {
        query = query.where('Gender Identity', isEqualTo: genderPrefs);
      }

      final snapshot = await query.get();
      final profiles = <UserProfile>[];

      for (final doc in snapshot.docs) {
        try {
          final profile = UserProfile.fromJson(doc.data() as Map<String, dynamic>);
          profiles.add(profile);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing profile ${doc.id}: $e');
          }
        }
      }

      return profiles;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profiles: $e');
      }
      return [];
    }
  }

  /// Get matches with optimization
  static Future<List<UserProfile>> getMatchesOptimized({
    required String currentUserId,
    bool isTraditional = true,
  }) async {
    final cacheKey = 'matches_${currentUserId}_${isTraditional}';
    
    return await PerformanceService.getCachedOrCompute(
      cacheKey,
      () async => await _fetchMatchesInIsolate({
        'currentUserId': currentUserId,
        'isTraditional': isTraditional,
      }),
      cacheExpiry: const Duration(minutes: 2),
    );
  }

  /// Fetch matches in isolate
  static Future<List<UserProfile>> _fetchMatchesInIsolate(Map<String, dynamic> params) async {
    return await _fetchMatchesCompute(params);
  }

  /// Compute function for matches fetching
  static Future<List<UserProfile>> _fetchMatchesCompute(Map<String, dynamic> params) async {
    try {
      final currentUserId = params['currentUserId'] as String;
      final isTraditional = params['isTraditional'] as bool;

      if (isTraditional) {
        return await _fetchTraditionalMatches(currentUserId);
      } else {
        return await _fetchSkillBasedMatches(currentUserId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching matches: $e');
      }
      return [];
    }
  }

  /// Fetch traditional matches
  static Future<List<UserProfile>> _fetchTraditionalMatches(String currentUserId) async {
    final matchesSnapshot = await _db
        .collection('matches')
        .where('user1Id', isEqualTo: currentUserId)
        .get();

    final matches2Snapshot = await _db
        .collection('matches')
        .where('user2Id', isEqualTo: currentUserId)
        .get();

    final allMatches = <String>[];
    
    for (final doc in matchesSnapshot.docs) {
      final data = doc.data();
      final user2Id = data['user2Id'] as String?;
      if (user2Id != null) allMatches.add(user2Id);
    }
    
    for (final doc in matches2Snapshot.docs) {
      final data = doc.data();
      final user1Id = data['user1Id'] as String?;
      if (user1Id != null) allMatches.add(user1Id);
    }

    final profiles = <UserProfile>[];
    for (final userId in allMatches) {
      try {
        final userDoc = await _db.collection('Profiles').doc(userId).get();
        if (userDoc.exists) {
          final profile = UserProfile.fromJson(userDoc.data()! as Map<String, dynamic>);
          profiles.add(profile);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading profile for $userId: $e');
        }
      }
    }

    return profiles;
  }

  /// Fetch skill-based matches
  static Future<List<UserProfile>> _fetchSkillBasedMatches(String currentUserId) async {
    final skillMatchesDoc = await _db
        .collection('SkillMatches')
        .doc(currentUserId)
        .get();

    if (!skillMatchesDoc.exists) {
      return [];
    }

    final data = skillMatchesDoc.data()!;
    final matches = data['matches'] as List<dynamic>? ?? [];
    
    final profiles = <UserProfile>[];
    for (final match in matches) {
      try {
        final userId = match['userId'] as String?;
        if (userId != null) {
          final userDoc = await _db.collection('Profiles').doc(userId).get();
          if (userDoc.exists) {
            final profile = UserProfile.fromJson(userDoc.data()! as Map<String, dynamic>);
            profiles.add(profile);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading skill match profile: $e');
        }
      }
    }

    return profiles;
  }

  /// Clear cache when needed
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    PerformanceService.clearCache();
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final timestamp = _cacheTimestamps[key];
      return timestamp != null && now.difference(timestamp) > _cacheExpiry;
    });
    PerformanceService.clearExpiredCache();
  }
}
