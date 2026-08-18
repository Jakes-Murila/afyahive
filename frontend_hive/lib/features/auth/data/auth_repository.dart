import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';

class AuthRepository {
  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api.php?route=v1/auth/login'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw ApiException(
          decoded['message'] as String? ?? 'Unable to sign in.',
          statusCode: response.statusCode,
        );
      }
      return AuthSession.fromJson(decoded['data'] as Map<String, dynamic>);
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

  Future<AuthSession> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) => _authenticate('register', {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'password': password,
  });

  Future<AuthSession> _authenticate(
    String action,
    Map<String, String> body,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api.php?route=v1/auth/$action'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw ApiException(
          decoded['message'] as String? ?? 'Unable to continue.',
          statusCode: response.statusCode,
        );
      }
      return AuthSession.fromJson(decoded['data'] as Map<String, dynamic>);
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

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['accessToken'] as String,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    firstname: json['firstname'] as String,
    lastname: json['lastname'] as String,
    email: json['email'] as String,
  );
}
