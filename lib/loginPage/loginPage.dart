import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:servicemate_app/bottom_navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/signupAPI.dart';
import '../api/user_service.dart';
import '../models/user_model.dart';
// import './googleLogin.dart';

// Custom Colors for your app (consistent with signup page)
class AppColors {
  static const Color primary = Color(0xFF6366F1); // Professional indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF10B981); // Emerald green
  static const Color accent = Color(0xFFF59E0B); // Amber
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  // Enhanced login handler with better notifications
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    _showCustomSnackBar("Logging in...", AppColors.primary);

    try {
      final result = await SignupAPI.loginUser(
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );

      if (result['success']) {
        // Update UserService with complete user data
        final userData = result['user'];
        UserService.updateUser(User.fromJson(userData));

        debugPrint("✅ Login successful, user data updated in UserService");
        debugPrint("User ID: ${UserService.currentUser.id}");
        debugPrint("User Name: ${UserService.currentUser.name}");
        debugPrint("User Email: ${UserService.currentUser.email}");

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phoneController.text.trim());
        await prefs.setBool('isLoggedIn', true);

        _showCustomSnackBar("Welcome back!", AppColors.success);

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppShell()),
        );
      } else {
        _showCustomSnackBar(
          result['message'] ?? "Login failed. Please check your credentials.",
          AppColors.error,
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      _showCustomSnackBar(
        "Connection error. Please try again.",
        AppColors.error,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Validation methods
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Enhanced snackbar with custom styling
  void _showCustomSnackBar(String message, Color backgroundColor) {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo with professional styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/logo.png', height: 60),
                ),

                const SizedBox(height: 32),

                // Welcome Header
                const Text(
                  "Welcome Back! 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Sign in to continue your journey with us",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    hintStyle:
                        const TextStyle(color: AppColors.textSecondary),
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
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.phone_android_outlined,
                        color: AppColors.textSecondary),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    hintStyle:
                        const TextStyle(color: AppColors.textSecondary),
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
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Google Login Section (Commented Out) ───────────────────
                // Row(
                //   children: [
                //     Expanded(
                //       child: Divider(
                //         color: AppColors.border,
                //         thickness: 1,
                //       ),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16),
                //       child: Text(
                //         "Or continue with",
                //         style: TextStyle(
                //           color: AppColors.textSecondary,
                //           fontSize: 14,
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Divider(
                //         color: AppColors.border,
                //         thickness: 1,
                //       ),
                //     ),
                //   ],
                // ),
                //
                // const SizedBox(height: 24),
                //
                // SizedBox(
                //   width: double.infinity,
                //   height: 56,
                //   child: OutlinedButton.icon(
                //     icon: SvgPicture.asset(
                //       'assets/images/google.svg',
                //       height: 20,
                //     ),
                //     label: const Text(
                //       "Continue with Google",
                //       style: TextStyle(
                //         color: AppColors.textPrimary,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     onPressed: () => GoogleLoginAPI.loginWithGoogle(context),
                //     style: OutlinedButton.styleFrom(
                //       side: const BorderSide(color: AppColors.border),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       backgroundColor: AppColors.surface,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 32),
                // ────────────────────────────────────────────────────────────

                const SizedBox(height: 32),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}