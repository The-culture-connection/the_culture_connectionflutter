import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../models/event_rsvp.dart';
import '../models/user_profile.dart';
import '../services/rsvp_service.dart';
import '../widgets/rsvp_user_row.dart';

/// EventDetailScreen - Equivalent to iOS EventDetailView.swift
class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final RSVPService _rsvpService = RSVPService();
  
  List<EventRSVP> _rsvpUsers = [];
  bool _isLoadingRSVPs = false;
  bool _hasRSVPd = false;
  bool _isLoadingRSVP = false;

  @override
  void initState() {
    super.initState();
    _checkRSVPStatus();
    _loadRSVPUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and RSVP button
                _buildHeader(),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Event Details Card
                        _buildEventDetailsCard(),
                        
                        const SizedBox(height: 20),
                        
                        // RSVP Section
                        _buildRSVPSection(),
                        
                        const SizedBox(height: 100), // Space for bottom navigation
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: Color(0xFFFF7E00),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // RSVP Button
          GestureDetector(
            onTap: _handleRSVP,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _hasRSVPd ? Colors.green : const Color(0xFFFF7E00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingRSVP) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      _hasRSVPd ? Icons.check_circle : Icons.person_add,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _hasRSVPd ? "RSVP'd" : 'RSVP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Icon
              Icon(
                Icons.calendar_today,
                color: const Color(0xFFFF7E00),
                size: 32,
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontFamily: 'Matches-StrikeRough',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Source and category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7E00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: const Color(0xFFFF7E00),
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.event.source.displayName,
                                style: const TextStyle(
                                  color: Color(0xFFFF7E00),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.event.category?.toUpperCase() ?? 'EVENT',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.event.isFree ? 'FREE' : (widget.event.price ?? 'N/A'),
                    style: TextStyle(
                      color: widget.event.isFree ? Colors.green : const Color(0xFFFF7E00),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.event.displayDistance != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.event.displayDistance!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Event Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.displayDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.event.isToday) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'TODAY',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else if (widget.event.isTomorrow) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'TOMORROW',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.event.displayLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Organizer
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Color(0xFFFF7E00),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.event.organizer ?? 'Organizer TBD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Description
          if (widget.event.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About This Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.event.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          
          // External Link
          if (widget.event.url != null && widget.event.url!.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openEventUrl(widget.event.url!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'View Event Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRSVPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RSVP Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                "Who's Going",
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${_rsvpUsers.length} RSVPs',
                style: const TextStyle(
                  color: Color(0xFFFF7E00),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // RSVP Users List
        if (_isLoadingRSVPs) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: Color(0xFFFF7E00),
                strokeWidth: 2,
              ),
            ),
          ),
        ] else if (_rsvpUsers.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.people,
                    color: Colors.grey,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No RSVPs Yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to RSVP to this event!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rsvpUsers.length,
            itemBuilder: (context, index) {
              final rsvp = _rsvpUsers[index];
              return RSVPUserRow(
                rsvp: rsvp,
                onTap: () => _showUserProfile(rsvp),
              );
            },
          ),
        ],
      ],
    );
  }

  void _handleRSVP() async {
    setState(() {
      _isLoadingRSVP = true;
    });

    try {
      await _rsvpService.rsvpToEvent(event: widget.event);
      
      // Toggle RSVP status
      setState(() {
        _hasRSVPd = !_hasRSVPd;
      });
      
      // Reload RSVP users
      await _loadRSVPUsers();
      
      if (_hasRSVPd) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully RSVP\'d to event!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RSVP removed from event'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to RSVP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingRSVP = false;
      });
    }
  }

  void _checkRSVPStatus() async {
    try {
      final status = await _rsvpService.getUserRSVPStatus(eventId: widget.event.id);
      setState(() {
        _hasRSVPd = status;
      });
    } catch (e) {
      print('❌ Failed to check RSVP status: $e');
    }
  }

  Future<void> _loadRSVPUsers() async {
    setState(() {
      _isLoadingRSVPs = true;
    });

    try {
      final users = await _rsvpService.getEventRSVPs(eventId: widget.event.id);
      setState(() {
        _rsvpUsers = users;
        _isLoadingRSVPs = false;
      });
    } catch (e) {
      print('❌ Failed to load RSVP users: $e');
      setState(() {
        _isLoadingRSVPs = false;
      });
    }
  }

  void _openEventUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showUserProfile(EventRSVP rsvp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: rsvp.userId,
          userName: rsvp.userName,
        ),
      ),
    );
  }
}

/// User Profile Screen
class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          
          if (_isLoading) ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFF7E00),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_userProfile != null) ...[
            SingleChildScrollView(
              child: Column(
                children: [
                  // Close Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Profile Content
                  _buildProfileContent(),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    color: Colors.grey,
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile Not Found',
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Could not load profile for this user',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Profile Header
          Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFFF7E00).withOpacity(0.2),
                child: _userProfile!.photoURL.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _userProfile!.photoURL,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              _userProfile!.initials,
                              style: const TextStyle(
                                fontFamily: 'Matches-StrikeRough',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7E00),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        _userProfile!.initials,
                        style: const TextStyle(
                          fontFamily: 'Matches-StrikeRough',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7E00),
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Name and details
              Text(
                _userProfile!.fullname,
                style: const TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              if (_userProfile!.jobTitle != 'Not specified') ...[
                const SizedBox(height: 4),
                Text(
                  _userProfile!.jobTitle,
                  style: const TextStyle(
                    color: Color(0xFFFF7E00),
                    fontSize: 16,
                  ),
                ),
              ],
              
              if (_userProfile!.industry != 'Not specified') ...[
                const SizedBox(height: 4),
                Text(
                  _userProfile!.industry,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Profile Details
          _buildProfileSection('About', _userProfile!.bio),
          if (_userProfile!.experienceLevel != 'Not specified')
            _buildProfileSection('Experience Level', _userProfile!.experienceLevel),
          if (_userProfile!.major != 'Not specified')
            _buildProfileSection('Major', _userProfile!.major),
          if (_userProfile!.skills != 'Not specified')
            _buildProfileSection('Skills', _userProfile!.skills),
          if (_userProfile!.interests != 'Not specified')
            _buildProfileSection('Interests', _userProfile!.interests),
          if (_userProfile!.location.isNotEmpty)
            _buildProfileSection('Location', _userProfile!.location),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, String content) {
    if (content.isEmpty || content == 'No Bio' || content == 'Not specified') {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFF7E00),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _loadUserProfile() async {
    try {
      // This would typically fetch from Firestore
      // For now, create a mock profile
      setState(() {
        _userProfile = UserProfile(
          id: widget.userId,
          fullname: widget.userName,
          age: 25,
          bio: 'Passionate about technology and community building.',
          experienceLevel: 'Mid-level',
          greekOrganization: 'Not specified',
          otherOrganizations: 'Not specified',
          industry: 'Technology',
          interests: 'Technology, Community Building',
          jobTitle: 'Software Developer',
          major: 'Computer Science',
          personalityTraits: 'Passionate, Driven',
          skills: 'Flutter, iOS, Web Development',
          photoURL: '',
          connectionPreference: 'Mentor',
          matchByIndustry: true,
          selectedIndustry: '🔧 Technology & Engineering',
          speedMentoring: false,
          minAgeSeeking: 18,
          maxAgeSeeking: 50,
          genderPreferences: 'Everyone',
          networkinggoal: 'Professional Growth',
          personalityTrait: 'Passionate',
          jobLevel: 'Mid-level',
          wantsToImprove: 'Leadership',
          email: 'user@example.com',
          location: 'San Francisco, CA',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
