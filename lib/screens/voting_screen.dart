import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _selectedOption;
  bool _hasVoted = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  
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
    _checkIfUserHasVoted();
  }

  Future<void> _checkIfUserHasVoted() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if user has already voted today
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final userVoteDoc = await _firestore
          .collection('voting')
          .doc('live_contest')
          .collection('user_votes')
          .doc('${user.uid}_$todayString')
          .get();

      if (userVoteDoc.exists) {
        setState(() {
          _hasVoted = true;
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking vote status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitVote() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option to vote'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if user has already voted today
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final userVoteRef = _firestore
          .collection('voting')
          .doc('live_contest')
          .collection('user_votes')
          .doc('${user.uid}_$todayString');
      
      final userVoteDoc = await userVoteRef.get();
      
      if (userVoteDoc.exists) {
        throw Exception('You have already voted today');
      }

      // Use the specific document ID you mentioned
      const votingResultsDocId = 'mWrN1YfAxB27hml50hyX';
      
      try {
        // First, try to get the document to see if it exists
        final docRef = _firestore.collection('Voting Results').doc(votingResultsDocId);
        final docSnapshot = await docRef.get();
        
        if (!docSnapshot.exists) {
          // Create the document with all options set to 0
          final initialData = <String, dynamic>{
            'Date': todayString,
            'lastUpdated': FieldValue.serverTimestamp(),
          };
          
          // Initialize all options to 0
          for (String option in _options) {
            initialData[option] = 0;
          }
          
          await docRef.set(initialData);
        }
        
        // Now use a simple update approach instead of transaction
        final currentData = docSnapshot.exists ? docSnapshot.data()! : <String, dynamic>{};
        final currentCount = (currentData[_selectedOption!] as int?) ?? 0;
        final newCount = currentCount + 1;
        
        // Update the document
        await docRef.update({
          _selectedOption!: newCount,
          'Date': todayString,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
      } catch (e) {
        // If update fails, try to create/update with set
        final docRef = _firestore.collection('Voting Results').doc(votingResultsDocId);
        final docSnapshot = await docRef.get();
        
        final currentData = docSnapshot.exists ? docSnapshot.data()! : <String, dynamic>{};
        final currentCount = (currentData[_selectedOption!] as int?) ?? 0;
        final newCount = currentCount + 1;
        
        // Use set with merge to ensure the document exists
        await docRef.set({
          _selectedOption!: newCount,
          'Date': todayString,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Also record in user votes to prevent duplicate voting
      await userVoteRef.set({
        'selectedOption': _selectedOption,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'date': todayString,
      });

      setState(() {
        _hasVoted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote Counted!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error submitting vote';
        
        if (e.toString().contains('already voted')) {
          errorMessage = 'You have already voted today';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please try again.';
        } else if (e.toString().contains('unavailable')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Error submitting vote: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
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
          'Live Contest Voting',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                  // Header
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Contest Voting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasVoted 
                              ? 'You have already voted. Thank you for participating!'
                              : 'Select your choice and submit your vote',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Voting Options
                  if (!_hasVoted) ...[
                    const Text(
                      'Select Your Choice:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._options.map((option) => _buildVoteOption(option)),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SUBMIT VOTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ],
                  
                ],
              ),
            ),
    );
  }

  Widget _buildVoteOption(String option) {
    final isSelected = _selectedOption == option;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _selectedOption = option),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.electricOrange.withOpacity(0.2)
                : const Color(0xFF1d1d1e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.electricOrange 
                  : AppColors.deepPurple.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.electricOrange : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
