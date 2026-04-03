import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Config {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrl.isNotEmpty) {
      return _apiBaseUrl;
    }
    return 'http://localhost:8080';
    // return 'http://10.0.2.2:8080';
    // return 'https://management-app-backend-kyhx.onrender.com';
  }
}
