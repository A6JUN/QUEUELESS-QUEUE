import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';

/// Confirmation screen after booking university token
class UniversityTokenConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> tokenData;

  const UniversityTokenConfirmationScreen({
    super.key,
    required this.tokenData,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Success header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppStyles.radiusXLarge),
                  bottomRight: Radius.circular(AppStyles.radiusXLarge),
                ),
                boxShadow: AppStyles.headerShadow,
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingXLarge : AppStyles.spacingXXLarge),
                child: Column(
                  children: [
                    // Success icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.textLight,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppStyles.spacingLarge),
                    
                    Text(
                      'Token Booked Successfully!',
                      style: AppStyles.headingLight.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppStyles.spacingSmall),
                    
                    Text(
                      'Your admission token has been confirmed',
                      style: AppStyles.subtitleLight,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Token details
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                child: Column(
                  children: [
                    // Token number card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppStyles.spacingXLarge),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        boxShadow: [AppStyles.cardShadow],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Token Number',
                            style: AppStyles.subtitleLight.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: AppStyles.spacingSmall),
                          Text(
                            tokenData['tokenNumber'] ?? 'N/A',
                            style: AppStyles.headingLight.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppStyles.spacingXLarge),
                    
                    // Queue position
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppStyles.spacingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        boxShadow: [AppStyles.cardShadow],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: AppStyles.spacingMedium),
                          Text(
                            'Queue Position: ${tokenData['queuePosition'] ?? 'N/A'}',
                            style: AppStyles.heading3,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppStyles.spacingXLarge),
                    
                    // Details card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppStyles.spacingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        boxShadow: [AppStyles.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: AppStyles.spacingLarge),
                          _DetailRow(
                            icon: Icons.person,
                            label: 'Name',
                            value: tokenData['userName'] ?? 'N/A',
                          ),
                          const SizedBox(height: AppStyles.spacingMedium),
                          _DetailRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: tokenData['userEmail'] ?? 'N/A',
                          ),
                          const SizedBox(height: AppStyles.spacingMedium),
                          _DetailRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: tokenData['userPhone'] ?? 'N/A',
                          ),
                          const SizedBox(height: AppStyles.spacingMedium),
                          _DetailRow(
                            icon: Icons.school,
                            label: 'Department',
                            value: tokenData['department'] ?? 'N/A',
                          ),
                          const SizedBox(height: AppStyles.spacingMedium),
                          _DetailRow(
                            icon: Icons.book,
                            label: 'Course',
                            value: tokenData['course'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppStyles.spacingXLarge),
                    
                    // Info message
                    Container(
                      padding: const EdgeInsets.all(AppStyles.spacingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppStyles.spacingMedium),
                          Expanded(
                            child: Text(
                              'Please arrive 15 minutes before your turn. Bring all required documents.',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom buttons
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Done',
                    onPressed: () {
                      // Go back to service selection
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppStyles.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
