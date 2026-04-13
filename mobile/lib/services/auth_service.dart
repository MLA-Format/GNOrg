import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the GNOrg backend.
const String _baseUrl = 'https://gnorg.net/api';

class AuthService {
  /// Registers a new user. Returns null on success, or an error message string.
  static Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({'email': email, 'username': username, 'password': password})),
      );
      debugPrint('[register] status: ${response.statusCode}');
      debugPrint('[register] body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Registration failed';
    } catch (e) {
      debugPrint('[register] exception: $e');
      return 'Something went wrong, please try again';
    }
  }

  /// Logs in a user. Returns null on success (token saved), or an error message.
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({'username': username, 'password': password})),
      );
      debugPrint('[login] status: ${response.statusCode}');
      debugPrint('[login] body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          return null;
        }
        return 'No token received';
      }
      if (response.statusCode == 401) return 'Invalid username or password';
      if (response.statusCode == 403) return 'Please verify your email before logging in';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message'] as String? ?? 'Login failed';
      } catch (_) {
        return 'Login failed (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('[login] exception: $e');
      return 'Login failed: $e';
    }
  }

  /// Verifies an email with the given token. Returns null on success (token saved),
  /// or an error message.
  static Future<String?> verifyEmail(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/verify-email/$token'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authToken = data['token'] as String?;
        if (authToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', authToken);
        }
        return null;
      }
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  /// Returns the stored JWT token, or null if absent / expired.
  static Future<String?> getValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      // Decode payload (second segment) and check expiry.
      final parts = token.split('.');
      if (parts.length != 3) {
        await prefs.remove('token');
        return null;
      }
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null || exp * 1000 <= DateTime.now().millisecondsSinceEpoch) {
        await prefs.remove('token');
        return null;
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  /// Requests a password reset email. Returns null on success, or an error message.
  static Future<String?> requestPasswordReset({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/request-password-reset'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({'email': email})),
      );
      if (response.statusCode == 200) return null;
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = data['message'] as String? ?? '';
        if (msg == 'EMAIL_NOT_FOUND') return 'No account found with that email.';
      } catch (_) {}
      return 'Something went wrong, please try again.';
    } catch (e) {
      return 'Something went wrong, please try again.';
    }
  }

  /// Resets the password using a reset token. Returns null on success, or an error message.
  static Future<String?> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password/$token'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({'password': password})),
      );
      if (response.statusCode == 200) return null;
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = data['message'] as String? ?? '';
        if (msg == 'RESET_TOKEN_EXPIRED') return 'This reset link has expired.';
      } catch (_) {}
      return 'Invalid or already used reset link.';
    } catch (e) {
      return 'Something went wrong, please try again.';
    }
  }

  /// Clears the stored token.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
