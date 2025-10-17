import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancedMatchingService {
  // Replace with your actual Firebase Function URL
  static const String _baseUrl =
      kDebugMode
          ? 'http://10.0.2.2:5001/culture-connection-d442f/us-central1' // Android emulator
          : 'https://us-central1-culture-connection-d442f.cloudfunctions.net';

  /// Call the runAdvancedMatching Firebase function
  static Future<Map<String, dynamic>> runAdvancedMatching() async {
    final url = Uri.parse('$_baseUrl/runAdvancedMatching');
    try {
      print('🚀 Calling advanced matching function: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Advanced matching completed: $result');
        return result;
      } else {
        print('❌ Failed to run advanced matching: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to run advanced matching: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error running advanced matching: $e');
      throw Exception('Error running advanced matching: $e');
    }
  }

  /// Trigger matching and get results
  static Future<Map<String, dynamic>> triggerMatching() async {
    try {
      final result = await runAdvancedMatching();
      
      if (result['success'] == true) {
        print('🎯 Matching completed successfully');
        print('Total users: ${result['totalUsers']}');
        print('Users with matches: ${result['usersWithMatches']}');
        print('Total matches: ${result['totalMatches']}');
        print('Notifications sent: ${result['notificationsSent']}');
      } else {
        print('❌ Matching failed: ${result['error']}');
      }
      
      return result;
    } catch (e) {
      print('❌ Error triggering matching: $e');
      rethrow;
    }
  }

  /// Get user matches from SkillMatches collection
  static Future<List<Map<String, dynamic>>> getUserMatches(String userId) async {
    try {
      print('🔍 Fetching skill matches for user: $userId');
      
      final doc = await FirebaseFirestore.instance
          .collection('SkillMatches')
          .doc(userId)
          .get();

      if (!doc.exists) {
        print('📭 No skill matches found for user');
        return [];
      }

      final data = doc.data()!;
      final matches = data['matches'] as List<dynamic>? ?? [];
      
      print('✅ Found ${matches.length} skill matches');
      
      return matches.map((match) => match as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching user matches: $e');
      return [];
    }
  }
}