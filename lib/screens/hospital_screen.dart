import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';

/// Hospital screen displaying list of available hospitals from Firestore
class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
              child: Row(
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
                  
                  SizedBox(width: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge),
                  
                  // Title with animation
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
                        'Hospitals',
                        style: AppStyles.heading1.copyWith(fontSize: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Hospital list from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hospitals')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppStyles.spacingLarge),
                          Text(
                            'Error loading hospitals',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: AppStyles.spacingSmall),
                          Text(
                            snapshot.error.toString(),
                            style: AppStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Filter active hospitals in the app instead of in the query
                  final allHospitals = snapshot.data?.docs ?? [];
                  final hospitals = allHospitals.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isActive'] == true;
                  }).toList();

                  if (hospitals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppStyles.spacingLarge),
                          Text(
                            'No hospitals available',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: AppStyles.spacingSmall),
                          Text(
                            'Please check back later',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                      0,
                      isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                      isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                    ),
                    itemCount: hospitals.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
                    ),
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      final data = hospital.data() as Map<String, dynamic>;
                      
                      return _AnimatedHospitalCard(
                        delay: index * 100,
                        child: _HospitalCard(
                          name: data['name'] ?? 'Unknown Hospital',
                          description: data['description'] ?? '',
                          address: data['address'] ?? '',
                          phone: data['phone'] ?? '',
                          onBookToken: () => _bookToken(context, data['name'] ?? 'Unknown Hospital'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
  final String address;
  final String phone;
  final VoidCallback onBookToken;

  const _HospitalCard({
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Address
              if (widget.address.isNotEmpty) ...[
                const SizedBox(height: AppStyles.spacingMedium),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: AppStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Phone
              if (widget.phone.isNotEmpty) ...[
                const SizedBox(height: AppStyles.spacingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.phone,
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
              ],
              
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
