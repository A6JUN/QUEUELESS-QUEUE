import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';
import 'queue_management_screen.dart';

/// Staff dashboard screen for hospital/service counter staff
class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  
  String _staffName = 'Staff';
  String _hospitalName = 'Loading...';
  String? _hospitalId;
  
  int _totalTokensToday = 0;
  int _waitingTokens = 0;
  int _completedTokens = 0;
  int _onHoldTokens = 0;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  /// Load staff data and statistics
  Future<void> _loadStaffData() async {
    try {
      // Get staff name
      final name = await _userService.getUserName();
      if (mounted && name != null) {
        setState(() => _staffName = name);
      }

      // Get staff's assigned hospital
      final userData = await _userService.getUserData();
      if (userData != null && userData['hospitalId'] != null) {
        final hospitalId = userData['hospitalId'] as String;
        setState(() => _hospitalId = hospitalId);

        // Get hospital name
        final hospitalDoc = await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(hospitalId)
            .get();
        
        if (hospitalDoc.exists && mounted) {
          setState(() {
            _hospitalName = hospitalDoc.data()?['name'] ?? 'Unknown Hospital';
          });
        }

        // Load today's statistics
        await _loadStatistics(hospitalId);
      } else {
        if (mounted) {
          setState(() => _hospitalName = 'No Hospital Assigned');
        }
      }
    } catch (e) {
      print('Error loading staff data: $e');
      if (mounted) {
        setState(() => _hospitalName = 'Error loading data');
      }
    }
  }

  /// Load today's token statistics
  Future<void> _loadStatistics(String hospitalId) async {
    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final tokensSnapshot = await FirebaseFirestore.instance
          .collection('tokens')
          .where('hospitalId', isEqualTo: hospitalId)
          .where('date', isEqualTo: dateString)
          .get();

      if (mounted) {
        setState(() {
          _totalTokensToday = tokensSnapshot.docs.length;
          _waitingTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'waiting').length;
          _completedTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'completed').length;
          _onHoldTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'on_hold').length;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        PageTransitions.fadeScaleTransition(const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Navigate to queue management
  void _navigateToQueue() {
    if (_hospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hospital assigned to your account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageTransitions.slideUpTransition(
        QueueManagementScreen(
          hospitalId: _hospitalId!,
          hospitalName: _hospitalName,
        ),
      ),
    ).then((_) => _loadStaffData()); // Refresh data when returning
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
                    // Staff info and logout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _staffName,
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
                                  'STAFF',
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
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout, color: AppColors.textLight),
                            onPressed: _handleLogout,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingXLarge),
                    
                    // Hospital name
                    Text(
                      _hospitalName,
                      style: AppStyles.headingLight.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: AppStyles.spacingSmall),
                    Text(
                      'Queue Management',
                      style: AppStyles.subtitleLight.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Dashboard content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's date
                    Text(
                      'Today: ${_formatDate(DateTime.now())}',
                      style: AppStyles.heading3.copyWith(fontSize: 18),
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    
                    // Statistics cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppStyles.spacingMedium,
                      crossAxisSpacing: AppStyles.spacingMedium,
                      childAspectRatio: isSmallScreen ? 1 : 1,
                      children: [
                        _StatCard(
                          title: 'Total Tokens',
                          value: _totalTokensToday.toString(),
                          icon: Icons.confirmation_number,
                          color: AppColors.primary,
                          isSmallScreen: isSmallScreen,
                        ),
                        _StatCard(
                          title: 'Waiting',
                          value: _waitingTokens.toString(),
                          icon: Icons.hourglass_empty,
                          color: AppColors.warning,
                          isSmallScreen: isSmallScreen,
                        ),
                        _StatCard(
                          title: 'Completed',
                          value: _completedTokens.toString(),
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          isSmallScreen: isSmallScreen,
                        ),
                        _StatCard(
                          title: 'On Hold',
                          value: _onHoldTokens.toString(),
                          icon: Icons.pause_circle,
                          color: AppColors.error,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppStyles.spacingXLarge : 40),
                    
                    // Action buttons
                    _ActionButton(
                      icon: Icons.list_alt,
                      title: 'Manage Queue',
                      description: 'View and manage today\'s queue',
                      onTap: _navigateToQueue,
                    ),
                    
                    const SizedBox(height: AppStyles.spacingLarge),
                    
                    _ActionButton(
                      icon: Icons.refresh,
                      title: 'Refresh Statistics',
                      description: 'Update dashboard data',
                      onTap: () => _loadStaffData(),
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmallScreen;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : AppStyles.spacingMedium,
          vertical: isSmallScreen ? 6 : AppStyles.spacingMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmallScreen ? 34 : 50,
              height: isSmallScreen ? 34 : 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 18 : 28),
            ),
            SizedBox(height: isSmallScreen ? 4 : 10),
            Text(
              value,
              style: AppStyles.heading1.copyWith(
                fontSize: isSmallScreen ? 20 : 32,
                color: color,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppStyles.bodyMedium.copyWith(
                fontSize: isSmallScreen ? 10 : 13,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionButton({
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
                ),
                child: Icon(icon, color: AppColors.textLight, size: 32),
              ),
              const SizedBox(width: AppStyles.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppStyles.heading3.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(description, style: AppStyles.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
