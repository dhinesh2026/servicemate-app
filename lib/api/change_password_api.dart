import 'dart:convert';
import 'package:http/http.dart' as http;

class ChangePasswordAPI {
  static const String baseUrl = "https://servicemate.ideonixis.com";

  // Change Password
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/change-password/$userId");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "newPassword": newPassword,
        }),
      );

      print("🔐 Change Password Response: ${res.statusCode} - ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode} - ${res.body}",
        };
      }
    } catch (e) {
      print("❌ Change Password Error: $e");
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Check Current Password
  static Future<Map<String, dynamic>> checkCurrentPassword({
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/check-current-password");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
        }),
      );

      print("🔍 Check Current Password Response: ${res.statusCode} - ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode} - ${res.body}",
        };
      }
    } catch (e) {
      print("❌ Check Current Password Error: $e");
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Change Password by Phone
  static Future<Map<String, dynamic>> changePasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/change-password-by-phone");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "newPassword": newPassword,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode} - ${res.body}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Verify Current Password
// Verify Current Password - Enhanced with debugging
static Future<Map<String, dynamic>> verifyCurrentPassword({
  required String phone,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/verify-password");
  
  // Debug what we're sending
  print("📤 Sending verify password request:");
  print("Phone: $phone");
  print("Password: $password");
  
  final requestBody = {
    "phone": phone,
    "password": password,
  };
  
  print("Request Body: $requestBody");
  
  try {
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      return {
        "success": false,
        "message": "Current password is incorrect",
      };
    } else if (res.statusCode == 400) {
      // Parse the error message from server
      try {
        final errorResponse = jsonDecode(res.body);
        return {
          "success": false,
          "message": errorResponse['message'] ?? 'Bad request',
        };
      } catch (e) {
        return {
          "success": false,
          "message": "Bad request: ${res.body}",
        };
      }
    } else {
      return {
        "success": false,
        "message": "Server error: ${res.statusCode} - ${res.body}",
      };
    }
  } catch (e) {
    return {"success": false, "message": "Request failed: $e"};
  }
}


}