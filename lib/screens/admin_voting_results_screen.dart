import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

class AdminVotingResultsScreen extends StatefulWidget {
  const AdminVotingResultsScreen({super.key});

  @override
  State<AdminVotingResultsScreen> createState() => _AdminVotingResultsScreenState();
}

class _AdminVotingResultsScreenState extends State<AdminVotingResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, int> _voteCounts = {};
  int _totalVotes = 0;
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _subscription;
  
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
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _subscription = _firestore
        .collection('Voting Results')
        .doc('mWrN1YfAxB27hml50hyX')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final counts = <String, int>{};
        
        for (String option in _options) {
          counts[option] = (data[option] ?? 0) as int;
        }
        
        // Calculate total votes from all options
        final total = counts.values.fold(0, (sum, count) => sum + count);
        
        if (mounted) {
          setState(() {
            _voteCounts = counts;
            _totalVotes = total;
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _exportResults() async {
    try {
      // Get all user votes for detailed analysis
      final userVotesSnapshot = await _firestore
          .collection('voting')
          .doc('live_contest')
          .collection('user_votes')
          .get();

      final votes = userVotesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'selectedOption': data['selectedOption'],
          'timestamp': data['timestamp'],
        };
      }).toList();

      // Create export data
      final exportData = {
        'summary': {
          'totalVotes': _totalVotes,
          'voteCounts': _voteCounts,
          'exportTime': DateTime.now().toIso8601String(),
        },
        'individualVotes': votes,
      };

      // In a real app, you'd save this to a file or send to email
      // For now, we'll show it in a dialog
      _showExportDialog(exportData);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting results: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showExportDialog(Map<String, dynamic> exportData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1d1d1e),
        title: const Text(
          'Export Results',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              _formatExportData(exportData),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatExportData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('VOTING RESULTS EXPORT');
    buffer.writeln('====================');
    buffer.writeln('Export Time: ${data['summary']['exportTime']}');
    buffer.writeln('Total Votes: ${data['summary']['totalVotes']}');
    buffer.writeln('');
    buffer.writeln('VOTE COUNTS:');
    buffer.writeln('-----------');
    
    final voteCounts = data['summary']['voteCounts'] as Map<String, int>;
    final sortedOptions = voteCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedOptions) {
      final percentage = _totalVotes > 0 ? (entry.value / _totalVotes * 100) : 0.0;
      buffer.writeln('${entry.key}: ${entry.value} votes (${percentage.toStringAsFixed(1)}%)');
    }
    
    buffer.writeln('');
    buffer.writeln('INDIVIDUAL VOTES:');
    buffer.writeln('----------------');
    
    final votes = data['individualVotes'] as List;
    for (final vote in votes) {
      buffer.writeln('User: ${vote['userId']} | Choice: ${vote['selectedOption']} | Time: ${vote['timestamp']}');
    }
    
    return buffer.toString();
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
          'Voting Results',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportResults,
            tooltip: 'Export Results',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.electricOrange,
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
                      ],
                    ),
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
    if (_totalVotes == 0) {
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
      ..sort((a, b) => (_voteCounts[b] ?? 0).compareTo(_voteCounts[a] ?? 0));

    return sortedOptions.map((option) {
      final votes = _voteCounts[option] ?? 0;
      final percentage = _totalVotes > 0 ? (votes / _totalVotes * 100) : 0.0;
      final isLeading = sortedOptions.indexOf(option) == 0;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLeading 
              ? AppColors.electricOrange.withOpacity(0.1)
              : const Color(0xFF1d1d1e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLeading 
                ? AppColors.electricOrange 
                : AppColors.deepPurple.withOpacity(0.3),
            width: isLeading ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLeading) ...[
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
                      fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Text(
                  '$votes votes',
                  style: TextStyle(
                    color: isLeading ? AppColors.electricOrange : Colors.white,
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
                    value: percentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLeading ? AppColors.electricOrange : AppColors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isLeading ? AppColors.electricOrange : Colors.white70,
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
