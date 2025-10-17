# Culture Connection - Flutter App

## 🎯 Overview

Culture Connection is a professional networking and relationship-building app for the Black community, now migrated to Flutter for cross-platform support (iOS, Android, Web).

## ✨ Key Features

- **Multi-Type Connections**: Mentorship, Networking, Romantic, and Friendship
- **Skills-Based Matching**: 66 professional skills across 10 categories
- **Enhanced Search**: Multi-filter search by name, experience, and skills
- **Real-Time Chat**: Firestore-powered messaging
- **News Feed**: Community posts and engagement
- **Points & Rewards**: Gamification for engagement
- **Events**: Community events with RSVP
- **Black-Owned Businesses**: Directory of Black-owned businesses

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK
- Firebase account
- iOS/Android development environment

### Installation

1. **Clone the repository**
```bash
cd /workspace
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Firebase is already configured in firebase_options.dart
# If you need to reconfigure:
flutterfire configure
```

4. **Run the app**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 📁 Project Structure

```
lib/
├── constants/       # App colors, skills categories, experience levels
├── models/          # Data models (UserProfile, Post, ChatRoom, etc.)
├── services/        # Firebase services (Auth, Firestore, Storage, Messaging)
├── providers/       # Riverpod state management
├── screens/         # UI screens organized by feature
│   ├── auth/
│   ├── connections/
│   ├── chat/
│   ├── discover/
│   ├── search/
│   ├── events/
│   ├── business/
│   ├── forums/
│   └── profile/
├── utils/           # Validators and utilities
└── main.dart        # App entry point
```

## 🔧 Configuration

### Firebase Setup

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Enable the following services:
   - Authentication (Email/Password, Google, Apple)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging (FCM)
   - Analytics
   - Cloud Functions (optional)

3. Download and add configuration files:
   - `google-services.json` for Android (`android/app/`)
   - `GoogleService-Info.plist` for iOS (`ios/Runner/`)

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Profiles/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /Posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /ChatRooms/{chatRoomId} {
      allow read: if request.auth != null && 
                    request.auth.uid in resource.data.participants;
      allow write: if request.auth != null &&
                     request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
    }
    
    // Add more rules for other collections
  }
}
```

## 📊 Firestore Data Structure

### Profiles Collection
```dart
{
  "UserId": "string",
  "Full Name": "string",
  "Age": 25,
  "Gender": "string",
  "Experience Level": "Mid-Level",
  "Skills Offering": ["Software Development", "Web Design"],
  "Skills Seeking": ["Leadership", "Marketing"],
  "photoURL": "https://...",
  "fcmToken": "string",
  "totalPoints": 150,
  "createdAt": Timestamp,
  "lastActive": Timestamp
}
```

## 🎨 Branding

### Colors
- **Deep Purple**: #4A148C
- **Electric Orange**: #FF6D00
- **Silver Purple**: #9C27B0

### Fonts
- **Inter**: Primary font (Variable)
- **InterTight**: Secondary font (Italic)

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

**iOS**
```bash
flutter build ios --release
```

**Android**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**Web**
```bash
flutter build web --release
```

### Code Generation
```bash
# If using build_runner for Riverpod/Hive
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Features Status

### ✅ Complete
- User Authentication (Email, Google, Apple)
- User Registration (Simplified 3-page flow)
- User Profiles with Skills
- Enhanced User Search (Multi-filter)
- Real-time Chat
- News Feed
- Connections Hub
- Bottom Tab Navigation

### 🚧 In Progress
- Matching Algorithm
- Points & Rewards System
- Events Listing
- Black-Owned Business Directory
- Forums

### 📋 Planned
- Speed Mentoring
- Date Proposals
- Calendar Integration
- Video Calls
- Groups

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For support, email support@cultureconnection.com

## 🙏 Acknowledgments

- Original iOS app developers
- Flutter team for the amazing framework
- Firebase team for the backend infrastructure

---

**Built with ❤️ using Flutter**
