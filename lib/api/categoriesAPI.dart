import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchServiceData(String serviceName) async {
  final String baseUrl = "https://servicemate.ideonixis.com/api"; // your server
  final url = Uri.parse("$baseUrl/services/${Uri.encodeComponent(serviceName)}");

  final response = await http.get(url);

  print("final response: $response");

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to load service data: ${response.statusCode}");
  }
}
