import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'service_selection_screen.dart';
import 'admin_dashboard_screen.dart';
import 'staff_dashboard_screen.dart';
import 'university_staff_dashboard_screen.dart';

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;
          
          // Get user role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Get role
              String role = 'user';
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                role = userData?['role'] as String? ?? 'user';
                print('🔍 User ID: $userId');
                print('🔍 User Data: $userData');
                print('🔍 Role: $role');
              } else {
                print('❌ User document does not exist');
              }
              
              // Route based on role
              switch (role) {
                case 'admin':
                  print('➡️ Routing to Admin Dashboard');
                  return const AdminDashboardScreen();
                case 'hospital_staff':
                  print('➡️ Routing to Hospital Staff Dashboard');
                  return const StaffDashboardScreen();
                case 'university_staff':
                  print('➡️ Routing to University Staff Dashboard');
                  return const UniversityStaffDashboardScreen();
                default:
                  print('➡️ Routing to Service Selection (User)');
                  return const ServiceSelectionScreen();
              }
            },
          );
        }
        
        return const LoginScreen();
      },
    );
  }
}
