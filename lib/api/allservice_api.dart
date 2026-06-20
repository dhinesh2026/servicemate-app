import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicemate_app/all_services/service_model.dart';

class ServiceApi {
  static Future<List<ServiceModel>> fetchServices() async {
    final res = await http.get(
      Uri.parse("https://servicemate.ideonixis.com/api/alllistservice"),
    );

    if (res.statusCode != 200) {
      return [];
    }

    final decoded = json.decode(res.body);

    // 🔥 VERY IMPORTANT SAFE CHECKS
    if (decoded == null) return [];

    if (decoded is List) {
      // 👈 backend direct array send pannina
      return decoded
          .map<ServiceModel>((e) => ServiceModel.fromJson(e))
          .toList();
    }

    if (decoded is Map && decoded["data"] is List) {
      return (decoded["data"] as List)
          .map<ServiceModel>((e) => ServiceModel.fromJson(e))
          .toList();
    }

    return [];
  }
}

