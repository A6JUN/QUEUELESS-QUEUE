import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';

/// University staff dashboard for managing admission queue
class UniversityStaffDashboardScreen extends StatefulWidget {
  const UniversityStaffDashboardScreen({super.key});

  @override
  State<UniversityStaffDashboardScreen> createState() => _UniversityStaffDashboardScreenState();
}

class _UniversityStaffDashboardScreenState extends State<UniversityStaffDashboardScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  
  String _staffName = 'Staff';
  String _departmentName = 'Loading...';
  String? _departmentCode;
  
  int _totalTokensToday = 0;
  int _waitingTokens = 0;
  int _calledTokens = 0;
  int _completedTokens = 0;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  /// Load staff data
  Future<void> _loadStaffData() async {
    try {
      final name = await _userService.getUserName();
      if (mounted && name != null) {
        setState(() => _staffName = name);
      }

      // Get staff's assigned department
      final userData = await _userService.getUserData();
      if (userData != null && userData['departmentCode'] != null) {
        final deptCode = userData['departmentCode'] as String;
        final deptName = userData['departmentName'] as String? ?? 'Unknown Department';
        
        setState(() {
          _departmentCode = deptCode;
          _departmentName = deptName;
        });

        await _loadStatistics(deptCode);
      } else {
        if (mounted) {
          setState(() => _departmentName = 'No Department Assigned');
        }
      }
    } catch (e) {
      print('Error loading staff data: $e');
      if (mounted) {
        setState(() => _departmentName = 'Error loading data');
      }
    }
  }

  /// Load today's statistics
  Future<void> _loadStatistics(String deptCode) async {
    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final tokensSnapshot = await _firestore
          .collection('university_tokens')
          .where('departmentCode', isEqualTo: deptCode)
          .where('date', isEqualTo: dateString)
          .get();

      if (mounted) {
        setState(() {
          _totalTokensToday = tokensSnapshot.docs.length;
          _waitingTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'waiting').length;
          _calledTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'called').length;
          _completedTokens = tokensSnapshot.docs.where((doc) => doc.data()['status'] == 'completed').length;
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
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
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
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
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    
                    const SizedBox(height: AppStyles.spacingLarge),
                    
                    Text(
                      _departmentName,
                      style: AppStyles.headingLight.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: AppStyles.spacingSmall),
                    Text(
                      'Kannur University',
                      style: AppStyles.subtitleLight.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_departmentCode != null) {
                  await _loadStatistics(_departmentCode!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today: ${_formatDate(DateTime.now())}',
                      style: AppStyles.heading3.copyWith(fontSize: 18),
                    ),
                    
                    const SizedBox(height: AppStyles.spacingXLarge),
                    
                    // Statistics
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppStyles.spacingMedium,
                      crossAxisSpacing: AppStyles.spacingMedium,
                      childAspectRatio: 1.1,
                      children: [
                        _StatCard(
                          title: 'Total',
                          value: _totalTokensToday.toString(),
                          icon: Icons.confirmation_number,
                          color: AppColors.primary,
                        ),
                        _StatCard(
                          title: 'Waiting',
                          value: _waitingTokens.toString(),
                          icon: Icons.hourglass_empty,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Called',
                          value: _calledTokens.toString(),
                          icon: Icons.phone_in_talk,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Completed',
                          value: _completedTokens.toString(),
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppStyles.spacingXXLarge),
                    
                    // Queue section
                    if (_departmentCode != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Queue',
                            style: AppStyles.heading2.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _loadStatistics(_departmentCode!),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.spacingLarge),
                      _QueueList(departmentCode: _departmentCode!),
                    ] else ...[
                      Center(
                        child: Text(
                          'No department assigned',
                          style: AppStyles.bodyMedium,
                        ),
                      ),
                    ],
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

/// Statistics card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: [AppStyles.cardShadow],
      ),
      padding: const EdgeInsets.all(AppStyles.spacingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppStyles.heading1.copyWith(fontSize: 28, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppStyles.bodyMedium.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Queue list widget
class _QueueList extends StatelessWidget {
  final String departmentCode;

  const _QueueList({required this.departmentCode});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('university_tokens')
          .where('departmentCode', isEqualTo: departmentCode)
          .where('date', isEqualTo: dateString)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTokens = snapshot.data?.docs ?? [];
        
        // Filter and sort: waiting first, then called, then completed
        final tokens = allTokens.where((doc) {
          final status = doc.data() as Map<String, dynamic>?;
          return status?['status'] != 'cancelled';
        }).toList();

        tokens.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aStatus = aData['status'] ?? 'waiting';
          final bStatus = bData['status'] ?? 'waiting';
          final aPos = aData['queuePosition'] ?? 999;
          final bPos = bData['queuePosition'] ?? 999;
          
          // Sort by status priority, then by queue position
          final statusPriority = {'waiting': 0, 'called': 1, 'completed': 2};
          final aPriority = statusPriority[aStatus] ?? 3;
          final bPriority = statusPriority[bStatus] ?? 3;
          
          if (aPriority != bPriority) return aPriority.compareTo(bPriority);
          return aPos.compareTo(bPos);
        });

        if (tokens.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.spacingXXLarge),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 60, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: AppStyles.spacingLarge),
                  Text('No tokens for today', style: AppStyles.heading3),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tokens.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppStyles.spacingMedium),
          itemBuilder: (context, index) {
            final token = tokens[index];
            final data = token.data() as Map<String, dynamic>;
            return _TokenCard(tokenId: token.id, data: data);
          },
        );
      },
    );
  }
}

/// Token card for staff
class _TokenCard extends StatelessWidget {
  final String tokenId;
  final Map<String, dynamic> data;

  const _TokenCard({required this.tokenId, required this.data});

  Future<void> _callNext(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('university_tokens')
          .doc(tokenId)
          .update({'status': 'called', 'calledAt': FieldValue.serverTimestamp()});
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student called'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _markCompleted(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('university_tokens')
          .doc(tokenId)
          .update({'status': 'completed', 'completedAt': FieldValue.serverTimestamp()});
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token completed'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenNumber = data['tokenNumber'] ?? 'N/A';
    final userName = data['userName'] ?? 'Unknown';
    final userPhone = data['userPhone'] ?? 'N/A';
    final course = data['course'] ?? 'Unknown';
    final status = data['status'] ?? 'waiting';
    final queuePosition = data['queuePosition'] ?? 0;

    Color statusColor;
    switch (status) {
      case 'waiting':
        statusColor = Colors.orange;
        break;
      case 'called':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: [AppStyles.cardShadow],
        border: status == 'called' ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      padding: const EdgeInsets.all(AppStyles.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppStyles.spacingMedium),
          
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(userName, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          
          const SizedBox(height: AppStyles.spacingSmall),
          
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(userPhone, style: AppStyles.bodyMedium),
            ],
          ),
          
          const SizedBox(height: AppStyles.spacingSmall),
          
          Row(
            children: [
              const Icon(Icons.book, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(course, style: AppStyles.bodyMedium)),
            ],
          ),
          
          const SizedBox(height: AppStyles.spacingSmall),
          
          Row(
            children: [
              const Icon(Icons.numbers, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('Position: $queuePosition', style: AppStyles.bodyMedium),
            ],
          ),
          
          if (status == 'waiting' || status == 'called') ...[
            const SizedBox(height: AppStyles.spacingMedium),
            Row(
              children: [
                if (status == 'waiting')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callNext(context),
                      icon: const Icon(Icons.phone_in_talk, size: 18),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (status == 'waiting') const SizedBox(width: AppStyles.spacingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markCompleted(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
