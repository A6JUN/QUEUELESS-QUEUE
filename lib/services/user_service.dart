import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service class for handling user data in Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save user data to Firestore after signup
  Future<void> saveUserData({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to save user data. Please try again.';
    }
  }

  /// Get user's full name from Firestore
  Future<String?> getUserName() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['fullName'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
