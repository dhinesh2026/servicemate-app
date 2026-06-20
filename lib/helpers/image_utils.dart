// image_utils.dart
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ImageUtils {
  static String getCacheBustingUrl(String url) {
    if (url.isEmpty) return url;
    
    try {
      // Add a timestamp parameter to bust the cache
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error creating cache busting URL: $e');
      return url; // Return original URL if there's an error
    }
  }
  
  static Future<void> preloadImage(String url, BuildContext context) async {
    if (url.isEmpty) return;
    
    try {
      final cacheBustedUrl = getCacheBustingUrl(url);
      await precacheImage(NetworkImage(cacheBustedUrl), context);
    } catch (e) {
      print('Error preloading image: $e');
    }
  }
  
  // Helper method to check if a file exists
  static Future<bool> fileExists(String path) async {
    try {
      if (path.isEmpty) return false;
      final file = File(path);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }
  
  // Helper method to check if a network image is accessible
  static Future<bool> isNetworkImageAccessible(String url) async {
    if (url.isEmpty) return false;
    
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Network image not accessible: $e');
      return false;
    }
  }
}