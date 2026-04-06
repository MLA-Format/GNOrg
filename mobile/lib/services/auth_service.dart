import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the GNOrg backend.
const String _baseUrl = 'http://100.69.2.138:3000';

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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'username': username, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Registration failed';
    } catch (_) {
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Login failed';
    } catch (_) {
      return 'Login failed due to internal error. Please try again later.';
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

  /// Clears the stored token.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
