import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';

/// Hospital screen displaying list of available hospitals
class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  /// Hospital data model
  static const List<Map<String, String>> hospitals = [
    {
      'name': 'Aster Hospital',
      'description': 'Multi-specialty hospital with 24/7 emergency services',
    },
    {
      'name': 'City Hospital',
      'description': 'Leading healthcare provider with modern facilities',
    },
    {
      'name': 'Sunrise Hospital',
      'description': 'Comprehensive care with experienced medical staff',
    },
  ];

  /// Handles token booking
  void _bookToken(BuildContext context, String hospitalName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Token Booked Successfully at $hospitalName'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
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
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [AppStyles.cardShadow],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
              
              // Title with animation
              TweenAnimationBuilder<double>(
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
                  'Hospitals',
                  style: AppStyles.heading1,
                ),
              ),
              
              SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
              
              // Hospital list
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: hospitals.length,
                  separatorBuilder: (context, index) => SizedBox(
                    height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
                  ),
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return _AnimatedHospitalCard(
                      delay: index * 100,
                      child: _HospitalCard(
                        name: hospital['name']!,
                        description: hospital['description']!,
                        onBookToken: () => _bookToken(context, hospital['name']!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated wrapper for hospital cards
class _AnimatedHospitalCard extends StatelessWidget {
  final int delay;
  final Widget child;

  const _AnimatedHospitalCard({
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
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Hospital card widget
class _HospitalCard extends StatefulWidget {
  final String name;
  final String description;
  final VoidCallback onBookToken;

  const _HospitalCard({
    required this.name,
    required this.description,
    required this.onBookToken,
  });

  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          boxShadow: _isHovered ? AppStyles.cardShadowHover : [AppStyles.cardShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital icon and name
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                      boxShadow: AppStyles.iconShadow,
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: AppColors.textLight,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingLarge),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: AppStyles.heading3,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppStyles.spacingLarge),
              
              // Description
              Text(
                widget.description,
                style: AppStyles.bodyMedium.copyWith(fontSize: 15),
              ),
              
              const SizedBox(height: AppStyles.spacingLarge),
              
              // Get Token button
              CustomButton(
                text: 'Get Token',
                onPressed: widget.onBookToken,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
