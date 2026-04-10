import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

/// Custom reusable text field widget with modern styling
class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        boxShadow: _isFocused ? AppStyles.elevatedShadow : [AppStyles.cardShadow],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: AppStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppStyles.bodyMedium,
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.prefixIcon,
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacingLarge,
            vertical: AppStyles.spacingLarge,
          ),
        ),
        ),
      ),
    );
  }
}
