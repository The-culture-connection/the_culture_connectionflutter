import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  final String matchId;
  final String matchName;
  final double score;
  final String? industry;
  final String why;

  Match({
    required this.matchId,
    required this.matchName,
    required this.score,
    this.industry,
    required this.why,
  });

  factory Match.fromMap(Map<String, dynamic> data) {
    // Handle both 'why' (old format) and 'reasons' (new format from Firebase function)
    String whyText = '';
    if (data['why'] != null) {
      whyText = data['why'] as String;
    } else if (data['reasons'] != null) {
      final reasons = data['reasons'] as List<dynamic>?;
      if (reasons != null && reasons.isNotEmpty) {
        whyText = reasons.join(', ');
      }
    }
    
    return Match(
      matchId: data['uid'] ?? data['matchId'] ?? data['userId'] ?? '',
      matchName: data['matchName'] ?? data['name'] ?? 'Unknown',
      score: (data['score'] ?? 0.0).toDouble(),
      industry: data['industry'],
      why: whyText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': matchId,
      'matchName': matchName,
      'score': score,
      'industry': industry,
      'why': why,
    };
  }
}

class UserMatch {
  final String userId;
  final String userName;
  final List<Match> matches;
  final DateTime runAt;

  UserMatch({
    required this.userId,
    required this.userName,
    required this.matches,
    required this.runAt,
  });

  factory UserMatch.fromMap(Map<String, dynamic> data) {
    final matchesData = data['matches'] as List<dynamic>? ?? [];
    final matches = matchesData
        .map((matchData) => Match.fromMap(matchData as Map<String, dynamic>))
        .toList();

    return UserMatch(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      matches: matches,
      runAt: (data['runAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'matches': matches.map((match) => match.toMap()).toList(),
      'runAt': Timestamp.fromDate(runAt),
    };
  }
}
