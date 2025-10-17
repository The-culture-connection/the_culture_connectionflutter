import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? get currentUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<firebase_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Register with email and password
  Future<firebase_auth.User?> registerWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        // Create user profile in Firestore
        await _createUserProfile(credential.user!, firstName, lastName);
      }

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Sign in with Google
  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Create or update user profile in Firestore
        await _createUserProfile(userCredential.user!, 
          userCredential.user!.displayName?.split(' ').first ?? '',
          userCredential.user!.displayName?.split(' ').last ?? '');
      }

      return userCredential.user;
    } catch (e) {
      throw 'Google sign-in failed: ${e.toString()}';
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(firebase_auth.User firebaseUser, String firstName, String lastName) async {
    final userData = {
      'id': firebaseUser.uid,
      'email': firebaseUser.email,
      'displayName': firebaseUser.displayName,
      'photoURL': firebaseUser.photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVerified': false,
      'interests': [],
      'skills': [],
    };

    await _firestore.collection('Profiles').doc(firebaseUser.uid).set(userData, SetOptions(merge: true));
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Get user profile from Firestore
  Future<User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('Profiles').doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: ${e.toString()}';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('Profiles').doc(uid).update(updates);
    } catch (e) {
      throw 'Failed to update user profile: ${e.toString()}';
    }
  }

  // Get error message from Firebase error code
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}