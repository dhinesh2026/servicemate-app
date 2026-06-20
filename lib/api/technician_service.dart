import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicemate_app/nearby_technicians/technician_model.dart';

class TechnicianService {
  // ⚠️ change this to your system IP (NOT localhost)
  static const String baseUrl = "https://servicemate.ideonixis.com";

  static Future<List<Technician>> fetchNearbyTechnicians() async {
    final response = await http.get(
      Uri.parse("$baseUrl/technicians"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        return (decoded['data'] as List)
            .map((e) => Technician.fromJson(e))
            .toList();
      } else {
        throw Exception("API success false");
      }
    } else {
      throw Exception("Failed to load technicians");
    }
  }
}