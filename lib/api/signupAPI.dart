import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class SignupAPI {
  static const String baseUrl = "https://servicemate.ideonixis.com";

  // Common POST request handler
  static Future<Map<String, dynamic>> _postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📥 STATUS: ${res.statusCode}");
      print("📥 RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode}",
          "data": res.body,
        };
      }
    } catch (e) {
      print("❌ ERROR: $e");
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Register User
  static Future<Map<String, dynamic>> signupUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String authType,
  }) async {
    return await _postRequest("/register", {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "authType": authType,
    });
  }

  // Send OTP
  static Future<Map<String, dynamic>> sendOTP({required String phone}) async {
    return await _postRequest("/send-otp", {"phone": phone});
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP({
    required String otpId,
    required String otp,
  }) async {
    return await _postRequest("/verify-otp", {"otp_id": otpId, "otp": otp});
  }

  // Login API
  // signupAPI.dart - Updated Login Method
  static Future<Map<String, dynamic>> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      // Step 1: Validate login credentials
      final loginResult = await _postRequest("/login", {
        "phone": phone,
        "password": password,
      });

      if (loginResult['success']) {
        // Step 2: Find user by phone to get complete profile
        final userResult = await getUserByPhone(phone: phone);

        if (userResult['success']) {
          return {
            "success": true,
            "message": "Login successful",
            "user": userResult['user'],
          };
        } else {
          return loginResult; // Return original login result
        }
      } else {
        return loginResult;
      }
    } catch (e) {
      return {"success": false, "message": "Login failed: $e"};
    }
  }

  // Add this new method to get user by phone
  static Future<Map<String, dynamic>> getUserByPhone({
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/user-by-phone");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Sync Passwords
  static Future<Map<String, dynamic>> syncPasswords({
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/sync-passwords");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Google Login
  static Future<Map<String, dynamic>> googleLogin({
    required String name,
    required String email,
    required String phone,
  }) async {
    return await _postRequest("/google-login", {
      "name": name,
      "email": email,
      "phone": phone,
    });
  }

  // Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    final url = Uri.parse("$baseUrl/upload-image/$userId");
    try {
      // Read image file and convert to base64
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageData": base64Image}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Update user profile - Fixed version
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? profession,
    String? bio,
    String? profileImageUrl,
  }) async {
    final url = Uri.parse("$baseUrl/profile/$userId");
    try {
      // Create the request body
      final Map<String, dynamic> requestBody = {};

      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (profession != null) requestBody['profession'] = profession;
      if (bio != null) requestBody['bio'] = bio;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        requestBody['profileImageUrl'] = profileImageUrl;
      }

      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Get user profile - Fixed version
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final url = Uri.parse("$baseUrl/profile/$userId");

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  // Instead of returning just bool, return Map<String, dynamic>
  static Future<Map<String, dynamic>> bookFastService({
    required Map<String, dynamic> bookingData,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/bookings"),
      );

      bookingData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("problemImage", imageFile.path),
        );
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseData.body);
      } else {
        return {"success": false};
      }
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> bookScheduleService({
    required Map<String, dynamic> bookingData,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/schedulebookings"),
      );

      bookingData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("problemImage", imageFile.path),
        );
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseData.body);
      } else {
        return {"success": false};
      }
    } catch (e) {
      return {"success": false};
    }
  }
}
