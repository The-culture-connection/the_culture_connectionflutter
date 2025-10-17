<<<<<<< HEAD
/// Simple UserProfile model to fix compilation errors
class UserProfile {
  final String id;
  final String fullname;
  final int age;
  final String bio;
  final String experienceLevel;
  final String greekOrganization;
  final String otherOrganizations;
  final String industry;
  final String interests;
  final String jobTitle;
  final String major;
  final String personalityTraits;
  final String skills;
  final String photoURL;
  final String connectionPreference;
  final bool matchByIndustry;
  final String selectedIndustry;
  final bool speedMentoring;
  final int minAgeSeeking;
  final int maxAgeSeeking;
  final String genderPreferences;
  final String networkinggoal;
  final String personalityTrait;
  final String jobLevel;
  final String wantsToImprove;
  final String email;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.fullname,
    required this.age,
    required this.bio,
    required this.experienceLevel,
    required this.greekOrganization,
    required this.otherOrganizations,
    required this.industry,
    required this.interests,
    required this.jobTitle,
    required this.major,
    required this.personalityTraits,
    required this.skills,
    required this.photoURL,
    required this.connectionPreference,
    required this.matchByIndustry,
    required this.selectedIndustry,
    required this.speedMentoring,
    required this.minAgeSeeking,
    required this.maxAgeSeeking,
    required this.genderPreferences,
    required this.networkinggoal,
    required this.personalityTrait,
    required this.jobLevel,
    required this.wantsToImprove,
    required this.email,
    required this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] ?? '',
      fullname: data['Full Name'] ?? 'Unknown',
      age: data['Age'] ?? 0,
      bio: data['Bio'] ?? '',
      experienceLevel: data['Experience Level'] ?? 'Not specified',
      greekOrganization: data['Greek Organization'] ?? 'Not specified',
      otherOrganizations: data['Other Organizations'] ?? 'Not specified',
      industry: data['Industry'] ?? 'Not specified',
      interests: data['Interests and Hobbies'] ?? 'Not specified',
      jobTitle: data['Job Title'] ?? 'Not specified',
      major: data['Major'] ?? 'Not specified',
      personalityTraits: data['Personality Traits'] ?? 'Not specified',
      skills: data['Skills'] ?? 'Not specified',
      photoURL: data['photoURL'] ?? '',
      connectionPreference: data['Connection Preference'] ?? 'Mentee',
      matchByIndustry: data['matchByIndustry'] ?? false,
      selectedIndustry: data['selectedIndustry'] ?? '',
      speedMentoring: data['Speed Mentoring'] ?? false,
      minAgeSeeking: data['minageseeking'] ?? 18,
      maxAgeSeeking: data['maxageseeking'] ?? 50,
      genderPreferences: data['Gender Preferences'] ?? 'Everyone',
      networkinggoal: data['Networking Goal'] ?? 'Problem-Solving and Critical Thinking',
      personalityTrait: data['Personality Trait'] ?? 'Not specified',
      jobLevel: data['Experience Level'] ?? 'Mid-Level',
      wantsToImprove: data['Areas of Improvement'] ?? 'Leadership and Management',
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get user initials from fullname
  String get initials {
    if (fullname.isEmpty) return 'U';
    final names = fullname.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
  }

  /// Get display name (alias for fullname)
  String get displayName => fullname;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'age': age,
      'bio': bio,
      'experienceLevel': experienceLevel,
      'greekOrganization': greekOrganization,
      'otherOrganizations': otherOrganizations,
      'industry': industry,
      'interests': interests,
      'jobTitle': jobTitle,
      'major': major,
      'personalityTraits': personalityTraits,
      'skills': skills,
      'photoURL': photoURL,
      'connectionPreference': connectionPreference,
      'matchByIndustry': matchByIndustry,
      'selectedIndustry': selectedIndustry,
      'speedMentoring': speedMentoring,
      'minAgeSeeking': minAgeSeeking,
      'maxAgeSeeking': maxAgeSeeking,
      'genderPreferences': genderPreferences,
      'networkinggoal': networkinggoal,
      'personalityTrait': personalityTrait,
      'jobLevel': jobLevel,
      'wantsToImprove': wantsToImprove,
      'email': email,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
=======
import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model - Simplified for new registration flow
class UserProfile {
  final String userId;
  final String fullName;
  final int age;
  final String gender;
  final String experienceLevel;
  final List<String> skillsOffering;
  final List<String> skillsSeeking;
  final List<String> purposes; // "What brought you here"
  final String? photoURL;
  final String? fcmToken;
  final int totalPoints;
  final Map<String, bool> blockedUsers;
  
  // Preferences
  final String? genderPreferences;
  final String? agePreferences;
  final String? connectionPreference;
  final String? networkingGoal;
  final String? relationshipGoal;
  final String? friendshipGoal;
  
  // Metadata
  final DateTime createdAt;
  final DateTime? lastActive;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.experienceLevel,
    required this.skillsOffering,
    required this.skillsSeeking,
    this.purposes = const [],
    this.photoURL,
    this.fcmToken,
    this.totalPoints = 0,
    this.blockedUsers = const {},
    this.genderPreferences,
    this.agePreferences,
    this.connectionPreference,
    this.networkingGoal,
    this.relationshipGoal,
    this.friendshipGoal,
    required this.createdAt,
    this.lastActive,
  });

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      fullName: data['Full Name'] ?? '',
      age: data['Age'] ?? 0,
      gender: data['Gender'] ?? '',
      experienceLevel: data['Experience Level'] ?? '',
      skillsOffering: List<String>.from(data['Skills Offering'] ?? []),
      skillsSeeking: List<String>.from(data['Skills Seeking'] ?? []),
      purposes: List<String>.from(data['Purposes'] ?? []),
      photoURL: data['photoURL'],
      fcmToken: data['fcmToken'],
      totalPoints: data['totalPoints'] ?? 0,
      blockedUsers: Map<String, bool>.from(data['blockedUsers'] ?? {}),
      genderPreferences: data['Gender Preferences'],
      agePreferences: data['Age Preferences'],
      connectionPreference: data['Connection Preference'],
      networkingGoal: data['Networking Goal'],
      relationshipGoal: data['Relationship Goal'],
      friendshipGoal: data['Friendship Goal'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'UserId': userId,
      'Full Name': fullName,
      'Age': age,
      'Gender': gender,
      'Experience Level': experienceLevel,
      'Skills Offering': skillsOffering,
      'Skills Seeking': skillsSeeking,
      'Purposes': purposes,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'totalPoints': totalPoints,
      'blockedUsers': blockedUsers,
      'Gender Preferences': genderPreferences,
      'Age Preferences': agePreferences,
      'Connection Preference': connectionPreference,
      'Networking Goal': networkingGoal,
      'Relationship Goal': relationshipGoal,
      'Friendship Goal': friendshipGoal,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Copy with method for updating profile
  UserProfile copyWith({
    String? fullName,
    int? age,
    String? gender,
    String? experienceLevel,
    List<String>? skillsOffering,
    List<String>? skillsSeeking,
    List<String>? purposes,
    String? photoURL,
    String? fcmToken,
    int? totalPoints,
    Map<String, bool>? blockedUsers,
    String? genderPreferences,
    String? agePreferences,
    String? connectionPreference,
    String? networkingGoal,
    String? relationshipGoal,
    String? friendshipGoal,
    DateTime? lastActive,
  }) {
    return UserProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skillsOffering: skillsOffering ?? this.skillsOffering,
      skillsSeeking: skillsSeeking ?? this.skillsSeeking,
      purposes: purposes ?? this.purposes,
      photoURL: photoURL ?? this.photoURL,
      fcmToken: fcmToken ?? this.fcmToken,
      totalPoints: totalPoints ?? this.totalPoints,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      genderPreferences: genderPreferences ?? this.genderPreferences,
      agePreferences: agePreferences ?? this.agePreferences,
      connectionPreference: connectionPreference ?? this.connectionPreference,
      networkingGoal: networkingGoal ?? this.networkingGoal,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      friendshipGoal: friendshipGoal ?? this.friendshipGoal,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Check if user has specific skill offering
  bool hasSkillOffering(String skill) {
    return skillsOffering.contains(skill);
  }

  /// Check if user is seeking specific skill
  bool isSeekingSkill(String skill) {
    return skillsSeeking.contains(skill);
  }

  /// Get matching skills with another user
  List<String> getMatchingSkills(UserProfile other) {
    List<String> matches = [];
    
    // Skills I offer that they're seeking
    for (var skill in skillsOffering) {
      if (other.skillsSeeking.contains(skill)) {
        matches.add(skill);
      }
    }
    
    // Skills they offer that I'm seeking
    for (var skill in other.skillsOffering) {
      if (skillsSeeking.contains(skill)) {
        matches.add(skill);
      }
    }
    
    return matches.toSet().toList(); // Remove duplicates
  }

  /// Calculate compatibility score with another user (0-100)
  double calculateCompatibility(UserProfile other) {
    int score = 0;
    
    // Matching skills (up to 40 points)
    final matchingSkills = getMatchingSkills(other);
    score += (matchingSkills.length * 10).clamp(0, 40);
    
    // Similar experience level (up to 20 points)
    if (experienceLevel == other.experienceLevel) {
      score += 20;
    } else if (_isAdjacentExperienceLevel(experienceLevel, other.experienceLevel)) {
      score += 10;
    }
    
    // Age similarity (up to 20 points)
    final ageDiff = (age - other.age).abs();
    if (ageDiff <= 5) {
      score += 20;
    } else if (ageDiff <= 10) {
      score += 10;
    } else if (ageDiff <= 15) {
      score += 5;
    }
    
    // Both have profile photos (up to 10 points)
    if (photoURL != null && other.photoURL != null) {
      score += 10;
    }
    
    // Active users (up to 10 points)
    if (lastActive != null && other.lastActive != null) {
      final daysSinceActive = DateTime.now().difference(lastActive!).inDays;
      final otherDaysSinceActive = DateTime.now().difference(other.lastActive!).inDays;
      
      if (daysSinceActive <= 7 && otherDaysSinceActive <= 7) {
        score += 10;
      } else if (daysSinceActive <= 14 && otherDaysSinceActive <= 14) {
        score += 5;
      }
    }
    
    return score.toDouble().clamp(0, 100);
  }

  bool _isAdjacentExperienceLevel(String level1, String level2) {
    const levels = ['Entry-Level', 'Mid-Level', 'Senior-Level', 'Executive'];
    final index1 = levels.indexOf(level1);
    final index2 = levels.indexOf(level2);
    
    if (index1 == -1 || index2 == -1) return false;
    
    return (index1 - index2).abs() == 1;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, fullName: $fullName, experienceLevel: $experienceLevel)';
  }
>>>>>>> 48e870b02ee1b0c01e22f1fa0652b170ae47e07e
}
