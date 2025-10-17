class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? bio;
  final String? location;
  final List<String> interests;
  final List<String> skills;
  final String? profession;
  final String? education;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.firstName,
    this.lastName,
    this.age,
    this.bio,
    this.location,
    this.interests = const [],
    this.skills = const [],
    this.profession,
    this.education,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age']?.toString(),
      bio: json['bio'],
      location: json['location'],
      interests: List<String>.from(json['interests'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      profession: json['profession'],
      education: json['education'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'bio': bio,
      'location': location,
      'interests': interests,
      'skills': skills,
      'profession': profession,
      'education': education,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? firstName,
    String? lastName,
    String? age,
    String? bio,
    String? location,
    List<String>? interests,
    List<String>? skills,
    String? profession,
    String? education,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      profession: profession ?? this.profession,
      education: education ?? this.education,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
