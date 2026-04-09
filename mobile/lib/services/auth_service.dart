import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _baseUrl = 'http://143.198.2.194/api';

class AuthService {
  // ── Registration ──────────────────────────────────────────────────────────

  /// Registers a new user. Returns null on success, or a human-readable error.
  static Future<String?> register({
    required String email,
    required String username,
    required String password,
    http.Client? httpClient,
  }) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['message'] as String? ?? '';
      return switch (code) {
        'USER_TAKEN' => 'Username is already taken',
        'EMAIL_TAKEN' => 'Email is already registered',
        'PASSWORD_TOO_SHORT' => 'Password must be at least 8 characters',
        _ => code.isNotEmpty ? code : 'Registration failed',
      };
    } catch (_) {
      return 'Something went wrong, please try again';
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Logs in a user. Returns null on success (token saved), or a human-readable error.
  static Future<String?> login({
    required String username,
    required String password,
    http.Client? httpClient,
  }) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.post(
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

      // 403 returns { "error": "EMAIL_NOT_VERIFIED" }, not { "message": ... }
      if (response.statusCode == 403) {
        final code = data['error'] as String? ?? '';
        if (code == 'EMAIL_NOT_VERIFIED') {
          return 'Please verify your email before signing in';
        }
      }

      final code = data['message'] as String? ?? '';
      return code.isNotEmpty ? code : 'Invalid username or password';
    } catch (_) {
      return 'Login failed, please try again later';
    }
  }

  // ── Email verification ────────────────────────────────────────────────────

  /// Verifies an email with the given token. Returns null on success (auth token
  /// saved to SharedPreferences), or a non-null string on error.
  static Future<String?> verifyEmail(String token, {http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.get(
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

  // ── Password reset ────────────────────────────────────────────────────────

  /// Sends a password-reset email to [email]. Returns null on success, or a
  /// human-readable error string.
  static Future<String?> requestPasswordReset(String email, {http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['message'] as String? ?? '';
      if (code == 'RESET_ALREADY_SENT') {
        return 'A reset link was already sent. Please check your inbox.';
      }
      return code.isNotEmpty ? code : 'Failed to send reset email';
    } catch (_) {
      return 'Something went wrong, please try again';
    }
  }

  /// Sets a new password using the reset [token] from the email link.
  /// Returns null on success, or a human-readable error string.
  static Future<String?> resetPassword({
    required String token,
    required String password,
    http.Client? httpClient,
  }) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/reset-password/$token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['message'] as String? ?? '';
      return switch (code) {
        'RESET_TOKEN_EXPIRED' => 'This reset link has expired',
        'RESET_TOKEN_INVALID' => 'Invalid reset link',
        'PASSWORD_TOO_SHORT' => 'Password must be at least 8 characters',
        _ => code.isNotEmpty ? code : 'Failed to reset password',
      };
    } catch (_) {
      return 'Something went wrong, please try again';
    }
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  /// Returns the stored JWT token if present and not expired, or null.
  static Future<String?> getValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) {
        await prefs.remove('token');
        return null;
      }
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null ||
          exp * 1000 <= DateTime.now().millisecondsSinceEpoch) {
        await prefs.remove('token');
        return null;
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  /// Clears the stored token from local storage.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
