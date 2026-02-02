import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use localhost for Web, 10.0.2.2 for Android Emulator
  static const String baseUrl = kDebugMode ? (kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080') : "https://cognify-gouq.onrender.com";
  static const String apiUrl = '${ApiConfig.baseUrl}/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
