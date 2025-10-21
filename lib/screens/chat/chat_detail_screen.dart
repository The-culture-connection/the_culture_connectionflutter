import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import '../../models/chat_room.dart';
import '../../models/message.dart';
import '../../models/date_proposal.dart';
import '../../services/chat_service.dart';
import 'other_user_profile_view.dart';

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
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _dateProposalController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isProposeDateViewVisible = false;
  bool _showOtherUserProfile = false;

  @override
  void dispose() {
    _messageController.dispose();
    _dateProposalController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.chatRoom.otherParticipantName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfileView(chatRoom: widget.chatRoom),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              _showDateProposalDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages and Date Proposals
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatRoom.id),
              builder: (context, messageSnapshot) {
                return StreamBuilder<List<DateProposal>>(
                  stream: _chatService.getDateProposals(widget.chatRoom.id),
                  builder: (context, proposalSnapshot) {
                    final messages = messageSnapshot.data ?? [];
                    final proposals = proposalSnapshot.data ?? [];
                    
                    // Combine and sort messages and proposals by timestamp
                    List<dynamic> allItems = [];
                    allItems.addAll(messages);
                    allItems.addAll(proposals);
                    allItems.sort((a, b) {
                      DateTime aTime = a is Message ? a.timestamp : (a as DateProposal).timestamp;
                      DateTime bTime = b is Message ? b.timestamp : (b as DateProposal).timestamp;
                      return aTime.compareTo(bTime);
                    });
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        
                        if (item is Message) {
                          return _buildMessageBubble(item, currentUserId);
                        } else if (item is DateProposal) {
                          return _buildDateProposalCard(item, currentUserId);
                        }
                        
                        return const SizedBox.shrink();
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFFFF7E00)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, String? currentUserId) {
    final isCurrentUser = message.senderId == currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser 
                  ? const Color(0xFFFF7E00).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateProposalCard(DateProposal proposal, String? currentUserId) {
    final isCurrentUser = proposal.proposerId == currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date Proposal",
            style: TextStyle(
              fontFamily: 'Matches-StrikeRough',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Details: ${proposal.details}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Date & Time: ${_formatDateTime(proposal.date)}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Place: ${proposal.place}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Status: ${proposal.status}",
            style: TextStyle(
              fontSize: 14,
              color: proposal.status == "Accepted" 
                  ? Colors.green 
                  : proposal.status == "Declined" 
                      ? Colors.red 
                      : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Action buttons for pending proposals from others
          if (!isCurrentUser && proposal.status == "Pending") ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToProposal(proposal, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToProposal(proposal, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Decline",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _chatService.sendMessage(widget.chatRoom.id, text);
      _messageController.clear();
    }
  }

  void _respondToProposal(DateProposal proposal, bool accept) async {
    await _chatService.respondToDateProposal(widget.chatRoom.id, proposal.id, accept);
    
    if (accept) {
      await _addEventToCalendar(proposal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meeting accepted and added to your calendar!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meeting declined"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _addEventToCalendar(DateProposal proposal) async {
    final status = await Permission.calendar.request();
    if (status.isGranted) {
      try {
        final calendar.Event event = calendar.Event(
          title: 'Meeting with ${widget.chatRoom.otherParticipantName}',
          description: proposal.details,
          location: proposal.place,
          startDate: proposal.date,
          endDate: proposal.date.add(const Duration(hours: 1)), // 1 hour duration
          allDay: false,
          iosParams: const calendar.IOSParams(
            reminder: Duration(minutes: 15),
          ),
          androidParams: const calendar.AndroidParams(
            emailInvites: [],
          ),
        );

        await calendar.Add2Calendar.addEvent2Cal(event);
      } catch (e) {
        print('Error adding to calendar: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error adding to calendar"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Calendar permission denied"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDateProposalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2A2A),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Propose a Date",
              style: const TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateProposalController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Describe your date proposal...",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                "Select Date & Time",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _formatDateTime(_selectedDate),
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () async {
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
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _placeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter a place...",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _dateProposalController.clear();
                      _placeController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _proposeDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7E00),
                    ),
                    child: const Text("Propose"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDateProposalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            "Propose a Date",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateProposalController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Details",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF7E00)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _placeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Place",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF7E00)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    "Date: ",
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(color: Color(0xFFFF7E00)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    "Time: ",
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                      child: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(color: Color(0xFFFF7E00)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _dateProposalController.clear();
                _placeController.clear();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _proposeDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E00),
                ),
                child: const Text("Propose"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proposeDate() async {
    print('_proposeDate called'); // Debug log
    final details = _dateProposalController.text.trim();
    final place = _placeController.text.trim();
    
    print('Details: $details, Place: $place'); // Debug log
    
    if (details.isEmpty || place.isEmpty) {
      print('Validation failed: empty fields'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill in both details and place"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      // Combine date and time
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      print('Calling _chatService.proposeDate...'); // Debug log
      await _chatService.proposeDate(
        widget.chatRoom.id,
        details,
        combinedDateTime,
        place,
      );
      print('_chatService.proposeDate completed successfully'); // Debug log
      
      // Add to proposer's calendar automatically
      final proposal = DateProposal(
        id: '',
        proposerId: _auth.currentUser?.uid ?? '',
        details: details,
        date: combinedDateTime,
        place: place,
        timestamp: DateTime.now(),
        status: 'Pending',
      );
      
      print('Adding to calendar...'); // Debug log
      await _addEventToCalendar(proposal);
      print('Calendar addition completed'); // Debug log
      
      Navigator.pop(context);
      _dateProposalController.clear();
      _placeController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Date proposal sent and added to your calendar!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error proposing date: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error proposing date: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}