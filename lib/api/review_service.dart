import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchReviewsData() async {
  final String baseUrl = "https://servicemate.ideonixis.com"; // your server
  final url = Uri.parse("$baseUrl/reviews");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    
    if (responseData['success'] == true) {
      // Convert List<dynamic> to List<Map<String, dynamic>>
      final List<dynamic> reviewsList = responseData['data'];
      
      print("📊 Total reviews: ${reviewsList.length}");
      return reviewsList.map((review) => review as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load reviews: ${responseData['message']}");
    }
  } else {
    throw Exception("Failed to load reviews: ${response.statusCode}");
  }
}