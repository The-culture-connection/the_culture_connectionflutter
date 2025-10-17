import 'package:flutter/material.dart';
import '../models/event_rsvp.dart';
import '../services/rsvp_service.dart';

/// RSVPUserRow widget - Equivalent to iOS RSVPUserRow.swift
class RSVPUserRow extends StatefulWidget {
  final EventRSVP rsvp;
  final VoidCallback? onTap;

  const RSVPUserRow({
    super.key,
    required this.rsvp,
    this.onTap,
  });

  @override
  State<RSVPUserRow> createState() => _RSVPUserRowState();
}

class _RSVPUserRowState extends State<RSVPUserRow> {
  final RSVPService _rsvpService = RSVPService();
  ConnectionStatus _connectionStatus = ConnectionStatus.none;
  bool _isLoadingConnection = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7E00).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFFF7E00).withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Color(0xFFFF7E00),
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.rsvp.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.rsvp.timeAgoDisplay,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'via ${widget.rsvp.eventSource}',
                        style: const TextStyle(
                          color: Color(0xFFFF7E00),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Connect Button
            GestureDetector(
              onTap: _handleConnectionAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse(_connectionStatus.buttonColor.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoadingConnection) ...[
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
                        _connectionStatus == ConnectionStatus.connected
                            ? Icons.check_circle
                            : Icons.person_add,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _connectionStatus.displayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConnectionAction() async {
    if (_connectionStatus == ConnectionStatus.connected || _isLoadingConnection) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingConnection = true;
      });
    }

    try {
      if (_connectionStatus == ConnectionStatus.requestReceived) {
        // Accept the connection request
        await _rsvpService.sendConnectionRequest(userId: widget.rsvp.userId);
        if (mounted) {
          setState(() {
            _connectionStatus = ConnectionStatus.connected;
          });
        }
      } else {
        // Send connection request
        await _rsvpService.sendConnectionRequest(userId: widget.rsvp.userId);
        if (mounted) {
          setState(() {
            _connectionStatus = ConnectionStatus.requestSent;
          });
        }
      }
    } catch (e) {
      print('❌ Connection action failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingConnection = false;
        });
      }
    }
  }

  void _checkConnectionStatus() async {
    try {
      final status = await _rsvpService.checkConnectionStatus(userId: widget.rsvp.userId);
      if (mounted) {
        setState(() {
          _connectionStatus = status;
        });
      }
    } catch (e) {
      print('❌ Failed to check connection status: $e');
    }
  }
}
