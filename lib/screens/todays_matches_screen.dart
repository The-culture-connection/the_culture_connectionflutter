import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/match.dart';
import '../services/rsvp_service.dart';

/// Today's Matches Screen - Equivalent to iOS TodaysMatchesView.swift
class TodaysMatchesScreen extends StatefulWidget {
  const TodaysMatchesScreen({super.key});

  @override
  State<TodaysMatchesScreen> createState() => _TodaysMatchesScreenState();
}

class _TodaysMatchesScreenState extends State<TodaysMatchesScreen> {
  UserMatch? _currentUser;
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RSVPService _rsvpService = RSVPService();

  @override
  void initState() {
    super.initState();
    _loadUserMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1E),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/EventImage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_matches.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildMatchesList();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7E00)),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading today's matches...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter-VariableFont_slnt,wght',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Color(0xFFFF7E00),
            ),
            const SizedBox(height: 20),
            Text(
              "Error Loading Matches",
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'Inter-VariableFont_slnt,wght',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserMatches,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7E00),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 50,
              color: Color(0xFFFF7E00),
            ),
            const SizedBox(height: 20),
            Text(
              "No Matches Found",
              style: TextStyle(
                fontFamily: 'Matches-StrikeRough',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Fill out your profile more completely to view matches",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'Inter-VariableFont_slnt,wght',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and Logo row
              Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Logo
                  Image.asset(
                    'assets/CC_PrimaryLogo_SilverPurple.png',
                    height: 60,
                    width: 120,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // Title
              Text(
                "Your Matches",
                style: TextStyle(
                  fontFamily: 'Matches-StrikeRough',
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // User greeting
              if (_currentUser != null)
                Text(
                  "Hello, ${_currentUser!.userName}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                  ),
                ),
            ],
          ),
        ),
        
        // Matches List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              return _buildMatchCard(match, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(Match match, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
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
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "#$rank",
                          style: TextStyle(
                            fontFamily: 'Matches-StrikeRough',
                            fontSize: 16,
                            color: const Color(0xFFFF7E00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            match.matchName,
                            style: TextStyle(
                              fontFamily: 'Matches-StrikeRough',
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (match.industry != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        match.industry!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Inter-VariableFont_slnt,wght',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Compatibility Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Compatibility",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Inter-VariableFont_slnt,wght',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(match.score * 100).toInt()}%",
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 18,
                      color: const Color(0xFFFF7E00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Why this match
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Why this match:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.why,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Inter-VariableFont_slnt,wght',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleConnectAction(match),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CONNECT',
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handlePassAction(match),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF7E00)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'PASS',
                    style: TextStyle(
                      fontFamily: 'Matches-StrikeRough',
                      fontSize: 16,
                      color: const Color(0xFFFF7E00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 Fetching matches for current user: $currentUserId');

      // Try to fetch from UserMatches collection first (new advanced matching)
      final userMatchDoc = await _db.collection("UserMatches").doc(currentUserId).get();
      
      if (userMatchDoc.exists) {
        final userMatch = UserMatch.fromMap(userMatchDoc.data()!);
        setState(() {
          _currentUser = userMatch;
          _matches = userMatch.matches;
          _isLoading = false;
        });
        print('✅ Fetched ${userMatch.matches.length} matches from UserMatches');
        return;
      }

      // Fallback to SkillMatches collection (old matching algorithm)
      final skillMatchDoc = await _db.collection("SkillMatches").doc(currentUserId).get();
      
      if (skillMatchDoc.exists) {
        final data = skillMatchDoc.data()!;
        final matchesData = data['matches'] as List<dynamic>? ?? [];
        final matches = matchesData
            .map((matchData) => Match.fromMap(matchData as Map<String, dynamic>))
            .toList();

        final userMatch = UserMatch(
          userId: currentUserId,
          userName: data['fullName'] ?? 'Unknown User',
          matches: matches,
          runAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );

        setState(() {
          _currentUser = userMatch;
          _matches = matches;
          _isLoading = false;
        });
        print('✅ Fetched ${matches.length} matches from SkillMatches');
        return;
      }

      // No matches found
      setState(() {
        _matches = [];
        _isLoading = false;
      });
      print('📭 No matches found for current user');

    } catch (e) {
      print('❌ Error loading matches: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConnectAction(Match match) async {
    try {
      final result = await _rsvpService.sendConnectionRequest(userId: match.matchId);
      
      if (mounted) {
        if (result['success'] == true) {
          if (result['isMatch'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 It\'s a Match! You are now connected!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection request sent!'),
                backgroundColor: Color(0xFFFF7E00),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: ${result['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePassAction(Match match) async {
    try {
      final currentUserId = _auth.currentUser!.uid;
      await _db.collection('UserActions').doc(currentUserId).set({
        'passedUsers': FieldValue.arrayUnion([match.matchId])
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User passed'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      print('Error recording pass: $e');
    }
  }
}