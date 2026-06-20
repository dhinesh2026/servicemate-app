// Create this file: helpers/image_helper.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  
  /// Convert base64 data URL or regular URL to Image widget
  static Widget buildImageFromData(String imageData, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    
    if (imageData.isEmpty) {
      return errorWidget ?? _buildDefaultAvatar(width, height);
    }
    
    try {
      // Check if it's base64 data URL (e.g., "data:image/jpeg;base64,/9j/4AAQ...")
      if (imageData.startsWith('data:image')) {
        // Extract base64 data (remove "data:image/jpeg;base64," prefix)
        final base64String = imageData.split(',')[1];
        final Uint8List bytes = base64Decode(base64String);
        
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Base64 image decode error: $error');
            return errorWidget ?? _buildDefaultAvatar(width, height);
          },
        );
      } 
      // If it's a regular URL (e.g., "https://example.com/image.jpg")
      else if (imageData.startsWith('http')) {
        return Image.network(
          imageData,
          width: width,
          height: height,
          fit: fit,
          headers: {"Cache-Control": "no-cache"}, // Prevent caching issues
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(width > height ? height/2 : width/2),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Network image error: $error');
            return errorWidget ?? _buildDefaultAvatar(width, height);
          },
        );
      }
      // If it's just base64 without data URL prefix
      else {
        final Uint8List bytes = base64Decode(imageData);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Pure base64 decode error: $error');
            return errorWidget ?? _buildDefaultAvatar(width, height);
          },
        );
      }
    } catch (e) {
      print('❌ Image helper error: $e');
      return errorWidget ?? _buildDefaultAvatar(width, height);
    }
  }
  
  /// Build a default avatar when no image is available
  static Widget _buildDefaultAvatar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(width > height ? height/2 : width/2),
      ),
      child: Icon(
        Icons.person,
        size: (width > height ? height : width) * 0.5,
        color: Colors.white,
      ),
    );
  }
  
  /// Check if the image data is base64
  static bool isBase64Data(String imageData) {
    return imageData.startsWith('data:image') || 
           (!imageData.startsWith('http') && imageData.isNotEmpty);
  }
  
  /// Check if the image data is a network URL
  static bool isNetworkUrl(String imageData) {
    return imageData.startsWith('http');
  }
}