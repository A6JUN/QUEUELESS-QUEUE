import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

/// Queue management screen for staff to manage tokens
class QueueManagementScreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;

  const QueueManagementScreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Waiting', 'Called', 'On Hold', 'Completed'];

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
              child: Column(
                children: [
                  Row(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Queue Management',
                              style: AppStyles.heading2.copyWith(fontSize: 20),
                            ),
                            Text(
                              widget.hospitalName,
                              style: AppStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppStyles.spacingLarge),
                  
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                            },
                            backgroundColor: AppColors.cardBackground,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Token list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getTokensStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tokens = snapshot.data?.docs ?? [];

                  if (tokens.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppStyles.spacingLarge),
                          Text(
                            'No tokens found',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: AppStyles.spacingSmall),
                          Text(
                            _selectedFilter == 'All' 
                                ? 'No tokens booked today'
                                : 'No $_selectedFilter tokens',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    itemCount: tokens.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppStyles.spacingLarge),
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      final data = token.data() as Map<String, dynamic>;
                      
                      return _TokenCard(
                        tokenId: token.id,
                        tokenNumber: data['tokenNumber'] ?? 'N/A',
                        userName: data['userName'] ?? 'Unknown',
                        department: data['department'] ?? 'General',
                        status: data['status'] ?? 'waiting',
                        bookedAt: data['bookedAt'],
                        queuePosition: data['queuePosition'] ?? 0,
                        onStatusChanged: () => setState(() {}),
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

  Stream<QuerySnapshot> _getTokensStream() {
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    var query = FirebaseFirestore.instance
        .collection('tokens')
        .where('hospitalId', isEqualTo: widget.hospitalId)
        .where('date', isEqualTo: dateString);

    // Apply filter
    if (_selectedFilter != 'All') {
      final statusMap = {
        'Waiting': 'waiting',
        'Called': 'called',
        'On Hold': 'on_hold',
        'Completed': 'completed',
      };
      query = query.where('status', isEqualTo: statusMap[_selectedFilter]);
    }

    return query.orderBy('bookedAt').snapshots();
  }
}

/// Token card widget
class _TokenCard extends StatelessWidget {
  final String tokenId;
  final String tokenNumber;
  final String userName;
  final String department;
  final String status;
  final Timestamp? bookedAt;
  final int queuePosition;
  final VoidCallback onStatusChanged;

  const _TokenCard({
    required this.tokenId,
    required this.tokenNumber,
    required this.userName,
    required this.department,
    required this.status,
    required this.bookedAt,
    required this.queuePosition,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: [AppStyles.cardShadow],
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tokenNumber,
                        style: AppStyles.heading3.copyWith(
                          color: AppColors.textLight,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (queuePosition > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Position: $queuePosition',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                _StatusBadge(status: status),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingMedium),
            
            // Patient info
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(userName, style: AppStyles.bodyLarge),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.medical_services, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(department, style: AppStyles.bodyMedium),
              ],
            ),
            
            if (bookedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(bookedAt!.toDate()),
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: AppStyles.spacingLarge),
            
            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (status) {
      case 'waiting':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(context, 'called'),
                icon: const Icon(Icons.phone_in_talk, size: 18),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(context, 'on_hold'),
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Hold'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              ),
            ),
          ],
        );
      
      case 'called':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(context, 'completed'),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(context, 'on_hold'),
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Hold'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              ),
            ),
          ],
        );
      
      case 'on_hold':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(context, 'called'),
                icon: const Icon(Icons.phone_in_talk, size: 18),
                label: const Text('Call Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(context, 'no_show'),
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('No Show'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        );
      
      case 'completed':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Service Completed',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc(tokenId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token status updated to ${newStatus.replaceAll('_', ' ')}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      
      onStatusChanged();
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

  Color _getStatusColor() {
    switch (status) {
      case 'waiting':
        return AppColors.warning;
      case 'called':
        return AppColors.primary;
      case 'on_hold':
        return AppColors.error;
      case 'completed':
        return AppColors.success;
      case 'no_show':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig['icon'],
            size: 16,
            color: statusConfig['color'],
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig['label'],
            style: AppStyles.bodySmall.copyWith(
              color: statusConfig['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (status) {
      case 'waiting':
        return {
          'label': 'Waiting',
          'icon': Icons.hourglass_empty,
          'color': AppColors.warning,
        };
      case 'called':
        return {
          'label': 'Called',
          'icon': Icons.phone_in_talk,
          'color': AppColors.primary,
        };
      case 'on_hold':
        return {
          'label': 'On Hold',
          'icon': Icons.pause_circle,
          'color': AppColors.error,
        };
      case 'completed':
        return {
          'label': 'Completed',
          'icon': Icons.check_circle,
          'color': AppColors.success,
        };
      case 'no_show':
        return {
          'label': 'No Show',
          'icon': Icons.cancel,
          'color': AppColors.textSecondary,
        };
      default:
        return {
          'label': 'Unknown',
          'icon': Icons.help,
          'color': AppColors.textSecondary,
        };
    }
  }
}
