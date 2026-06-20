// lib/services/google_login_api.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:servicemate_app/bottom_navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/signupAPI.dart';

// Custom Colors for your app (consistent with other pages)
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF1F5F9);
}

class GoogleLoginAPI {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Enhanced notification method
  static void _showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Professional dialog to collect phone + password - FIXED VERSION
  static Future<Map<String, String>?> _askForUserDetails(
      BuildContext context, String googleName, String googleEmail) async {
    final nameController = TextEditingController(text: googleName);
    final emailController = TextEditingController(text: googleEmail);
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    bool obscurePassword = true;

    return await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Header Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_add_alt_1,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Complete Your Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          const Text(
                            'We need a few more details to complete your registration',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Form Section - FIXED
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Name Field
                            TextFormField(
                              controller: nameController,
                              readOnly: true,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Email Field
                            TextFormField(
                              controller: emailController,
                              readOnly: true,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Phone Field
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                prefixIcon: const Icon(Icons.phone_android_outlined, color: AppColors.textSecondary),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password Field
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Create Password',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Fixed Footer Buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => Navigator.pop(context, null),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                String phone = phoneController.text.trim();
                                String password = passwordController.text.trim();

                                if (phone.isEmpty) {
                                  _showCustomSnackBar(
                                    context, 
                                    'Phone number is required', 
                                    AppColors.error
                                  );
                                  return;
                                }
                                if (phone.length != 10) {
                                  _showCustomSnackBar(
                                    context, 
                                    'Phone number must be exactly 10 digits', 
                                    AppColors.error
                                  );
                                  return;
                                }
                                if (password.isEmpty) {
                                  _showCustomSnackBar(
                                    context, 
                                    'Password is required', 
                                    AppColors.error
                                  );
                                  return;
                                }
                                if (password.length < 6) {
                                  _showCustomSnackBar(
                                    context, 
                                    'Password must be at least 6 characters', 
                                    AppColors.error
                                  );
                                  return;
                                }

                                Navigator.pop(context, {
                                  "name": nameController.text.trim(),
                                  "email": emailController.text.trim(),
                                  "phone": phone,
                                  "password": password,
                                });
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Enhanced main login function with professional notifications
  static Future<void> loginWithGoogle(BuildContext context) async {
    debugPrint('[Google Login] -> loginWithGoogle() called');

    _showCustomSnackBar(context, "Starting Google Sign-In...", AppColors.primary);

    try {
      // Always signOut first for account selection
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('⚠️ Google Sign-In cancelled / no account returned');
        _showCustomSnackBar(
          context, 
          'Google Sign-In cancelled', 
          AppColors.warning
        );
        return;
      }

      debugPrint('✅ Google Sign-In successful: ${account.email}');
      _showCustomSnackBar(
        context, 
        'Welcome, ${account.displayName ?? "User"}!', 
        AppColors.success
      );

      // Brief delay for better UX flow
      await Future.delayed(const Duration(milliseconds: 500));

      final userDetails = await _askForUserDetails(
        context,
        account.displayName ?? 'Google User',
        account.email,
      );

      if (userDetails == null) {
        _showCustomSnackBar(
          context, 
          'Registration cancelled', 
          AppColors.warning
        );
        return;
      }

      _showCustomSnackBar(
        context, 
        'Creating your account...', 
        AppColors.primary
      );

      final res = await SignupAPI.signupUser(
        name: userDetails['name']!,
        email: userDetails['email']!,
        phone: userDetails['phone']!,
        password: userDetails['password']!,
        authType: "google",
      );

      if (res['success'] == true) {
        if (res['token'] != null) await _saveToken(res['token']);
        
        _showCustomSnackBar(
          context, 
          'Account created successfully!', 
          AppColors.success
        );
        
        // Brief delay to show success message
        await Future.delayed(const Duration(milliseconds: 800));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      } else {
        _showCustomSnackBar(
          context, 
          res['message'] ?? 'Registration failed. Please try again.', 
          AppColors.error
        );
      }
    } catch (error, stack) {
      debugPrint("❌ Google Sign-In error: $error");
      debugPrint(stack.toString());
      
      _showCustomSnackBar(
        context, 
        'Google Sign-In failed. Please try again.', 
        AppColors.error
      );
    }
  }
}