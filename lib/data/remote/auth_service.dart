import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to login state changes (logged in vs logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create Account & Save Profile to Database
  Future<String?> signUp(String name, String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Save the user's profile data in Firestore using their secure Auth ID
      await _db.collection('users').doc(cred.user!.uid).set({
        'full_name': name,
        'email': email,
        'profile_pic_path': null,
      });
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message to display
    }
  }

  // Login
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}