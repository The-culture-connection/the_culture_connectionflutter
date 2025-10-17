# Culture Connection - iOS to Flutter Migration Guide

## 📋 Migration Status

This document tracks the complete migration from the iOS Swift app to Flutter with the NEW simplified registration flow.

---

## ✅ COMPLETED FEATURES

### 1. **Project Setup**
- ✅ Flutter dependencies configured
- ✅ Firebase integration (Core, Auth, Firestore, Storage, Messaging, Analytics, Functions)
- ✅ State management with Riverpod
- ✅ Navigation with GoRouter
- ✅ Asset configuration (fonts, images)
- ✅ App branding colors configured

### 2. **Data Models**
All models created with Firestore integration:
- ✅ UserProfile (NEW simplified fields)
- ✅ Post
- ✅ ChatRoom
- ✅ Message
- ✅ Event
- ✅ Business
- ✅ DateProposal
- ✅ Connection
- ✅ Match
- ✅ EarnedPoints
- ✅ Forum

### 3. **Constants & Utilities**
- ✅ AppColors (Culture Connection brand colors)
- ✅ SkillsCategories (NEW 10 categories with all subcategories)
- ✅ ExperienceLevels
- ✅ Validators (email, password, age, name, etc.)

### 4. **Core Services**
- ✅ AuthService (Email, Google, Apple Sign-In)
- ✅ FirestoreService (Complete CRUD operations)
- ✅ StorageService (Photo uploads)
- ✅ MessagingService (FCM push notifications)

### 5. **Authentication Screens**
- ✅ LoginScreen
- ✅ PasswordResetScreen  
- ⏳ RegistrationScreen (NEW SIMPLIFIED - In Progress)

---

## 🔄 IN PROGRESS

### NEW Simplified Registration Flow
**OLD FLOW (7 steps)** → **NEW FLOW (1 step)**

#### Fields Being Consolidated:
1. ~~RegisterUser (Email & Password)~~
2. ~~RegistrationTwoView (Name, Age, Bio, Photo)~~
3. ~~RegistrationThreeView (Job Title, Industry, University, Major, Greek Org)~~
4. ~~RegistrationFourView (Connection Preference, Goals)~~
5. ~~RegistrationFiveView (Skills, Areas of Improvement, Experience Level)~~
6. ~~RegistrationSixView (Relationship Status)~~
7. ~~RegistrationSevenView (Gender Identity)~~

#### NEW SINGLE-STEP REGISTRATION FIELDS:
✅ **Required Fields:**
- Gender (Dropdown)
- Experience Level (Dropdown)
- Full Name (Text Field)
- Email (Text Field)
- Password (Secure Field)
- Photo (Image Picker)
- Age (Number Input)
- Skills Offering (Multi-select from 10 categories)
- Skills Seeking (Multi-select from 10 categories)

✅ **Automatic Defaults:**
- Gender Preferences: "Everyone"
- Age Preferences: "Everyone"
- Speed Mentoring: "Yes"
- minageseeking: "18"
- maxageseeking: "99"

---

## 📊 NEW SKILLS CATEGORIES (10 Categories)

### 🔧 Technology & Engineering
- Software Development
- Web Design / UX/UI Design
- App Development (iOS / Android / Flutter)
- Data Analysis / Data Science
- Machine Learning / AI Integration
- Cybersecurity
- Cloud Computing (AWS / Firebase / Azure)
- IT Support & Systems Administration
- Automation / Scripting
- CAD Design / Product Prototyping
- Electrical / Mechanical Engineering

### 📢 Marketing, Branding & PR
- Public Relations (PR)
- Brand Strategy
- Marketing Campaign Development
- Social Media Management
- Copywriting / Content Strategy
- Influencer Relations
- Event Marketing / Experiential Marketing
- SEO / SEM / Paid Ads
- Graphic Design
- Video Editing / Photography

### 💼 Business, Finance & Consulting
- Financial Consulting
- Funding Strategy / Grant Writing
- Business Planning & Modeling
- Accounting / Bookkeeping
- Market Research / Competitive Analysis
- Strategic Partnerships
- Investor Relations / Pitch Decks
- Sales / Lead Generation
- Project Management
- Business Development

### 🧩 Leadership & Organizational Development
- Executive Leadership Coaching
- Team Building / Organizational Culture
- Diversity, Equity & Inclusion Strategy
- Public Speaking / Communication
- Time Management / Productivity Systems
- Conflict Resolution / Mediation

### 💡 Entrepreneurship & Startups
- Startup Formation & Legal Structure
- Fundraising / Venture Capital Readiness
- Pitching & Investor Relations
- Product Development
- Scaling Operations
- Community Building

### 🎨 Creative, Media & Arts
- Photography / Videography
- Creative Direction
- Fashion Design / Styling
- Music Production / Audio Engineering
- Writing / Editing / Journalism
- Visual Arts / Illustration
- Acting / Performing Arts

### 🧘🏽‍♀️ Health, Wellness & Lifestyle
- Therapy / Counseling
- Life Coaching / Mindset Coaching
- Nutrition / Fitness Training
- Yoga / Meditation Instruction
- Wellness Brand Strategy
- Health Tech Innovation

### 🏫 Education & Mentorship
- Tutoring / Academic Support
- Curriculum Development
- Training & Facilitation
- Career Coaching / Resume Support
- Mentorship / Professional Guidance

### 🏠 Trades & Services
- Construction / General Contracting
- Real Estate / Property Management
- Home Design / Interior Decorating
- Cleaning / Maintenance
- Landscaping / Sustainability

---

## 🎯 ENHANCED SEARCH FUNCTIONALITY

### NEW Multi-Filter Search
Users can search by:
1. **Name** (text search)
2. **Experience Level** (dropdown filter)
3. **Skills Offering** (multi-select from categories)
4. **Skills Seeking** (multi-select from categories)

### Firestore Query Implementation:
```dart
// Name search
query.where('Full Name', isGreaterThanOrEqualTo: nameFilter)
     .where('Full Name', isLessThan: nameFilter + '\uf8ff');

// Experience level filter
query.where('Experience Level', isEqualTo: experienceFilter);

// Skills offering filter
query.where('Skills Offering', arrayContainsAny: skillsOfferingFilter);

// Skills seeking filter
query.where('Skills Seeking', arrayContainsAny: skillsSeekingFilter);
```

---

## 🗄️ FIREBASE FIRESTORE STRUCTURE

### Profiles Collection
```
Profiles/{userId}
├── UserId: string
├── Full Name: string
├── Age: int
├── Gender: string
├── Experience Level: string
├── Skills Offering: array<string>  ← NEW
├── Skills Seeking: array<string>   ← NEW
├── photoURL: string
├── fcmToken: string
├── totalPoints: int
├── blockedUsers: map<string, bool>
├── Gender Preferences: string
├── Age Preferences: string
├── Connection Preference: string
├── Networking Goal: string
├── Relationship Goal: string
├── Friendship Goal: string
├── createdAt: timestamp
└── lastActive: timestamp
```

### Other Collections
- **Posts**: title, description, type, userId, postPhotoURL, timestamp
- **ChatRooms**: participants, createdAt, lastMessage, lastMessageTimestamp
  - **messages** (subcollection): senderId, text, timestamp
  - **dateProposals** (subcollection): proposerId, details, date, place, status
- **Connects**: fromUserId, toUserId, timestamp
- **Matches**: user1Id, user2Id, timestamp
- **EarnedPointss**: userId, points, action, timestamp, date
- **Events**: Header, Details, Date, Place
- **Businesses**: name, phone, website, location, categories, rating
- **Forums**: title, createdBy, timestamp

---

## 📱 PENDING FEATURES TO IMPLEMENT

### Core Screens
- ⏳ RegistrationScreen (simplified)
- ⬜ MainNavigationScreen (Bottom tabs)
- ⬜ HomeScreen / DiscoverScreen

### Connection Features
- ⬜ ConnectionsScreen (main hub)
- ⬜ MentorshipConnectionsScreen
- ⬜ NetworkingConnectionsScreen  
- ⬜ RomanticConnectionsScreen
- ⬜ TodaysMatchesScreen
- ⬜ FindMatchesScreen
- ⬜ SpeedMentoringScreen

### Chat Features
- ⬜ ChatListScreen
- ⬜ ChatDetailScreen
- ⬜ DateProposalWidget

### Discover Features
- ⬜ NewsFeedScreen
- ⬜ PostCardWidget
- ⬜ CreatePostScreen

### Search Features
- ⬜ UserSearchScreen (with NEW filters)
- ⬜ UserSearchFiltersSheet

### Events Features  
- ⬜ EventsListScreen
- ⬜ LocalEventsScreen
- ⬜ EventDetailScreen
- ⬜ CalendarScreen

### Business Features
- ⬜ BlackBusinessScreen
- ⬜ BusinessListScreen
- ⬜ BusinessDetailScreen
- ⬜ YelpSearchScreen

### Profile Features
- ⬜ ProfileScreen
- ⬜ EditProfileScreen
- ⬜ ProfilePreviewScreen
- ⬜ PointsScreen
- ⬜ RewardsScreen

### Other Features
- ⬜ ForumsScreen
- ⬜ SeriesScreen
- ⬜ SettingsScreen

---

## 🔧 TECHNICAL IMPLEMENTATION NOTES

### State Management
Using Riverpod for:
- Authentication state
- User profile state
- Chat state
- Connection state
- Search filters state

### Navigation
Using GoRouter for:
- Deep linking support
- Auth-based redirects
- Tab persistence
- Modal routes

### Performance Optimizations
- Lazy loading with ListView.builder
- Image caching with cached_network_image
- Firestore query pagination
- Hive for local caching

### Push Notifications
- FCM token management
- Background message handling
- Local notifications for foreground messages
- Notification navigation handling

---

## 📦 REQUIRED PACKAGES

### Core
- flutter_riverpod: State management
- go_router: Navigation
- firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging

### UI
- cached_network_image: Image caching
- image_picker, image_cropper: Photo selection
- shimmer: Loading states
- lottie: Animations

### Utilities
- intl: Date formatting
- timeago: Relative timestamps
- uuid: ID generation
- email_validator: Email validation

---

## 🚀 NEXT STEPS

1. ✅ Complete simplified RegistrationScreen
2. ⬜ Build main navigation with bottom tabs
3. ⬜ Implement core Connection features
4. ⬜ Build Chat system
5. ⬜ Create Discover/NewsFeed
6. ⬜ Implement enhanced User Search
7. ⬜ Build Events features
8. ⬜ Create Business discovery
9. ⬜ Implement Matching algorithm
10. ⬜ Add Rewards/Points system
11. ⬜ Test and polish UI/UX
12. ⬜ Deploy to App Store & Play Store

---

## 📝 REMOVED FIELDS (From Old Registration)

These fields are NO LONGER collected during registration:
- ❌ Bio
- ❌ Job Title
- ❌ Industry
- ❌ University
- ❌ Major
- ❌ Greek Organization
- ❌ Other Organizations
- ❌ Relationship Status
- ❌ Interests
- ❌ Personality Traits
- ❌ Hobbies

**Note:** These can be added later as optional profile enhancements.

---

## 🎨 BRAND COLORS

- **Deep Purple**: #4A148C
- **Silver Purple**: #9C27B0
- **Electric Orange**: #FF6D00
- **Black**: #000000
- **Dark Background**: #1d1d1e

---

## ✨ KEY IMPROVEMENTS OVER iOS APP

1. **Simplified Onboarding**: 7 steps → 1 step
2. **Better Skill Matching**: Generic skills → 10 categorized skill groups
3. **Enhanced Search**: Name only → Name + Experience + Skills Offering/Seeking
4. **Faster Registration**: ~5 minutes → ~2 minutes
5. **Cross-Platform**: iOS only → iOS + Android + Web

---

## 📞 SUPPORT

For migration questions or issues, refer to:
- iOS codebase: `/workspace/ios-app/`
- Flutter codebase: `/workspace/lib/`
- Firebase Console: [Culture Connection Project]

---

**Last Updated**: 2025-10-17
**Migration Progress**: 35% Complete
**Estimated Completion**: Ongoing development
