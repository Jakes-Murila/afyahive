import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://localhost/afyahive';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2/afyahive'
        : 'http://127.0.0.1/afyahive';
  }
}
