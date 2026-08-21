import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../screens/auth/data/auth_session_store.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, AuthSessionStore? sessionStore})
    : _client = client ?? http.Client(),
      _sessionStore = sessionStore ?? const AuthSessionStore();

  final http.Client _client;
  final AuthSessionStore _sessionStore;

  Future<dynamic> get(String route) => _request('GET', route);
  Future<dynamic> post(String route, Map<String, dynamic> body) =>
      _request('POST', route, body: body);
  Future<dynamic> patch(String route, Map<String, dynamic> body) =>
      _request('PATCH', route, body: body);
  Future<dynamic> delete(String route) => _request('DELETE', route);

  Future<dynamic> _request(
    String method,
    String route, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _sessionStore.readToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Your session has expired. Please sign in again.',
      );
    }
    try {
      final request =
          http.Request(
              method,
              Uri.parse('${ApiConfig.baseUrl}/api.php?route=$route'),
            )
            ..headers.addAll({
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            });
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw ApiException(
          decoded['message'] as String? ??
              'The request could not be completed.',
          statusCode: response.statusCode,
        );
      }
      return decoded['data'];
    } on FormatException {
      throw const ApiException('The server returned an invalid response.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to reach AfyaHive. Check your connection.',
      );
    }
  }
}
