import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicemate_app/bookingpage/bookings_content.dart';
import 'package:servicemate_app/locationPage/add_address.dart';
import '../api/user_service.dart';
import 'edit_profile_page.dart';
import '../providers/theme_provider.dart';
import '../profilePage/change_password_page.dart';
import '../models/user_model.dart';
import '../profilePage/privacy_policy_page.dart';
import '../profilePage/terms_conditions_page.dart';
import '../loginPage/loginPage.dart';
import '../helpers/image_helper.dart';

// Custom Colors for your app
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
  static const Color cardBackground = Color(0xFFFFFFFF);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UniqueKey _imageKey = UniqueKey();

  void _refreshProfile() {
    setState(() {
      _imageKey = UniqueKey();
      UserService.clearImageCache();
    });
  }

  void _showCustomSnackBar(String message, Color backgroundColor) {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }

  Widget _buildProfileImage() {
    final user = UserService.currentUser;
    final imageUrl = user.profileImageUrl;
    final localPath = user.localImagePath;

    return KeyedSubtree(
      key: _imageKey,
      child: _buildImageContent(user, imageUrl, localPath),
    );
  }

  Widget _buildImageContent(User user, String imageUrl, String? localPath) {
    // Try local file first
    if (localPath != null && localPath.isNotEmpty) {
      try {
        final file = File(localPath);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return ImageHelper.buildImageFromData(
                  imageUrl,
                  width: 80,
                  height: 80,
                  errorWidget: _buildFallbackImage(),
                );
              },
            ),
          );
        }
      } catch (e) {
        print('Local file check error: $e');
      }
    }

    // Use database image data
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ImageHelper.buildImageFromData(
          imageUrl,
          width: 80,
          height: 80,
          errorWidget: _buildFallbackImage(),
        ),
      );
    }

    // Fallback to default
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  // Enhanced Logout Dialog
  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              const Text(
                "Log Out?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Message
              const Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          _buildProfileImage(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email.isNotEmpty ? user.email : user.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (user.profession.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.profession,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items - FIXED: Using Expanded with SingleChildScrollView
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Account Section
                        _buildSectionCard(
                          title: "Account",
                          children: [
                            _buildMenuItem(
                              icon: Icons.edit_outlined,
                              text: "Edit Profile",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfilePage(),
                                  ),
                                ).then((_) {
                                  _refreshProfile();
                                  _showCustomSnackBar("Profile updated successfully!", AppColors.success);
                                });
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.lock_outlined,
                              text: "Change Password",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChangePasswordPage(),
                                  ),
                                ).then((_) {
                                  _showCustomSnackBar("Password updated successfully!", AppColors.success);
                                });
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.calendar_today_outlined,
                              text: "My Bookings",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BookingsContent(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.location_on_outlined,
                              text: "My Addresses",
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DeliveryLocationScreen(),
                                  ),
                                );

                                if (result != null && result is String) {
                                  _showCustomSnackBar("Address updated: $result", AppColors.success);
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Preferences Section
                        _buildSectionCard(
                          title: "Preferences",
                          children: [
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.privacy_tip_outlined,
                              text: "Privacy Policy",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicyPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.description_outlined,
                              text: "Terms & Conditions",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TermsConditionsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Logout Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: AppColors.error.withOpacity(0.05),
                          child: ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: AppColors.error,
                            ),
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                            onTap: () async {
                              final shouldLogout = await _showLogoutConfirmationDialog();
                              if (shouldLogout == true) {
                                _showCustomSnackBar("Logging out...", AppColors.primary);
                                
                                // Navigate to login page
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );

                                // Background logout process
                                Future.delayed(Duration.zero, () async {
                                  await UserService.logout();
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20), // Extra padding for bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.border,
      ),
    );
  }
}