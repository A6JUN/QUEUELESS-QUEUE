import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing university admission tokens
class UniversityTokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Books a token for university admission
  Future<Map<String, dynamic>> bookToken({
    required String department,
    required String departmentCode,
    required String course,
    required String courseCode,
    required String phoneNumber,
  }) async {
    try {
      print('🔵 Starting token booking...');
      
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ User not logged in');
        throw Exception('User not logged in');
      }
      print('✅ User authenticated: ${user.uid}');

      // Get user details
      print('🔵 Fetching user details...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['fullName'] ?? 'Unknown';
      print('✅ User name: $userName');

      // Get today's date
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      print('✅ Date: $dateStr');

      // Generate token number
      print('🔵 Generating token number...');
      final tokenNumber = await _generateTokenNumber(departmentCode, courseCode, dateStr);
      print('✅ Token number: $tokenNumber');

      // Calculate queue position
      print('🔵 Calculating queue position...');
      final queuePosition = await _getQueuePosition(departmentCode, courseCode, dateStr);
      print('✅ Queue position: $queuePosition');

      // Create token document
      final tokenData = {
        'tokenNumber': tokenNumber,
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email ?? '',
        'userPhone': phoneNumber,
        'department': department,
        'departmentCode': departmentCode,
        'course': course,
        'courseCode': courseCode,
        'status': 'waiting',
        'queuePosition': queuePosition,
        'bookedAt': FieldValue.serverTimestamp(),
        'date': dateStr,
      };

      print('🔵 Saving to Firestore...');
      final docRef = await _firestore.collection('university_tokens').add(tokenData);
      print('✅ Token saved successfully! Doc ID: ${docRef.id}');

      // Return data with current timestamp for display
      final displayData = {
        'success': true,
        'tokenNumber': tokenNumber,
        'queuePosition': queuePosition,
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email ?? '',
        'userPhone': phoneNumber,
        'department': department,
        'departmentCode': departmentCode,
        'course': course,
        'courseCode': courseCode,
        'status': 'waiting',
        'date': dateStr,
        'bookedAt': DateTime.now(), // Use current time for display
      };

      return displayData;
    } catch (e) {
      print('❌ Error booking token: $e');
      throw Exception('Failed to book token: $e');
    }
  }

  /// Generates unique token number
  Future<String> _generateTokenNumber(String deptCode, String courseCode, String date) async {
    final prefix = '$deptCode-$courseCode';
    
    try {
      // Get all tokens for today
      final snapshot = await _firestore
          .collection('university_tokens')
          .where('date', isEqualTo: date)
          .get()
          .timeout(const Duration(seconds: 10));

      // Filter by department and course code in memory
      final matchingTokens = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['departmentCode'] == deptCode && data['courseCode'] == courseCode;
      }).toList();

      final count = matchingTokens.length + 1;
      final number = count.toString().padLeft(3, '0');
      
      return '$prefix-$number';
    } catch (e) {
      // If collection doesn't exist or query fails, start with 001
      return '$prefix-001';
    }
  }

  /// Gets current queue position
  Future<int> _getQueuePosition(String deptCode, String courseCode, String date) async {
    try {
      // Get all tokens for today
      final snapshot = await _firestore
          .collection('university_tokens')
          .where('date', isEqualTo: date)
          .get()
          .timeout(const Duration(seconds: 10));

      // Filter by department, course code, and status in memory
      final waitingTokens = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['departmentCode'] == deptCode && 
               data['courseCode'] == courseCode &&
               data['status'] == 'waiting';
      }).toList();

      return waitingTokens.length + 1;
    } catch (e) {
      // If collection doesn't exist or query fails, start with position 1
      return 1;
    }
  }

  /// Gets user's tokens
  Stream<QuerySnapshot> getUserTokens() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('university_tokens')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  /// Cancels a token
  Future<void> cancelToken(String tokenId) async {
    try {
      await _firestore
          .collection('university_tokens')
          .doc(tokenId)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel token: $e');
    }
  }
}
