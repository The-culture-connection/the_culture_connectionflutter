import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/Ultra Black Friday/questionnaire_screen.dart';
import '../screens/Ultra Black Friday/black_card_home_screen.dart';

/// Helper function to navigate to Ultra Black Friday feature
/// Checks if questionnaire is completed, shows it if not, then navigates to home
Future<void> navigateToUltraBlackFriday(BuildContext context) async {
  print('🎯 navigateToUltraBlackFriday called');
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ User not authenticated');
    // User not authenticated - could show login screen or return
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to access Ultra Black Friday'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  print('✅ User authenticated: ${user.uid}');

  try {
    // Check if questionnaire is completed
    print('📋 Checking questionnaire status in Profiles collection...');
    print('📋 User ID: ${user.uid}');
    print('📋 Collection path: Profiles/${user.uid}');
    
    final userDoc = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user.uid)
        .get();

    print('📋 Document exists: ${userDoc.exists}');
    print('📋 Document data: ${userDoc.data()}');
    
    bool completed = userDoc.data()?['ultraBlackFridayQuestionnaireCompleted'] ?? false;
    print('📋 Questionnaire completed flag: $completed');
    
    // Also check the subcollection as a fallback
    if (!completed) {
      print('📋 Checking Ultra Black Stats subcollection as fallback...');
      final statsDoc = await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(user.uid)
          .collection('Ultra Black Stats')
          .doc('preferences')
          .get();
      
      print('📋 Stats document exists: ${statsDoc.exists}');
      if (statsDoc.exists) {
        final statsCompleted = statsDoc.data()?['questionnaireCompleted'] ?? false;
        print('📋 Stats questionnaire completed: $statsCompleted');
        if (statsCompleted) {
          print('✅ Found completed questionnaire in subcollection, updating flag...');
          // Update the main document flag
          await FirebaseFirestore.instance
              .collection('Profiles')
              .doc(user.uid)
              .set({
            'ultraBlackFridayQuestionnaireCompleted': true,
          }, SetOptions(merge: true));
          // Update the local variable
          completed = true;
        }
      }
    }

    if (!completed) {
      // First time - show questionnaire
      print('📝 Showing questionnaire screen...');
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuestionnaireScreen(),
        ),
      );

      print('📝 Questionnaire result: $result');

      // If questionnaire was completed successfully, navigate to home
      if (result == true && context.mounted) {
        print('✅ Navigating to BlackCardHomeScreen after questionnaire');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BlackCardHomeScreen(),
          ),
        );
      }
    } else {
      // Already completed - go straight to home
      print('✅ Navigating directly to BlackCardHomeScreen');
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BlackCardHomeScreen(),
          ),
        );
      }
    }
  } catch (e) {
    print('❌ Error in navigateToUltraBlackFriday: $e');
    // On error, just navigate to home screen
    if (context.mounted) {
      print('⚠️ Navigating to home screen despite error');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BlackCardHomeScreen(),
        ),
      );
    }
  }
}

