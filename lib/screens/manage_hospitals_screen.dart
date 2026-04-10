import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import '../widgets/custom_button.dart';
import 'add_edit_hospital_screen.dart';

/// Screen for managing hospitals (admin only)
class ManageHospitalsScreen extends StatelessWidget {
  const ManageHospitalsScreen({super.key});

  /// Delete hospital
  Future<void> _deleteHospital(BuildContext context, String hospitalId, String hospitalName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hospital'),
        content: Text('Are you sure you want to delete $hospitalName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(hospitalId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hospital deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
              child: Row(
                children: [
                  Container(
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
                  const SizedBox(width: AppStyles.spacingLarge),
                  Expanded(
                    child: Text(
                      'Manage Hospitals',
                      style: AppStyles.heading1.copyWith(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Hospital list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hospitals')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final hospitals = snapshot.data?.docs ?? [];

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
                            'No hospitals yet',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: AppStyles.spacingSmall),
                          Text(
                            'Add your first hospital',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    itemCount: hospitals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppStyles.spacingLarge),
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      final data = hospital.data() as Map<String, dynamic>;
                      
                      return _HospitalCard(
                        hospitalId: hospital.id,
                        name: data['name'] ?? 'Unknown',
                        description: data['description'] ?? '',
                        address: data['address'] ?? '',
                        isActive: data['isActive'] ?? true,
                        onEdit: () {
                          Navigator.push(
                            context,
                            PageTransitions.slideUpTransition(
                              AddEditHospitalScreen(
                                hospitalId: hospital.id,
                                hospitalData: data,
                              ),
                            ),
                          );
                        },
                        onDelete: () => _deleteHospital(context, hospital.id, data['name'] ?? 'Unknown'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageTransitions.slideUpTransition(const AddEditHospitalScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Hospital'),
      ),
    );
  }
}

/// Hospital card widget for admin management
class _HospitalCard extends StatelessWidget {
  final String hospitalId;
  final String name;
  final String description;
  final String address;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HospitalCard({
    required this.hospitalId,
    required this.name,
    required this.description,
    required this.address,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
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
        padding: const EdgeInsets.all(AppStyles.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: AppColors.textLight,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppStyles.heading3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: AppStyles.bodySmall.copyWith(
                            color: isActive ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingMedium),
            
            Text(
              description,
              style: AppStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (address.isNotEmpty) ...[
              const SizedBox(height: AppStyles.spacingSmall),
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
                      address,
                      style: AppStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: AppStyles.spacingLarge),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppStyles.spacingMedium),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
