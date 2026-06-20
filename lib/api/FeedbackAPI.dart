import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackAPI {
  static const String baseUrl = 'https://servicemate.ideonixis.com';

  /// ✅ Submit feedback for a booking
  static Future<Map<String, dynamic>> submitFeedback({
    required String bookingId,
    required int rating,
    required String comment,
    required double totalAmount,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/feedback/submit');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bookingId': bookingId,
          'rating': rating,
          'comment': comment,
          'totalAmount': totalAmount,
        }),
      );

      // Decode response safely
      final Map<String, dynamic> responseData = json.decode(response.body);

      final bool isSuccess =
          response.statusCode == 200 &&
          (responseData["success"] == true ||
              responseData["message"]?.toString().toLowerCase().contains("success") == true);

      return {
        "success": isSuccess,
        "message": responseData["message"] ?? "Unexpected response",
        "data": responseData,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  /// ✅ Fetch all reviews by booking ID
  static Future<List<Map<String, dynamic>>> fetchReviews(String bookingId) async {
    try {
      final uri = Uri.parse('$baseUrl/feedback/reviews/$bookingId'); // 🛠 route adjusted to match REST pattern

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }
}
