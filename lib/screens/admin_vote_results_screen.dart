import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../constants/app_colors.dart';

class AdminVoteResultsScreen extends StatefulWidget {
  const AdminVoteResultsScreen({super.key});

  @override
  State<AdminVoteResultsScreen> createState() => _AdminVoteResultsScreenState();
}

class _AdminVoteResultsScreenState extends State<AdminVoteResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  Map<String, dynamic> _results = {};
  String? _winner;
  int _totalVotes = 0;
  bool _isLoading = true;
  String? _error;
  
  final List<String> _options = [
    'Alpha Phi Alpha Fraternity, Inc.',
    'Kappa Alpha Psi Fraternity, Inc.',
    'Omega Psi Phi Fraternity, Inc.',
    'Phi Beta Sigma Fraternity, Inc.',
    'Iota Phi Theta Fraternity, Inc.',
    'Alpha Kappa Alpha Sorority, Inc.',
    'Delta Sigma Theta Sorority, Inc.',
    'Zeta Phi Beta Sorority, Inc.',
    'Sigma Gamma Rho Sorority, Inc.',
  ];

  @override
  void initState() {
    super.initState();
    _getVoteResults();
  }

  Future<void> _getVoteResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Call the Cloud Function to get vote results
      final callable = _functions.httpsCallable('countVotesAndGetWinner');
      final result = await callable.call();
      
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        setState(() {
          _results = data['results'] ?? {};
          _winner = data['winner']?['option'];
          _totalVotes = data['totalVotes'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to get results';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error calling function: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getDailyResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Call the Cloud Function to get daily vote results
      final callable = _functions.httpsCallable('getDailyVoteSummary');
      final result = await callable.call({'date': todayString});
      
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        setState(() {
          _results = data['results'] ?? {};
          _winner = data['winner']?['option'];
          _totalVotes = data['totalVotes'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to get daily results';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error calling function: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vote Results',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _getVoteResults,
            tooltip: 'Refresh All Results',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.electricOrange,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getVoteResults,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.deepPurple, AppColors.electricOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Live Contest Results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Votes: $_totalVotes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                              ),
                            ),
                            if (_winner != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      color: Colors.yellow,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Winner: $_winner',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _getVoteResults,
                              icon: const Icon(Icons.analytics, color: Colors.white),
                              label: const Text(
                                'All Results',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _getDailyResults,
                              icon: const Icon(Icons.today, color: Colors.white),
                              label: const Text(
                                'Today Only',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.electricOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Results List
                      ..._buildResultsList(),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildResultsList() {
    if (_results.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1d1d1e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.deepPurple.withOpacity(0.3)),
          ),
          child: const Center(
            child: Text(
              'No votes yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ];
    }

    // Sort options by vote count (descending)
    final sortedOptions = _options.toList()
      ..sort((a, b) {
        final aVotes = _results[a]?['votes'] ?? 0;
        final bVotes = _results[b]?['votes'] ?? 0;
        return bVotes.compareTo(aVotes);
      });

    return sortedOptions.map((option) {
      final result = _results[option];
      final votes = result?['votes'] ?? 0;
      final percentage = result?['percentage'] ?? 0.0;
      final isWinner = option == _winner;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isWinner 
              ? AppColors.electricOrange.withOpacity(0.1)
              : const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinner 
                ? AppColors.electricOrange 
                : AppColors.deepPurple.withOpacity(0.3),
            width: isWinner ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isWinner) ...[
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.electricOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Text(
                  '$votes votes',
                  style: TextStyle(
                    color: isWinner ? AppColors.electricOrange : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _totalVotes > 0 ? votes / _totalVotes : 0,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isWinner ? AppColors.electricOrange : AppColors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isWinner ? AppColors.electricOrange : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

