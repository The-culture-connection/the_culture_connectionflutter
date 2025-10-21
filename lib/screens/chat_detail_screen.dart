import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/date_proposal.dart';
import 'other_user_profile_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _dateProposalController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  List<Message> _messages = [];
  List<DateProposal> _dateProposals = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  bool _showDateProposalSheet = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _fetchDateProposals();
    _syncPendingCalendarEvents();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _dateProposalController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.chatRoom.otherParticipantName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(chatRoom: widget.chatRoom),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              setState(() {
                _showDateProposalSheet = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages and Date Proposals
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF7E00),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + _dateProposals.length,
                        itemBuilder: (context, index) {
                          if (index < _messages.length) {
                            return _buildMessageBubble(_messages[index]);
                          } else {
                            final proposalIndex = index - _messages.length;
                            return _buildDateProposalCard(_dateProposals[proposalIndex]);
                          }
                        },
                      ),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
      bottomSheet: _showDateProposalSheet ? _buildDateProposalSheet() : null,
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = message.senderId == _auth.currentUser?.uid;
    
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser 
              ? const Color(0xFFFF7E00).withOpacity(0.8)
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildDateProposalCard(DateProposal proposal) {
    final isCurrentUser = proposal.proposerId == _auth.currentUser?.uid;
    final canRespond = !isCurrentUser && proposal.status == 'Pending';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.yellow.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Proposal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Details: ${proposal.details}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date & Time: ${_formatDateTime(proposal.date)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Place: ${proposal.place}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${proposal.status}',
            style: TextStyle(
              fontSize: 14,
              color: proposal.status == 'Accepted' 
                  ? Colors.green 
                  : proposal.status == 'Declined' 
                      ? Colors.red 
                      : Colors.blue,
              fontFamily: 'Inter',
            ),
          ),
          if (canRespond) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToProposal(proposal, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToProposal(proposal, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Color(0xFF404040), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                filled: true,
                fillColor: Color(0xFF404040),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Color(0xFFFF7E00)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateProposalSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Propose a Date',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _dateProposalController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.grey),
              hintText: 'What would you like to do?',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFF404040),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text(
              'Select Date & Time',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _formatDateTime(_selectedDate),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.calendar_today, color: Color(0xFFFF7E00)),
            onTap: _selectDateTime,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _placeController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Place',
              labelStyle: TextStyle(color: Colors.grey),
              hintText: 'Where would you like to meet?',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFF404040),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDateProposalSheet = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _proposeDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Propose'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetchMessages() async {
    try {
      _db
          .collection('ChatRooms')
          .doc(widget.chatRoom.id)
          .collection('Messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _messages = snapshot.docs.map((doc) {
              final data = doc.data();
              return Message(
                id: doc.id,
                senderId: data['senderId'] ?? '',
                text: data['text'] ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }).toList();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDateProposals() async {
    try {
      _db
          .collection('ChatRooms')
          .doc(widget.chatRoom.id)
          .collection('DateProposals')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _dateProposals = snapshot.docs.map((doc) {
              final data = doc.data();
              final otherParticipantId = widget.chatRoom.participants
                  .firstWhere((id) => id != _auth.currentUser?.uid);
              return DateProposal(
                id: doc.id,
                proposerId: data['proposerId'] ?? '',
                details: data['details'] ?? '',
                date: (data['date'] as Timestamp).toDate(),
                place: data['place'] ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                status: data['status'] ?? 'Pending',
              );
            }).toList();
          });
        }
      });
    } catch (e) {
      print('Error fetching date proposals: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final timestamp = Timestamp.now();
      final messageData = {
        'senderId': currentUserId,
        'text': _messageController.text.trim(),
        'timestamp': timestamp,
      };

      await _db
          .collection('ChatRooms')
          .doc(widget.chatRoom.id)
          .collection('Messages')
          .add(messageData);

      // Update chat room with last message
      await _db.collection('ChatRooms').doc(widget.chatRoom.id).update({
        'lastMessage': _messageController.text.trim(),
        'lastMessageTimestamp': timestamp,
        'lastMessageSenderId': currentUserId,
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _proposeDate() async {
    if (_dateProposalController.text.trim().isEmpty || _placeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final proposalData = {
        'proposerId': currentUserId,
        'details': _dateProposalController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'place': _placeController.text.trim(),
        'timestamp': Timestamp.now(),
        'status': 'Pending',
      };

      await _db
          .collection('ChatRooms')
          .doc(widget.chatRoom.id)
          .collection('DateProposals')
          .add(proposalData);

      // Add to proposer's calendar
      await _addProposedDateToCalendar(proposalData);

      setState(() {
        _showDateProposalSheet = false;
        _dateProposalController.clear();
        _placeController.clear();
        _selectedDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date proposal sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error proposing date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _respondToProposal(DateProposal proposal, bool accept) async {
    try {
      final newStatus = accept ? 'Accepted' : 'Declined';
      
      await _db
          .collection('ChatRooms')
          .doc(widget.chatRoom.id)
          .collection('DateProposals')
          .doc(proposal.id)
          .update({'status': newStatus});

      if (accept) {
        await _addAcceptedProposalToCalendar(proposal);
        await _storeAcceptedProposalForOtherUser(proposal);
        await _addAcceptedProposalToProposerCalendar(proposal);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Date proposal $newStatus'),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('Error responding to proposal: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _addProposedDateToCalendar(Map<String, dynamic> proposalData) async {
    // Request calendar permission
    final status = await Permission.calendar.request();
    if (!status.isGranted) {
      _showCalendarPermissionAlert();
      return;
    }

    // Get other participant's name
    final otherParticipantId = widget.chatRoom.participants
        .firstWhere((id) => id != _auth.currentUser?.uid);
    
    try {
      final otherUserDoc = await _db.collection('Profiles').doc(otherParticipantId).get();
      final otherUserName = otherUserDoc.data()?['Full Name'] ?? 'Unknown';

      // Create calendar event
      final eventTitle = 'Date Proposal with $otherUserName';
      final eventDescription = 'Proposed: ${proposalData['details']}\n\nStatus: Pending Response';
      
      await _createCalendarEvent(
        title: eventTitle,
        description: eventDescription,
        date: (proposalData['date'] as Timestamp).toDate(),
        location: proposalData['place'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date proposal added to your calendar'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding to calendar: $e');
    }
  }

  Future<void> _addAcceptedProposalToCalendar(DateProposal proposal) async {
    final status = await Permission.calendar.request();
    if (!status.isGranted) {
      _showCalendarPermissionAlert();
      return;
    }

    try {
      final otherParticipantId = widget.chatRoom.participants
          .firstWhere((id) => id != _auth.currentUser?.uid);
      
      final otherUserDoc = await _db.collection('Profiles').doc(otherParticipantId).get();
      final otherUserName = otherUserDoc.data()?['Full Name'] ?? 'Unknown';

      await _createCalendarEvent(
        title: 'Meeting with $otherUserName',
        description: proposal.details,
        date: proposal.date,
        location: proposal.place,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accepted date added to your calendar'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding accepted proposal to calendar: $e');
    }
  }

  Future<void> _storeAcceptedProposalForOtherUser(DateProposal proposal) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final otherParticipantId = widget.chatRoom.participants
        .firstWhere((id) => id != currentUserId);

    try {
      final currentUserDoc = await _db.collection('Profiles').doc(currentUserId).get();
      final currentUserName = currentUserDoc.data()?['Full Name'] ?? 'Unknown';

      final acceptedProposalData = {
        'proposalId': proposal.id,
        'chatRoomId': widget.chatRoom.id,
        'title': 'Meeting with $currentUserName',
        'date': Timestamp.fromDate(proposal.date),
        'place': proposal.place,
        'details': proposal.details,
        'acceptedAt': Timestamp.now(),
        'needsCalendarSync': true,
      };

      await _db
          .collection('Profiles')
          .doc(otherParticipantId)
          .collection('AcceptedProposals')
          .doc(proposal.id)
          .set(acceptedProposalData);
    } catch (e) {
      print('Error storing accepted proposal for other user: $e');
    }
  }

  Future<void> _addAcceptedProposalToProposerCalendar(DateProposal proposal) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final proposerId = widget.chatRoom.participants
        .firstWhere((id) => id != currentUserId);

    try {
      final currentUserDoc = await _db.collection('Profiles').doc(currentUserId).get();
      final currentUserName = currentUserDoc.data()?['Full Name'] ?? 'Unknown';

      final acceptedProposalData = {
        'proposalId': proposal.id,
        'chatRoomId': widget.chatRoom.id,
        'title': 'Meeting with $currentUserName',
        'date': Timestamp.fromDate(proposal.date),
        'place': proposal.place,
        'details': proposal.details,
        'acceptedAt': Timestamp.now(),
        'needsCalendarSync': true,
      };

      await _db
          .collection('Profiles')
          .doc(proposerId)
          .collection('AcceptedProposals')
          .doc(proposal.id)
          .set(acceptedProposalData);
    } catch (e) {
      print('Error storing accepted proposal for proposer: $e');
    }
  }

  Future<void> _syncPendingCalendarEvents() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final snapshot = await _db
          .collection('Profiles')
          .doc(currentUserId)
          .collection('AcceptedProposals')
          .where('needsCalendarSync', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title'] as String?;
        final date = (data['date'] as Timestamp?)?.toDate();
        final place = data['place'] as String?;
        final details = data['details'] as String?;

        if (title != null && date != null && place != null && details != null) {
          await _createCalendarEvent(
            title: title,
            description: details,
            date: date,
            location: place,
          );

          // Mark as synced
          await doc.reference.update({'needsCalendarSync': false});
        }
      }
    } catch (e) {
      print('Error syncing pending calendar events: $e');
    }
  }

  Future<void> _createCalendarEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
  }) async {
    try {
      final calendar.Event calendarEvent = calendar.Event(
        title: title,
        description: description,
        location: location,
        startDate: date,
        endDate: date.add(const Duration(hours: 1)),
        allDay: false,
        iosParams: const calendar.IOSParams(
          reminder: Duration(minutes: 15),
        ),
        androidParams: const calendar.AndroidParams(
          emailInvites: [],
        ),
      );

      await calendar.Add2Calendar.addEvent2Cal(calendarEvent);
      print('✅ Calendar event created: $title at $date');
    } catch (e) {
      print('❌ Error creating calendar event: $e');
    }
  }

  void _showCalendarPermissionAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Permission Required'),
        content: const Text(
          'Calendar access is required to add date proposals to your calendar. Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
