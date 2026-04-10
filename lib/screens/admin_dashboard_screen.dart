import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';
import 'manage_hospitals_screen.dart';

/// Admin dashboard screen with management options
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _userService = UserService();
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  /// Load admin's full name from Firestore
  Future<void> _loadAdminName() async {
    final name = await _userService.getUserName();
    if (mounted && name != null) {
      setState(() {
        _adminName = name;
      });
    }
  }

  /// Handles logout action
  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.signOut();
      
      if (!context.mounted) return;
      
      // Clear navigation stack and go to login
      Navigator.pushAndRemoveUntil(
        context,
        PageTransitions.fadeScaleTransition(const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navigate to manage hospitals screen
  void _navigateToManageHospitals(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideUpTransition(const ManageHospitalsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppStyles.radiusXLarge),
                bottomRight: Radius.circular(AppStyles.radiusXLarge),
              ),
              boxShadow: AppStyles.headerShadow,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppStyles.spacingXLarge,
                  isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
                  AppStyles.spacingXLarge,
                  isSmallScreen ? AppStyles.spacingXLarge : AppStyles.spacingXXLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin name and logout button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _adminName,
                                style: AppStyles.subtitleLight.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ADMIN',
                                  style: AppStyles.subtitleLight.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: AppStyles.spacingMedium),
                        
                        // Logout button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.textLight,
                            ),
                            onPressed: () => _handleLogout(context),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingXLarge),
                    
                    // Title
                    Text(
                      'Admin Dashboard',
                      style: AppStyles.headingLight.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: AppStyles.spacingSmall),
                    Text(
                      'Manage your system',
                      style: AppStyles.subtitleLight.copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Admin options content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? AppStyles.spacingSmall : AppStyles.spacingMedium),
                    
                    Text(
                      'Management',
                      style: AppStyles.heading2,
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    
                    // Admin options
                    _AdminOptionCard(
                      icon: Icons.local_hospital,
                      title: 'Manage Hospitals',
                      description: 'Add, edit, or remove hospitals',
                      onTap: () => _navigateToManageHospitals(context),
                    ),
                    
                    const SizedBox(height: AppStyles.spacingLarge),
                    
                    _AdminOptionCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      description: 'View system statistics and reports',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics coming soon!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppStyles.spacingLarge),
                    
                    _AdminOptionCard(
                      icon: Icons.people,
                      title: 'Manage Users',
                      description: 'View and manage user accounts',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User management coming soon!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin option card widget
class _AdminOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          boxShadow: [AppStyles.cardShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingLarge),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  boxShadow: AppStyles.iconShadow,
                ),
                child: Icon(
                  icon,
                  color: AppColors.textLight,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppStyles.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
