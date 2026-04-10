import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

/// Debug screen to check user role
class DebugRoleScreen extends StatefulWidget {
  const DebugRoleScreen({super.key});

  @override
  State<DebugRoleScreen> createState() => _DebugRoleScreenState();
}

class _DebugRoleScreenState extends State<DebugRoleScreen> {
  String _status = 'Loading...';
  String? _uid;
  String? _email;
  String? _role;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          _status = 'No user logged in';
        });
        return;
      }

      setState(() {
        _uid = user.uid;
        _email = user.email;
      });

      // Get user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userData = data;
          _role = data?['role'] as String?;
          _status = 'User data found';
        });
      } else {
        setState(() {
          _status = 'User document does not exist in Firestore';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _setRoleToAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': 'admin'});

      setState(() {
        _status = 'Role updated to admin! Please restart the app.';
      });
      
      _checkRole();
    } catch (e) {
      setState(() {
        _status = 'Error updating role: $e';
      });
    }
  }

  Future<void> _setRoleToUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': 'user'});

      setState(() {
        _status = 'Role updated to user! Please restart the app.';
      });
      
      _checkRole();
    } catch (e) {
      setState(() {
        _status = 'Error updating role: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Debug Role'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status:', style: AppStyles.heading3),
              const SizedBox(height: 8),
              Text(_status, style: AppStyles.bodyLarge),
              
              const SizedBox(height: AppStyles.spacingXLarge),
              
              Text('User ID:', style: AppStyles.heading3),
              const SizedBox(height: 8),
              Text(_uid ?? 'N/A', style: AppStyles.bodyMedium),
              
              const SizedBox(height: AppStyles.spacingLarge),
              
              Text('Email:', style: AppStyles.heading3),
              const SizedBox(height: 8),
              Text(_email ?? 'N/A', style: AppStyles.bodyMedium),
              
              const SizedBox(height: AppStyles.spacingLarge),
              
              Text('Current Role:', style: AppStyles.heading3),
              const SizedBox(height: 8),
              Text(
                _role ?? 'N/A',
                style: AppStyles.bodyLarge.copyWith(
                  color: _role == 'admin' ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppStyles.spacingLarge),
              
              Text('Full User Data:', style: AppStyles.heading3),
              const SizedBox(height: 8),
              Text(
                _userData?.toString() ?? 'N/A',
                style: AppStyles.bodySmall,
              ),
              
              const SizedBox(height: AppStyles.spacingXLarge),
              
              ElevatedButton(
                onPressed: _setRoleToAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Set Role to Admin'),
              ),
              
              const SizedBox(height: AppStyles.spacingMedium),
              
              ElevatedButton(
                onPressed: _setRoleToUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Set Role to User'),
              ),
              
              const SizedBox(height: AppStyles.spacingMedium),
              
              ElevatedButton(
                onPressed: _checkRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
