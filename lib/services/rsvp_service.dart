import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import '../models/event.dart';
import '../models/event_rsvp.dart';
import '../models/user_profile.dart';

/// RSVPService - Equivalent to iOS RSVPService.swift
class RSVPService {
  static final RSVPService _instance = RSVPService._internal();
  factory RSVPService() => _instance;
  RSVPService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  bool _showingCalendarPermissionAlert = false;
  bool _showingCalendarSuccessAlert = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showingCalendarPermissionAlert => _showingCalendarPermissionAlert;
  bool get showingCalendarSuccessAlert => _showingCalendarSuccessAlert;

  /// RSVP to an event
  Future<void> rsvpToEvent({required Event event}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;
    _errorMessage = null;

    try {
      // Check if user already RSVP'd to this event
      final existingRSVP = await _checkExistingRSVP(eventId: event.id, userId: currentUser.uid);

      if (existingRSVP != null) {
        // User already RSVP'd, so remove them (toggle off)
        await _removeUserFromRSVP(event: event);
        print('✅ Successfully removed RSVP from event: ${event.title}');
      } else {
        // User hasn't RSVP'd, so add them
        await _createNewRSVP(event: event, userId: currentUser.uid);
        print('✅ Successfully RSVP\'d to event: ${event.title}');
        
        // Add event to calendar
        await addEventToCalendar(event: event);
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ RSVP failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Check if user has RSVP'd to an event
  Future<bool> getUserRSVPStatus({required String eventId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final query = _db.collection('RSVP EVENTS')
          .where('eventId', isEqualTo: eventId)
          .where('rsvpUsers', arrayContains: currentUser.uid)
          .limit(1);

      final snapshot = await query.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Failed to check RSVP status: $e');
      return false;
    }
  }

  /// Get all RSVPs for an event
  Future<List<EventRSVP>> getEventRSVPs({required String eventId}) async {
    try {
      final query = _db.collection('RSVP EVENTS')
          .where('eventId', isEqualTo: eventId)
          .limit(50);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EventRSVP.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('❌ Failed to load RSVP users: $e');
      return [];
    }
  }

  /// Send connection request to a user using Firebase function
  Future<Map<String, dynamic>> sendConnectionRequest({required String userId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔗 Sending connection request to user: $userId');
      
      // Call Firebase function
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('handleUserConnection');
      
      final result = await callable.call({
        'fromUserId': currentUser.uid,
        'toUserId': userId,
        'connectionRequestId': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        if (data['isMatch'] == true) {
          print('🎉 Match created! You and the other user are now connected!');
        } else {
          print('✅ Connection request sent successfully');
        }
      }

      return data;
    } catch (e) {
      print('❌ Connection request failed: $e');
      rethrow;
    }
  }

  /// Check connection status with a user
  Future<ConnectionStatus> checkConnectionStatus({required String userId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if already connected
      final userActionsDoc = await _db.collection('UserActions').doc(currentUser.uid).get();
      if (userActionsDoc.exists) {
        final data = userActionsDoc.data();
        final connectedUsers = List<String>.from(data?['connectedUsers'] ?? []);
        if (connectedUsers.contains(userId)) {
          return ConnectionStatus.connected;
        }
      }

      // Check if connection request sent
      final connectsQuery = _db.collection('Connects')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: userId);

      final connectsSnapshot = await connectsQuery.get();
      if (connectsSnapshot.docs.isNotEmpty) {
        return ConnectionStatus.requestSent;
      }

      // Check if connection request received
      final receivedQuery = _db.collection('Connects')
          .where('fromUserId', isEqualTo: userId)
          .where('toUserId', isEqualTo: currentUser.uid);

      final receivedSnapshot = await receivedQuery.get();
      if (receivedSnapshot.docs.isNotEmpty) {
        return ConnectionStatus.requestReceived;
      }

      return ConnectionStatus.none;
    } catch (e) {
      print('❌ Failed to check connection status: $e');
      return ConnectionStatus.none;
    }
  }

  /// Add event to calendar
  Future<void> addEventToCalendar({required Event event}) async {
    try {
      // Check calendar permission
      final status = await Permission.calendar.status;
      if (status.isDenied) {
        final result = await Permission.calendar.request();
        if (result.isDenied) {
          _showingCalendarPermissionAlert = true;
          return;
        }
      }

      // Use add_2_calendar package for native calendar integration
      final calendar.Event calendarEvent = calendar.Event(
        title: event.title,
        description: event.details,
        location: event.place,
        startDate: event.date,
        endDate: event.date.add(const Duration(hours: 2)),
        allDay: false,
        iosParams: const calendar.IOSParams(
          reminder: Duration(minutes: 15),
        ),
        androidParams: const calendar.AndroidParams(
          emailInvites: [],
        ),
      );

      await calendar.Add2Calendar.addEvent2Cal(calendarEvent);
      _showingCalendarSuccessAlert = true;
      print('✅ Calendar event created successfully: ${event.title}');
    } catch (e) {
      print('❌ Error creating calendar event: $e');
    }
  }

  /// Get calendar preview for an event
  CalendarEventPreview getCalendarPreview({required Event event}) {
    return CalendarEventPreview(
      title: event.title,
      startDate: event.date,
      endDate: event.date.add(const Duration(hours: 2)),
      location: event.place,
      description: event.details,
    );
  }

  // MARK: - Private Methods

  Future<EventRSVP?> _checkExistingRSVP({required String eventId, required String userId}) async {
    try {
      final query = _db.collection('RSVP EVENTS')
          .where('eventId', isEqualTo: eventId)
          .where('rsvpUsers', arrayContains: userId)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return EventRSVP.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      print('❌ Failed to check existing RSVP: $e');
      return null;
    }
  }

  Future<void> _createNewRSVP({required Event event, required String userId}) async {
    try {
      // Get user profile to get the display name
      final userProfile = await _getUserProfile(userId: userId);
      final userName = userProfile?.displayName ?? 'Anonymous User';

      final rsvpData = {
        'eventId': event.id,
        'eventTitle': event.title,
        'eventDescription': event.details,
        'eventStartDate': event.date,
        'eventEndDate': event.date.add(const Duration(hours: 2)),
        'eventLocation': event.place,
        'eventAddress': event.place,
        'eventLatitude': 0.0,
        'eventLongitude': 0.0,
        'eventOrganizer': event.organizer ?? 'Unknown',
        'eventCategory': event.category ?? 'Event',
        'eventSource': event.source.name,
        'eventUrl': event.url ?? '',
        'eventImageURL': '',
        'eventIsFree': event.isFree,
        'eventPrice': event.price ?? '',
        'rsvpUsers': [userId],
        'rsvpCount': 1,
        'userName': userName,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('RSVP EVENTS').add(rsvpData);
      print('✅ Created new RSVP document for event: ${event.title}');
    } catch (e) {
      print('❌ Failed to create new RSVP: $e');
      rethrow;
    }
  }

  Future<void> _removeUserFromRSVP({required Event event}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final query = _db.collection('RSVP EVENTS')
          .where('eventId', isEqualTo: event.id)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        throw Exception('RSVP document not found');
      }

      final doc = snapshot.docs.first;
      final currentData = doc.data();
      final rsvpUsers = List<String>.from(currentData['rsvpUsers'] ?? []);

      // Remove user from RSVP list
      rsvpUsers.removeWhere((id) => id == currentUser.uid);

      final updateData = {
        'rsvpUsers': rsvpUsers,
        'rsvpCount': rsvpUsers.length,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await doc.reference.update(updateData);
      print('✅ Removed user from RSVP for event: ${event.title}');
    } catch (e) {
      print('❌ Failed to remove user from RSVP: $e');
      rethrow;
    }
  }

  Future<UserProfile?> _getUserProfile({required String userId}) async {
    try {
      final doc = await _db.collection('Profiles').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Failed to get user profile: $e');
      return null;
    }
  }

  Future<void> _checkForMutualLike({
    required String fromUserId,
    required String toUserId,
    required String connectionRequestId,
  }) async {
    try {
      final query = _db.collection('Connects')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: fromUserId);

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        print('✅ Mutual like detected between $fromUserId and $toUserId');
        await _createMatch(
          user1Id: fromUserId,
          user2Id: toUserId,
          connectionRequestId: connectionRequestId,
        );
      }
    } catch (e) {
      print('❌ Failed to check for mutual like: $e');
    }
  }

  Future<void> _createMatch({
    required String user1Id,
    required String user2Id,
    required String connectionRequestId,
  }) async {
    try {
      // Create match document
      final matchData = {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final matchRef = await _db.collection('Matches').add(matchData);
      print('✅ Match created successfully between $user1Id and $user2Id');
      print('✅ Match document ID: ${matchRef.id}');
      print('✅ Match document path: Matches/${matchRef.id}');
      print('✅ This should trigger notifyOnNewMatch function');

      // Create chat room
      await _createChatRoom(user1Id: user1Id, user2Id: user2Id);
    } catch (e) {
      print('❌ Failed to create match: $e');
    }
  }

  Future<void> _createChatRoom({required String user1Id, required String user2Id}) async {
    try {
      // Ensure consistent ordering of participants
      final participants = [user1Id, user2Id]..sort();

      // Check if chat room already exists
      final query = _db.collection('ChatRooms')
          .where('participants', isEqualTo: participants);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        // Create new chat room
        final chatRoomData = {
          'participants': participants,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        };

        await _db.collection('ChatRooms').add(chatRoomData);
        print('✅ Chat room created successfully between $user1Id and $user2Id');
      } else {
        print('ℹ️ Chat room already exists between $user1Id and $user2Id');
      }
    } catch (e) {
      print('❌ Failed to create chat room: $e');
    }
  }
}

/// Calendar Event Preview Model
class CalendarEventPreview {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String description;

  CalendarEventPreview({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.description,
  });

  String get formattedDateRange {
    final formatter = DateFormat('MMM d, y • h:mm a');
    final startFormatted = formatter.format(startDate);
    final endFormatted = formatter.format(endDate);

    if (startDate.day == endDate.day) {
      // Same day - show date once with both times
      final dateFormatter = DateFormat('MMM d, y');
      final dateString = dateFormatter.format(startDate);
      
      final timeFormatter = DateFormat('h:mm a');
      final startTime = timeFormatter.format(startDate);
      final endTime = timeFormatter.format(endDate);
      
      return '$dateString • $startTime - $endTime';
    } else {
      // Different days
      return '$startFormatted - $endFormatted';
    }
  }

  String get duration {
    final duration = endDate.difference(startDate);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

/// Connection Status Enum
enum ConnectionStatus {
  none,
  requestSent,
  requestReceived,
  connected;

  String get displayText {
    switch (this) {
      case ConnectionStatus.none:
        return 'Connect';
      case ConnectionStatus.requestSent:
        return 'Request Sent';
      case ConnectionStatus.requestReceived:
        return 'Accept Request';
      case ConnectionStatus.connected:
        return 'Connected';
    }
  }

  String get buttonColor {
    switch (this) {
      case ConnectionStatus.none:
        return '#FF7E00';
      case ConnectionStatus.requestSent:
        return '#FFA500';
      case ConnectionStatus.requestReceived:
        return '#32CD32';
      case ConnectionStatus.connected:
        return '#808080';
    }
  }
}
