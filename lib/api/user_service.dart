import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http; // ✅ ADD THIS
import '../models/user_model.dart';
import '../api/signupAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static User _currentUser = User(
    id: '',
    name: '',
    email: '',
    phone: '',
    profileImageUrl: '',
    profession: '',
    bio: '',
    localImagePath: null,
  );

  static User get currentUser => _currentUser;

  static void updateUser(User newUser) {
    _currentUser = newUser;
    print('✅ User updated: ${_currentUser.name}');
    print('📞 Phone: ${_currentUser.phone}');
    print('📧 Email: ${_currentUser.email}');
    print('🖼️ Profile Image: ${_currentUser.profileImageUrl}');
    print('💾 Local Image Path: ${_currentUser.localImagePath}');
  }

  static bool get isUserDataValid {
    return _currentUser.phone.isNotEmpty && _currentUser.id.isNotEmpty;
  }

  // 🔹 Logout with API + local clear
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = _currentUser.phone;

    try {
      // 🔹 Call backend logout API
      final response = await http.post(
        Uri.parse("https://servicemate.ideonixis.com/logout"),
        headers: {"Content-Type": "application/json"},
        body: '{"phone":"$phone"}', // ✅ JSON body
      );

      print("📡 Logout API response: ${response.body}");
    } catch (e) {
      print("❌ Error calling logout API: $e");
    }

    // 🔹 Clear local user data
    _currentUser = User(
      id: '',
      name: '',
      email: '',
      phone: '',
      profileImageUrl: '',
      profession: '',
      bio: '',
      localImagePath: null,
    );

    await prefs.clear();
    print("🚪 User logged out & data cleared");
  }

  // Upload profile image
  static Future<bool> uploadProfileImage(File imageFile) async {
    try {
      print("📤 Uploading profile image");
      final result = await SignupAPI.uploadProfileImage(
        userId: _currentUser.id,
        imagePath: imageFile.path,
      );

      if (result['success']) {
        _currentUser = _currentUser.copyWith(
          profileImageUrl: result['profileImageUrl'],
          localImagePath: imageFile.path,
        );
        print("✅ Profile image uploaded successfully");
        return true;
      } else {
        print("❌ Failed to upload profile image: ${result['message']}");
        return false;
      }
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      return false;
    }
  }

  // Save user data to API
  static Future<bool> saveUserData() async {
    try {
      print("💾 Saving user data: ${_currentUser.toJson()}");

      final result = await SignupAPI.updateProfile(
        userId: _currentUser.id,
        name: _currentUser.name,
        email: _currentUser.email,
        phone: _currentUser.phone,
        profession: _currentUser.profession,
        bio: _currentUser.bio,
        profileImageUrl: _currentUser.profileImageUrl,
      );

      print("💾 Save result: ${result['success']} - ${result['message']}");

      return result['success'];
    } catch (e) {
      print('❌ Error saving user data: $e');
      return false;
    }
  }

  // Clear image cache when needed
  static void clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
