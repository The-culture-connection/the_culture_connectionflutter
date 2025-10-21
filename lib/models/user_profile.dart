import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model - Unified for both old and new registration flows
class UserProfile {
  final String id;
  final String userId;
  final String fullName;
  final String fullname;
  final int age;
  final String gender;
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
  final List<String> skillsOffering;
  final List<String> skillsSeeking;
  final List<String> skillsOfferingCategories;
  final List<String> skillsSeekingCategories;
  final List<String> purposes;
  final String photoURL;
  final String? fcmToken;
  final int totalPoints;
  final Map<String, bool> blockedUsers;
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
  final DateTime? lastActive;

  const UserProfile({
    required this.id,
    this.userId = '',
    required this.fullName,
    this.fullname = '',
    required this.age,
    this.gender = '',
    this.bio = '',
    required this.experienceLevel,
    this.greekOrganization = '',
    this.otherOrganizations = '',
    this.industry = '',
    this.interests = '',
    this.jobTitle = '',
    this.major = '',
    this.personalityTraits = '',
    this.skills = '',
    this.skillsOffering = const [],
    this.skillsSeeking = const [],
    this.skillsOfferingCategories = const [],
    this.skillsSeekingCategories = const [],
    this.purposes = const [],
    this.photoURL = '',
    this.fcmToken,
    this.totalPoints = 0,
    this.blockedUsers = const {},
    this.connectionPreference = '',
    this.matchByIndustry = false,
    this.selectedIndustry = '',
    this.speedMentoring = false,
    this.minAgeSeeking = 18,
    this.maxAgeSeeking = 50,
    this.genderPreferences = '',
    this.networkinggoal = '',
    this.personalityTrait = '',
    this.jobLevel = '',
    this.wantsToImprove = '',
    this.email = '',
    this.location = '',
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.lastActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] ?? data['userId'] ?? '',
      userId: data['userId'] ?? data['id'] ?? '',
      fullName: data['Full Name'] ?? data['fullName'] ?? 'Unknown',
      fullname: data['fullname'] ?? data['Full Name'] ?? data['fullName'] ?? 'Unknown',
      age: data['Age'] ?? data['age'] ?? 0,
      gender: data['Gender'] ?? data['gender'] ?? '',
      bio: data['Bio'] ?? data['bio'] ?? '',
      experienceLevel: data['Experience Level'] ?? data['experienceLevel'] ?? 'Not specified',
      greekOrganization: data['Greek Organization'] ?? data['greekOrganization'] ?? 'Not specified',
      otherOrganizations: data['Other Organizations'] ?? data['otherOrganizations'] ?? 'Not specified',
      industry: data['Industry'] ?? data['industry'] ?? 'Not specified',
      interests: data['Interests and Hobbies'] ?? data['interests'] ?? 'Not specified',
      jobTitle: data['Job Title'] ?? data['jobTitle'] ?? 'Not specified',
      major: data['Major'] ?? data['major'] ?? 'Not specified',
      personalityTraits: data['Personality Traits'] ?? data['personalityTraits'] ?? 'Not specified',
      skills: data['Skills'] ?? data['skills'] ?? 'Not specified',
      skillsOffering: List<String>.from(data['Skills Offering'] ?? data['skillsOffering'] ?? []),
      skillsSeeking: List<String>.from(data['Skills Seeking'] ?? data['skillsSeeking'] ?? []),
      skillsOfferingCategories: List<String>.from(data['Skills Offering Categories'] ?? data['skillsOfferingCategories'] ?? []),
      skillsSeekingCategories: List<String>.from(data['Skills Seeking Categories'] ?? data['skillsSeekingCategories'] ?? []),
      purposes: List<String>.from(data['Purposes'] ?? data['purposes'] ?? []),
      photoURL: data['photoURL'] ?? '',
      fcmToken: data['fcmToken'],
      totalPoints: _parseIntFromDynamic(data['totalPoints']),
      blockedUsers: _parseBlockedUsers(data['blockedUsers']),
      connectionPreference: data['Connection Preference'] ?? data['connectionPreference'] ?? 'Mentee',
      matchByIndustry: _parseBoolean(data['matchByIndustry']) ?? false,
      selectedIndustry: data['selectedIndustry'] ?? '',
      speedMentoring: _parseBoolean(data['Speed Mentoring'] ?? data['speedMentoring']) ?? false,
      minAgeSeeking: data['minageseeking'] ?? data['minAgeSeeking'] ?? 18,
      maxAgeSeeking: data['maxageseeking'] ?? data['maxAgeSeeking'] ?? 50,
      genderPreferences: data['Gender Preferences'] ?? data['genderPreferences'] ?? 'Everyone',
      networkinggoal: data['Networking Goal'] ?? data['networkinggoal'] ?? 'Problem-Solving and Critical Thinking',
      personalityTrait: data['Personality Trait'] ?? data['personalityTrait'] ?? 'Not specified',
      jobLevel: data['Experience Level'] ?? data['jobLevel'] ?? 'Mid-Level',
      wantsToImprove: data['Areas of Improvement'] ?? data['wantsToImprove'] ?? 'Leadership and Management',
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      latitude: _parseDoubleFromDynamic(data['latitude']),
      longitude: _parseDoubleFromDynamic(data['longitude']),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] != null 
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : data['updatedAt'] != null 
              ? DateTime.parse(data['updatedAt'])
              : DateTime.now(),
      lastActive: data['lastActive'] is Timestamp 
          ? (data['lastActive'] as Timestamp).toDate()
          : data['lastActive'] != null 
              ? DateTime.parse(data['lastActive'])
              : null,
    );
  }

  /// Create from Map (alias for fromJson)
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile.fromJson(data);
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      userId: doc.id,
      fullName: data['Full Name'] ?? '',
      fullname: data['Full Name'] ?? '',
      age: _parseIntFromDynamic(data['Age']),
      gender: _parseStringFromDynamic(data['Gender']),
      bio: _parseStringFromDynamic(data['Bio']),
      experienceLevel: _parseStringFromDynamic(data['Experience Level']),
      greekOrganization: _parseStringFromDynamic(data['Greek Organization']),
      otherOrganizations: _parseStringFromDynamic(data['Other Organizations']),
      industry: _parseStringFromDynamic(data['Industry']),
      interests: _parseStringFromDynamic(data['Interests and Hobbies']),
      jobTitle: _parseStringFromDynamic(data['Job Title']),
      major: _parseStringFromDynamic(data['Major']),
      personalityTraits: _parseStringFromDynamic(data['Personality Traits']),
      skills: _parseStringFromDynamic(data['Skills']),
      skillsOffering: List<String>.from(data['Skills Offering'] ?? []),
      skillsSeeking: List<String>.from(data['Skills Seeking'] ?? []),
      skillsOfferingCategories: List<String>.from(data['Skills Offering Categories'] ?? []),
      skillsSeekingCategories: List<String>.from(data['Skills Seeking Categories'] ?? []),
      purposes: List<String>.from(data['Purposes'] ?? []),
      photoURL: data['photoURL'] ?? '',
      fcmToken: data['fcmToken'],
      totalPoints: _parseIntFromDynamic(data['totalPoints']),
      blockedUsers: _parseBlockedUsers(data['blockedUsers']),
      connectionPreference: _parseStringFromDynamic(data['Connection Preference']),
      matchByIndustry: _parseBoolean(data['matchByIndustry']) ?? false,
      selectedIndustry: _parseStringFromDynamic(data['selectedIndustry']),
      speedMentoring: _parseBoolean(data['Speed Mentoring']) ?? false,
      minAgeSeeking: _parseIntFromDynamic(data['minageseeking']) != 0 ? _parseIntFromDynamic(data['minageseeking']) : 18,
      maxAgeSeeking: _parseIntFromDynamic(data['maxageseeking']) != 0 ? _parseIntFromDynamic(data['maxageseeking']) : 50,
      genderPreferences: _parseStringFromDynamic(data['Gender Preferences']),
      networkinggoal: _parseStringFromDynamic(data['Networking Goal']),
      personalityTrait: _parseStringFromDynamic(data['Personality Trait']),
      jobLevel: _parseStringFromDynamic(data['Experience Level']),
      wantsToImprove: _parseStringFromDynamic(data['Areas of Improvement']),
      email: _parseStringFromDynamic(data['email']),
      location: _parseStringFromDynamic(data['location']),
      latitude: _parseDoubleFromDynamic(data['latitude']),
      longitude: _parseDoubleFromDynamic(data['longitude']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// Get user initials from fullname
  String get initials {
    final name = fullName.isNotEmpty ? fullName : fullname;
    if (name.isEmpty) return 'U';
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
  }

  /// Get display name (alias for fullname)
  String get displayName => fullName.isNotEmpty ? fullName : fullname;

  /// Get networking goal (alias for networkinggoal)
  String get networkingGoal => networkinggoal;

  /// Helper method to parse boolean values from various formats
  static bool? _parseBoolean(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == 'yes' || lowerValue == '1';
    }
    if (value is int) return value == 1;
    return false;
  }

  /// Helper method to parse blocked users map
  static Map<String, bool> _parseBlockedUsers(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, bool>) return value;
    if (value is Map) {
      final result = <String, bool>{};
      value.forEach((key, val) {
        if (key is String) {
          result[key] = _parseBoolean(val) ?? false;
        }
      });
      return result;
    }
    return {};
  }

  /// Helper method to parse string from dynamic value (handles both string and list)
  static String _parseStringFromDynamic(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  /// Helper method to parse integer from dynamic value (handles string, int, and other types)
  static int _parseIntFromDynamic(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  /// Helper method to parse double from dynamic value (handles string, double, and other types)
  static double? _parseDoubleFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
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
    if (photoURL.isNotEmpty && other.photoURL.isNotEmpty) {
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

  /// Copy with method for updating profile
  UserProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? fullname,
    int? age,
    String? gender,
    String? bio,
    String? experienceLevel,
    String? greekOrganization,
    String? otherOrganizations,
    String? industry,
    String? interests,
    String? jobTitle,
    String? major,
    String? personalityTraits,
    String? skills,
    List<String>? skillsOffering,
    List<String>? skillsSeeking,
    List<String>? skillsOfferingCategories,
    List<String>? skillsSeekingCategories,
    List<String>? purposes,
    String? photoURL,
    String? fcmToken,
    int? totalPoints,
    Map<String, bool>? blockedUsers,
    String? connectionPreference,
    bool? matchByIndustry,
    String? selectedIndustry,
    bool? speedMentoring,
    int? minAgeSeeking,
    int? maxAgeSeeking,
    String? genderPreferences,
    String? networkinggoal,
    String? personalityTrait,
    String? jobLevel,
    String? wantsToImprove,
    String? email,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      fullname: fullname ?? this.fullname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      greekOrganization: greekOrganization ?? this.greekOrganization,
      otherOrganizations: otherOrganizations ?? this.otherOrganizations,
      industry: industry ?? this.industry,
      interests: interests ?? this.interests,
      jobTitle: jobTitle ?? this.jobTitle,
      major: major ?? this.major,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      skills: skills ?? this.skills,
      skillsOffering: skillsOffering ?? this.skillsOffering,
      skillsSeeking: skillsSeeking ?? this.skillsSeeking,
      skillsOfferingCategories: skillsOfferingCategories ?? this.skillsOfferingCategories,
      skillsSeekingCategories: skillsSeekingCategories ?? this.skillsSeekingCategories,
      purposes: purposes ?? this.purposes,
      photoURL: photoURL ?? this.photoURL,
      fcmToken: fcmToken ?? this.fcmToken,
      totalPoints: totalPoints ?? this.totalPoints,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      connectionPreference: connectionPreference ?? this.connectionPreference,
      matchByIndustry: matchByIndustry ?? this.matchByIndustry,
      selectedIndustry: selectedIndustry ?? this.selectedIndustry,
      speedMentoring: speedMentoring ?? this.speedMentoring,
      minAgeSeeking: minAgeSeeking ?? this.minAgeSeeking,
      maxAgeSeeking: maxAgeSeeking ?? this.maxAgeSeeking,
      genderPreferences: genderPreferences ?? this.genderPreferences,
      networkinggoal: networkinggoal ?? this.networkinggoal,
      personalityTrait: personalityTrait ?? this.personalityTrait,
      jobLevel: jobLevel ?? this.jobLevel,
      wantsToImprove: wantsToImprove ?? this.wantsToImprove,
      email: email ?? this.email,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'fullname': fullname,
      'age': age,
      'gender': gender,
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
      'skillsOffering': skillsOffering,
      'skillsSeeking': skillsSeeking,
      'skillsOfferingCategories': skillsOfferingCategories,
      'skillsSeekingCategories': skillsSeekingCategories,
      'purposes': purposes,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'totalPoints': totalPoints,
      'blockedUsers': blockedUsers,
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
      'lastActive': lastActive,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'UserId': userId,
      'Full Name': fullName,
      'Age': age,
      'Gender': gender,
      'Bio': bio,
      'Experience Level': experienceLevel,
      'Greek Organization': greekOrganization,
      'Other Organizations': otherOrganizations,
      'Industry': industry,
      'Interests and Hobbies': interests,
      'Job Title': jobTitle,
      'Major': major,
      'Personality Traits': personalityTraits,
      'Skills': skills,
      'Skills Offering': skillsOffering,
      'Skills Seeking': skillsSeeking,
      'Skills Offering Categories': skillsOfferingCategories,
      'Skills Seeking Categories': skillsSeekingCategories,
      'Purposes': purposes,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'totalPoints': totalPoints,
      'blockedUsers': blockedUsers,
      'Connection Preference': connectionPreference,
      'matchByIndustry': matchByIndustry,
      'selectedIndustry': selectedIndustry,
      'Speed Mentoring': speedMentoring,
      'minageseeking': minAgeSeeking,
      'maxageseeking': maxAgeSeeking,
      'Gender Preferences': genderPreferences,
      'Networking Goal': networkinggoal,
      'Personality Trait': personalityTrait,
      'Job Level': jobLevel,
      'Areas of Improvement': wantsToImprove,
      'email': email,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, fullName: $fullName, experienceLevel: $experienceLevel)';
  }
}