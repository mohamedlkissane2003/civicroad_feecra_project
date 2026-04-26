import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class CivicRoadApi {
  const CivicRoadApi._();

  static const String _defaultAndroidBaseUrl = 'http://10.0.2.2:4000';
  static const String _defaultOtherBaseUrl = 'http://localhost:4000';

  static String get baseUrl {
    const overrideUrl = String.fromEnvironment('CIVICROAD_API_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    if (kIsWeb) {
      return _defaultOtherBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _defaultAndroidBaseUrl;
      default:
        return _defaultOtherBaseUrl;
    }
  }

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<List<Map<String, dynamic>>> fetchPublicReports() async {
    final response = await http.get(_uri('/api/public/reports'));
    if (response.statusCode >= 400) {
      throw Exception('Unable to load reports');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<Map<String, dynamic>> submitReport({
    required String title,
    required String description,
    required String category,
    required String severity,
    required String userName,
    Uint8List? imageBytes,
    String? imageName,
    LatLng? location,
    String? locationText,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'user_name': userName,
      'location_text': locationText,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      if (imageBytes != null) 'image_url': _toDataUrl(imageBytes, imageName),
    };

    final response = await http.post(
      _uri('/api/reports'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('Unable to submit report');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return Map<String, dynamic>.from(decoded as Map);
  }

  static String _toDataUrl(Uint8List bytes, String? imageName) {
    final extension = imageName?.toLowerCase().split('.').last;
    final mimeType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
}