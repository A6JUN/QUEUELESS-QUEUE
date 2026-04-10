import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import '../widgets/service_card.dart';
import 'hospital_screen.dart';
import 'login_screen.dart';

/// Service selection screen showing available services
class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final _userService = UserService();
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  /// Load user's full name from Firestore
  Future<void> _loadUserName() async {
    final name = await _userService.getUserName();
    if (mounted && name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  /// Handles logout action with Firebase
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
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navigates to hospital screen
  void _navigateToHospital(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideUpTransition(const HospitalScreen()),
    );
  }

  /// Shows coming soon message for other services
  void _showComingSoon(BuildContext context, String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$serviceName coming soon!'),
        backgroundColor: AppColors.primary,
      ),
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
          // Gradient header with enhanced shadow
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
                    // User email and logout button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User email with animation
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(-20 * (1 - value), 0),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _userName,
                              style: AppStyles.subtitleLight.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppStyles.spacingMedium),
                        
                        // Logout button with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
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
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingXLarge),
                    
                    // App title with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Queueless',
                        style: AppStyles.headingLight.copyWith(fontSize: 36),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingSmall),
                    
                    // Subtitle with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Skip the line. Save your time.',
                        style: AppStyles.subtitleLight.copyWith(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Service selection content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? AppStyles.spacingSmall : AppStyles.spacingMedium),
                    
                    // Section title with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Select a Service',
                        style: AppStyles.heading2,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    
                    // Service grid with staggered animation
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
                      crossAxisSpacing: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
                      childAspectRatio: isSmallScreen ? 1.0 : 0.95,
                      children: [
                        // Hospital service
                        _AnimatedServiceCard(
                          delay: 0,
                          child: ServiceCard(
                            icon: Icons.local_hospital,
                            title: 'Hospital',
                            onTap: () => _navigateToHospital(context),
                          ),
                        ),
                        
                        // Bank service
                        _AnimatedServiceCard(
                          delay: 100,
                          child: ServiceCard(
                            icon: Icons.account_balance,
                            title: 'Bank',
                            onTap: () => _showComingSoon(context, 'Bank'),
                          ),
                        ),
                        
                        // College Office service
                        _AnimatedServiceCard(
                          delay: 200,
                          child: ServiceCard(
                            icon: Icons.school,
                            title: 'College Office',
                            onTap: () => _showComingSoon(context, 'College Office'),
                          ),
                        ),
                        
                        // Government Office service
                        _AnimatedServiceCard(
                          delay: 300,
                          child: ServiceCard(
                            icon: Icons.business,
                            title: 'Government Office',
                            onTap: () => _showComingSoon(context, 'Government Office'),
                          ),
                        ),
                        
                        // Service Center
                        _AnimatedServiceCard(
                          delay: 400,
                          child: ServiceCard(
                            icon: Icons.build,
                            title: 'Service Center',
                            onTap: () => _showComingSoon(context, 'Service Center'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
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


/// Animated wrapper for service cards with staggered animation
class _AnimatedServiceCard extends StatelessWidget {
  final int delay;
  final Widget child;

  const _AnimatedServiceCard({
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
