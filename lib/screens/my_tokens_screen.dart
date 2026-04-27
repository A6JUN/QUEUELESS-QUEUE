import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/university_token_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

/// Screen to display user's booked tokens
class MyTokensScreen extends StatefulWidget {
  const MyTokensScreen({super.key});

  @override
  State<MyTokensScreen> createState() => _MyTokensScreenState();
}

class _MyTokensScreenState extends State<MyTokensScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tokenService = UniversityTokenService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with gradient
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
              child: Column(
                children: [
                  // Back button and title
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge),
                        Expanded(
                          child: Text(
                            'My Tokens',
                            style: AppStyles.headingLight.copyWith(fontSize: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tabs
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      AppStyles.spacingXLarge,
                      0,
                      AppStyles.spacingXLarge,
                      AppStyles.spacingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textLight,
                      labelStyle: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      tabs: const [
                        Tab(text: 'Active'),
                        Tab(text: 'Past'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TokensList(status: 'active', tokenService: _tokenService),
                _TokensList(status: 'past', tokenService: _tokenService),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tokens list widget
class _TokensList extends StatelessWidget {
  final String status;
  final UniversityTokenService tokenService;

  const _TokensList({
    required this.status,
    required this.tokenService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tokenService.getUserTokens(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: AppStyles.spacingLarge),
                Text('Error loading tokens', style: AppStyles.heading3),
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
          return const Center(child: CircularProgressIndicator());
        }

        final allTokens = snapshot.data?.docs ?? [];
        
        // Sort tokens by date (newest first) in memory
        allTokens.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = aData['date'] ?? '';
          final bDate = bData['date'] ?? '';
          return bDate.compareTo(aDate); // Descending order
        });
        
        // Filter tokens based on status
        final tokens = allTokens.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final tokenStatus = data['status'] ?? 'waiting';
          
          if (status == 'active') {
            return tokenStatus == 'waiting' || tokenStatus == 'called';
          } else {
            return tokenStatus == 'completed' || tokenStatus == 'cancelled';
          }
        }).toList();

        if (tokens.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'active' ? Icons.receipt_long_outlined : Icons.history,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: AppStyles.spacingLarge),
                Text(
                  status == 'active' ? 'No active tokens' : 'No past tokens',
                  style: AppStyles.heading3,
                ),
                const SizedBox(height: AppStyles.spacingSmall),
                Text(
                  status == 'active' 
                      ? 'Book a token to get started'
                      : 'Your completed tokens will appear here',
                  style: AppStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh is automatic with StreamBuilder
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppStyles.spacingXLarge),
            itemCount: tokens.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppStyles.spacingLarge),
            itemBuilder: (context, index) {
              final token = tokens[index];
              final data = token.data() as Map<String, dynamic>;
              // Add document ID to data
              data['tokenId'] = token.id;
              return _TokenCard(data: data);
            },
          ),
        );
      },
    );
  }
}

/// Individual token card
class _TokenCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TokenCard({required this.data});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return AppColors.primary;
      case 'called':
        return Colors.orange;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Waiting';
      case 'called':
        return 'Called';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<void> _cancelToken(BuildContext context, String tokenId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        ),
        title: Text('Cancel Token?', style: AppStyles.heading3),
        content: Text(
          'Are you sure you want to cancel this token? This action cannot be undone.',
          style: AppStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cancel the token
      await UniversityTokenService().cancelToken(tokenId);

      if (!context.mounted) return;
      
      // Close loading
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Token cancelled successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Close loading
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel token: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenNumber = data['tokenNumber'] ?? 'N/A';
    final tokenId = data['tokenId'] ?? '';
    final department = data['department'] ?? 'Unknown Department';
    final course = data['course'] ?? 'Unknown Course';
    final status = data['status'] ?? 'waiting';
    final queuePosition = data['queuePosition'] ?? 0;
    final date = data['date'] ?? '';
    final canCancel = status == 'waiting' || status == 'called';

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
            // Token number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Token number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingMedium,
                    vertical: AppStyles.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                  ),
                  child: Text(
                    tokenNumber,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingMedium,
                    vertical: AppStyles.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: AppStyles.bodySmall.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingLarge),
            
            // Department
            Row(
              children: [
                const Icon(Icons.school, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppStyles.spacingSmall),
                Expanded(
                  child: Text(
                    department,
                    style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingSmall),
            
            // Course
            Row(
              children: [
                const Icon(Icons.book, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppStyles.spacingSmall),
                Expanded(
                  child: Text(
                    course,
                    style: AppStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingSmall),
            
            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppStyles.spacingSmall),
                Text(
                  date,
                  style: AppStyles.bodyMedium,
                ),
              ],
            ),
            
            // Queue position (only for active tokens)
            if (status == 'waiting' || status == 'called') ...[
              const SizedBox(height: AppStyles.spacingMedium),
              Container(
                padding: const EdgeInsets.all(AppStyles.spacingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppStyles.spacingSmall),
                    Text(
                      'Queue Position: $queuePosition',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Cancel button (only for active tokens)
            if (canCancel && tokenId.isNotEmpty) ...[
              const SizedBox(height: AppStyles.spacingMedium),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelToken(context, tokenId),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Token'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
