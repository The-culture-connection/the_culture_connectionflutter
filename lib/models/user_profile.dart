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
}
