import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../screens/event_detail_screen.dart';
import '../services/rsvp_service.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final RSVPService _rsvpService = RSVPService();
  bool _hasRSVPd = false;
  bool _isLoadingRSVP = false;

  @override
  void initState() {
    super.initState();
    _checkRSVPStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToEventDetail(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(12),
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
            // Header with source icon and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Icon
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFF7E00),
                  size: 24,
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
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
                                  _getSourceIcon(widget.event.source),
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
                        fontSize: 12,
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
            
            const SizedBox(height: 12),
            
            // Event Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.displayDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.event.displayLocation,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Organizer
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.organizer ?? 'Organizer TBD',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Description
            if (widget.event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.event.description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                // RSVP Button
                Expanded(
                  child: _buildActionButton(
                    text: _hasRSVPd ? "RSVP'd" : 'RSVP',
                    onTap: _handleRSVP,
                    backgroundColor: _hasRSVPd ? Colors.green : const Color(0xFFFF7E00),
                    isLoading: _isLoadingRSVP,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Calendar Preview Button
                Expanded(
                  child: _buildActionButton(
                    text: 'Preview',
                    onTap: _showCalendarPreview,
                    backgroundColor: const Color(0xFF7E7BEF),
                  ),
                ),
                
                if (widget.event.url != null && widget.event.url!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  
                  // View Event Button
                  Expanded(
                    child: _buildActionButton(
                      text: 'VIEW EVENT',
                      onTap: () => _openEventUrl(widget.event.url!),
                      backgroundColor: const Color(0xFFFF7E00),
                    ),
                  ),
                ],
              ],
            ),
            
            // Date indicators
            if (widget.event.isToday || widget.event.isTomorrow) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.event.isToday) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else if (widget.event.isTomorrow) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TOMORROW',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required Color backgroundColor,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ] else ...[
              Icon(
                _getButtonIcon(text),
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSourceIcon(EventSource source) {
    switch (source) {
      case EventSource.ticketmaster:
        return Icons.calendar_today;
    }
  }

  IconData _getButtonIcon(String text) {
    switch (text) {
      case 'RSVP':
        return Icons.person_add;
      case "RSVP'd":
        return Icons.check_circle;
      case 'Preview':
        return Icons.calendar_today;
      case 'VIEW EVENT':
        return Icons.link;
      default:
        return Icons.info;
    }
  }

  void _navigateToEventDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: widget.event),
      ),
    );
  }

  void _handleRSVP() async {
    if (mounted) {
      setState(() {
        _isLoadingRSVP = true;
      });
    }

    try {
      await _rsvpService.rsvpToEvent(event: widget.event);
      if (mounted) {
        setState(() {
          _hasRSVPd = !_hasRSVPd;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasRSVPd ? 'Successfully RSVP\'d to event!' : 'RSVP removed from event'),
          backgroundColor: _hasRSVPd ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to RSVP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRSVP = false;
        });
      }
    }
  }

  void _checkRSVPStatus() async {
    try {
      final status = await _rsvpService.getUserRSVPStatus(eventId: widget.event.id);
      if (mounted) {
        setState(() {
          _hasRSVPd = status;
        });
      }
    } catch (e) {
      print('❌ Failed to check RSVP status: $e');
    }
  }

  void _showCalendarPreview() {
    final preview = _rsvpService.getCalendarPreview(event: widget.event);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1d1d1e),
        title: const Text(
          'Calendar Preview',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${preview.title}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${preview.formattedDateRange}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${preview.location}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${preview.duration}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rsvpService.addEventToCalendar(event: widget.event);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7E00),
            ),
            child: const Text('Add to Calendar'),
          ),
        ],
      ),
    );
  }

  void _openEventUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}