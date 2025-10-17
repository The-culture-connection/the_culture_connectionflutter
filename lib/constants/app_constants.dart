/// App-wide constants for Culture Connection
class AppConstants {
  // Experience Levels
  static const List<String> experienceLevels = [
    'Entry-Level',
    'Mid-Level',
    'Senior-Level',
    'Executive',
  ];

  // Gender Options
  static const List<String> genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  // Connection Types
  static const String connectionTypeMentorship = 'Mentorship';
  static const String connectionTypeNetworking = 'Networking';
  static const String connectionTypeRomantic = 'Romantic';
  static const String connectionTypeFriendship = 'Friendship';

  // Post Types
  static const String postTypeGeneral = 'General';
  static const String postTypeEvent = 'Event';
  static const String postTypeJob = 'Job';
  static const String postTypeResource = 'Resource';

  // Date Proposal Status
  static const String proposalStatusPending = 'pending';
  static const String proposalStatusAccepted = 'accepted';
  static const String proposalStatusRejected = 'rejected';

  // Subscription Tiers
  static const String tierFree = 'Free';
  static const String tierPremium = 'Premium';
  static const String tierUnlimited = 'Unlimited';

  // Points Actions
  static const String pointsActionProfileComplete = 'Profile Complete';
  static const String pointsActionDailyLogin = 'Daily Login';
  static const String pointsActionConnection = 'Connection Made';
  static const String pointsActionEventRSVP = 'Event RSVP';
  static const String pointsActionPostCreated = 'Post Created';
  static const String pointsActionMessageSent = 'Message Sent';

  // Points Values
  static const int pointsProfileComplete = 100;
  static const int pointsDailyLogin = 10;
  static const int pointsConnection = 50;
  static const int pointsEventRSVP = 25;
  static const int pointsPostCreated = 30;
  static const int pointsMessageSent = 5;

  // Free Tier Limits
  static const int freeTierDailyConnections = 5;
  static const int freeTierDailyMessages = 20;

  // Premium Tier Limits
  static const int premiumTierDailyConnections = 20;
  static const int premiumTierDailyMessages = 100;

  // App Settings
  static const int maxProfilePhotos = 6;
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 1000;
  static const int maxPostTitleLength = 100;
  static const int maxPostDescriptionLength = 2000;

  // Firestore Collection Names
  static const String collectionProfiles = 'Profiles';
  static const String collectionPosts = 'Posts';
  static const String collectionChatRooms = 'ChatRooms';
  static const String collectionMessages = 'messages';
  static const String collectionDateProposals = 'dateProposals';
  static const String collectionConnects = 'Connects';
  static const String collectionMatches = 'Matches';
  static const String collectionEarnedPoints = 'EarnedPointss';
  static const String collectionEvents = 'Events';
  static const String collectionForums = 'Forums';
  static const String collectionBusinesses = 'Businesses';

  // Firebase Storage Paths
  static const String storageProfilePhotos = 'profile_photos';
  static const String storagePostPhotos = 'post_photos';
  static const String storageEventPhotos = 'event_photos';

  // Age Preferences
  static const List<String> agePreferences = [
    '18-25',
    '26-35',
    '36-45',
    '46-55',
    '56+',
    'Any',
  ];

  // Distance Preferences (in miles)
  static const List<int> distancePreferences = [
    5,
    10,
    25,
    50,
    100,
    500,
  ];
}
