import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import '../services/university_token_service.dart';
import 'university_token_confirmation_screen.dart';

/// Kannur University screen with departments and courses
class KannurUniversityScreen extends StatelessWidget {
  const KannurUniversityScreen({super.key});

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
                  SizedBox(width: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge),
                  Expanded(
                    child: Text(
                      'Kannur University',
                      style: AppStyles.heading1.copyWith(fontSize: 28),
                    ),
                  ),
                ],
              ),
            ),
            
            // Departments list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                  0,
                  isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                  isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge,
                ),
                children: [
                  _DepartmentCard(
                    department: 'Department of Information Technology',
                    departmentCode: 'IT',
                    courses: const [
                      {'name': 'MSc Computer Science', 'code': 'MSCS'},
                      {'name': 'MCA', 'code': 'MCA'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'School of Physical Education and Sport Sciences',
                    departmentCode: 'PE',
                    courses: const [
                      {'name': 'Bachelor in Physical Education', 'code': 'BPE'},
                      {'name': 'Master in Physical Education', 'code': 'MPE'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Mathematical Sciences',
                    departmentCode: 'MATH',
                    courses: const [
                      {'name': 'MSc Maths', 'code': 'MSC'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Statistical Sciences',
                    departmentCode: 'STAT',
                    courses: const [
                      {'name': 'MSc Statistics', 'code': 'MSC'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of History',
                    departmentCode: 'HIST',
                    courses: const [
                      {'name': 'MA History', 'code': 'MA'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Journalism and Media Studies',
                    departmentCode: 'JMC',
                    courses: const [
                      {'name': 'M.A. Journalism and Mass Communication', 'code': 'MA'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Behavioural Sciences',
                    departmentCode: 'BEH',
                    courses: const [
                      {'name': 'M.Sc Clinical and Counselling', 'code': 'MSCC'},
                      {'name': 'Five-Year Integrated Masters Program in Clinical Psychology', 'code': '5YIP'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Wood Science & Technology',
                    departmentCode: 'WOOD',
                    courses: const [
                      {'name': 'M.Sc. Wood Science & Technology', 'code': 'MSC'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Environmental Studies',
                    departmentCode: 'ENV',
                    courses: const [
                      {'name': 'M.Sc. in Environmental Science', 'code': 'MSC'},
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingLarge),
                  _DepartmentCard(
                    department: 'Department of Management Studies',
                    departmentCode: 'MGT',
                    courses: const [
                      {'name': 'MBA', 'code': 'MBA'},
                    ],
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

/// Department card with expandable courses
class _DepartmentCard extends StatelessWidget {
  final String department;
  final String departmentCode;
  final List<Map<String, String>> courses;

  const _DepartmentCard({
    required this.department,
    required this.departmentCode,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(AppStyles.spacingLarge),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppStyles.spacingLarge,
            0,
            AppStyles.spacingLarge,
            AppStyles.spacingLarge,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
            ),
            child: const Icon(
              Icons.school,
              color: AppColors.textLight,
              size: 28,
            ),
          ),
          title: Text(
            department,
            style: AppStyles.heading3.copyWith(fontSize: 16),
          ),
          children: courses.map((course) {
            return _CourseItem(
              courseName: course['name']!,
              courseCode: course['code']!,
              department: department,
              departmentCode: departmentCode,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Individual course item
class _CourseItem extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final String department;
  final String departmentCode;

  const _CourseItem({
    required this.courseName,
    required this.courseCode,
    required this.department,
    required this.departmentCode,
  });

  void _showPhoneDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        ),
        title: Text('Enter Phone Number', style: AppStyles.heading3),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91 9876543210',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length < 10) {
                return 'Please enter valid phone number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _bookToken(context, phoneController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Book Token'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookToken(BuildContext context, String phoneNumber) async {
    // Capture navigator before showing dialog
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print('📱 UI: Starting booking process...');
      final service = UniversityTokenService();
      final result = await service.bookToken(
        department: department,
        departmentCode: departmentCode,
        course: courseName,
        courseCode: courseCode,
        phoneNumber: phoneNumber,
      );

      print('📱 UI: Booking completed, result: ${result['tokenNumber']}');
      
      print('📱 UI: Closing loading dialog...');
      // Close loading using root navigator
      navigator.pop();

      print('📱 UI: Navigating to confirmation screen...');
      // Navigate to confirmation
      navigator.push(
        PageTransitions.slideUpTransition(
          UniversityTokenConfirmationScreen(tokenData: result),
        ),
      );
      print('📱 UI: Navigation complete!');
    } catch (e) {
      print('❌ UI: Error occurred: $e');
      
      print('📱 UI: Closing loading dialog after error...');
      // Close loading
      navigator.pop();

      print('📱 UI: Showing error snackbar...');
      // Show error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
      ),
      child: ListTile(
        title: Text(
          courseName,
          style: AppStyles.bodyMedium.copyWith(fontSize: 15),
        ),
        trailing: ElevatedButton(
          onPressed: () => _showPhoneDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
            ),
          ),
          child: const Text('Book Token'),
        ),
      ),
    );
  }
}
