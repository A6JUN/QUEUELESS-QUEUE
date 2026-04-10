import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'service_selection_screen.dart';

/// Wrapper widget that handles authentication state
/// Automatically navigates to appropriate screen based on auth status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, show service selection screen
        if (snapshot.hasData && snapshot.data != null) {
          return const ServiceSelectionScreen();
        }
        
        // If user is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
