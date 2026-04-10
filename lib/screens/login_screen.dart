import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/page_transitions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'signup_screen.dart';
import 'service_selection_screen.dart';

/// Login screen with email and password authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handles login action with Firebase Authentication
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Sign in with Firebase
        await _authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        if (!mounted) return;
        
        // Wait a bit for auth state to propagate
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted) return;
        
        // Navigate to service selection (AuthWrapper will handle this but we force it)
        Navigator.of(context).pushReplacement(
          PageTransitions.fadeScaleTransition(const ServiceSelectionScreen()),
        );
        
      } catch (e) {
        if (!mounted) return;
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Navigates to signup screen
  void _navigateToSignup() {
    Navigator.push(
      context,
      PageTransitions.slideTransition(const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyles.spacingXLarge,
                vertical: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? AppStyles.spacingXLarge : 60),
                  
                  // Welcome text with fade-in animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppStyles.heading1,
                        ),
                        const SizedBox(height: AppStyles.spacingSmall),
                        Text(
                          'Sign in to continue',
                          style: AppStyles.bodyMedium.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? AppStyles.spacingXLarge : 60),
                  
                  // Email field with staggered animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
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
                    child: CustomTextField(
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  
                  const SizedBox(height: AppStyles.spacingLarge),
                  
                  // Password field with staggered animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
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
                    child: CustomTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                      validator: _validatePassword,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? AppStyles.spacingXLarge : 60),
                  
                  // Login button with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
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
                    child: CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? AppStyles.spacingLarge : AppStyles.spacingXLarge),
                  
                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToSignup,
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? AppStyles.spacingMedium : AppStyles.spacingLarge),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
