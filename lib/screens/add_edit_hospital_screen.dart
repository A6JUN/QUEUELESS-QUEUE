import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

/// Screen for adding or editing a hospital
class AddEditHospitalScreen extends StatefulWidget {
  final String? hospitalId;
  final Map<String, dynamic>? hospitalData;

  const AddEditHospitalScreen({
    super.key,
    this.hospitalId,
    this.hospitalData,
  });

  @override
  State<AddEditHospitalScreen> createState() => _AddEditHospitalScreenState();
}

class _AddEditHospitalScreenState extends State<AddEditHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.hospitalId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing && widget.hospitalData != null) {
      _nameController.text = widget.hospitalData!['name'] ?? '';
      _descriptionController.text = widget.hospitalData!['description'] ?? '';
      _addressController.text = widget.hospitalData!['address'] ?? '';
      _phoneController.text = widget.hospitalData!['phone'] ?? '';
      _emailController.text = widget.hospitalData!['email'] ?? '';
      _isActive = widget.hospitalData!['isActive'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _saveHospital() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hospitalData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        // Update existing hospital
        await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(widget.hospitalId)
            .update(hospitalData);
      } else {
        // Add new hospital
        hospitalData['createdAt'] = FieldValue.serverTimestamp();
        hospitalData['departments'] = ['General', 'Emergency'];
        hospitalData['averageWaitTime'] = 15;
        
        await FirebaseFirestore.instance
            .collection('hospitals')
            .add(hospitalData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Hospital updated successfully' : 'Hospital added successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [AppStyles.cardShadow],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEditing ? 'Edit Hospital' : 'Add Hospital',
          style: AppStyles.heading3,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital Name
                  CustomTextField(
                    hintText: 'Hospital Name',
                    prefixIcon: Icons.local_hospital,
                    controller: _nameController,
                    validator: (value) => _validateRequired(value, 'hospital name'),
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),

                  // Description
                  CustomTextField(
                    hintText: 'Description',
                    prefixIcon: Icons.description,
                    controller: _descriptionController,
                    validator: (value) => _validateRequired(value, 'description'),
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),

                  // Address
                  CustomTextField(
                    hintText: 'Address',
                    prefixIcon: Icons.location_on,
                    controller: _addressController,
                    validator: (value) => _validateRequired(value, 'address'),
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),

                  // Phone
                  CustomTextField(
                    hintText: 'Phone Number',
                    prefixIcon: Icons.phone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => _validateRequired(value, 'phone number'),
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),

                  // Email
                  CustomTextField(
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),

                  // Active Status
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      boxShadow: [AppStyles.cardShadow],
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Active Status',
                        style: AppStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        _isActive ? 'Hospital is active' : 'Hospital is inactive',
                        style: AppStyles.bodySmall,
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? AppStyles.spacingXLarge : 60),

                  // Save Button
                  CustomButton(
                    text: isEditing ? 'Update Hospital' : 'Add Hospital',
                    onPressed: _saveHospital,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppStyles.spacingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
