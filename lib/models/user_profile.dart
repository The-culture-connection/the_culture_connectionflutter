import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model - Simplified registration fields
class UserProfile {
  final String userId;
  final String fullName;
  final int age;
  final String gender;
  final String experienceLevel;
  final List<String> skillsOffering;
  final List<String> skillsSeeking;
  final String photoURL;
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
  
  // Additional fields
  final String? bio;
  final String? location;
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
    required this.photoURL,
    this.fcmToken,
    this.totalPoints = 0,
    Map<String, bool>? blockedUsers,
    this.genderPreferences,
    this.agePreferences,
    this.connectionPreference,
    this.networkingGoal,
    this.relationshipGoal,
    this.friendshipGoal,
    this.bio,
    this.location,
    DateTime? createdAt,
    this.lastActive,
  })  : blockedUsers = blockedUsers ?? {},
        createdAt = createdAt ?? DateTime.now();

  /// Create UserProfile from Firestore document
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
      photoURL: data['photoURL'] ?? '',
      fcmToken: data['fcmToken'],
      totalPoints: data['totalPoints'] ?? 0,
      blockedUsers: Map<String, bool>.from(data['blockedUsers'] ?? {}),
      genderPreferences: data['Gender Preferences'],
      agePreferences: data['Age Preferences'],
      connectionPreference: data['Connection Preference'],
      networkingGoal: data['Networking Goal'],
      relationshipGoal: data['Relationship Goal'],
      friendshipGoal: data['Friendship Goal'],
      bio: data['bio'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert UserProfile to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'UserId': userId,
      'Full Name': fullName,
      'Age': age,
      'Gender': gender,
      'Experience Level': experienceLevel,
      'Skills Offering': skillsOffering,
      'Skills Seeking': skillsSeeking,
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
      'bio': bio,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Copy with method for updates
  UserProfile copyWith({
    String? userId,
    String? fullName,
    int? age,
    String? gender,
    String? experienceLevel,
    List<String>? skillsOffering,
    List<String>? skillsSeeking,
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
    String? bio,
    String? location,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skillsOffering: skillsOffering ?? this.skillsOffering,
      skillsSeeking: skillsSeeking ?? this.skillsSeeking,
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
      bio: bio ?? this.bio,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
