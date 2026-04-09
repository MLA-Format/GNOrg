import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gnorg_mobile/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── login ────────────────────────────────────────────────────────────────

  group('AuthService.login', () {
    test('saves token and returns null on success', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'token': 'jwt-abc'}),
            200,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.login(
        username: 'testuser',
        password: 'password123',
        httpClient: client,
      );

      expect(result, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), equals('jwt-abc'));
    });

    test('returns error message on invalid credentials (401)', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'INVALID_CREDENTIALS'}),
            401,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.login(
        username: 'testuser',
        password: 'wrongpass',
        httpClient: client,
      );

      expect(result, equals('INVALID_CREDENTIALS'));
    });

    test('returns human-readable message when email is not verified (403)', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'error': 'EMAIL_NOT_VERIFIED'}),
            403,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.login(
        username: 'testuser',
        password: 'pass123',
        httpClient: client,
      );

      expect(result, equals('Please verify your email before signing in'));
    });

    test('returns fallback error on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      final result = await AuthService.login(
        username: 'testuser',
        password: 'pass123',
        httpClient: client,
      );

      expect(result, equals('Login failed, please try again later'));
    });
  });

  // ── register ─────────────────────────────────────────────────────────────

  group('AuthService.register', () {
    test('returns null on successful registration', () async {
      final client = MockClient((_) async => http.Response('', 201));

      final result = await AuthService.register(
        email: 'new@example.com',
        username: 'newuser',
        password: 'password123',
        httpClient: client,
      );

      expect(result, isNull);
    });

    test('returns username taken message for USER_TAKEN', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'USER_TAKEN'}),
            400,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.register(
        email: 'new@example.com',
        username: 'takenuser',
        password: 'password123',
        httpClient: client,
      );

      expect(result, equals('Username is already taken'));
    });

    test('returns email registered message for EMAIL_TAKEN', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'EMAIL_TAKEN'}),
            400,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.register(
        email: 'taken@example.com',
        username: 'newuser',
        password: 'password123',
        httpClient: client,
      );

      expect(result, equals('Email is already registered'));
    });

    test('returns password too short message for PASSWORD_TOO_SHORT', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'PASSWORD_TOO_SHORT'}),
            400,
            headers: {'content-type': 'application/json'},
          ));

      final result = await AuthService.register(
        email: 'new@example.com',
        username: 'newuser',
        password: 'short',
        httpClient: client,
      );

      expect(result, equals('Password must be at least 8 characters'));
    });

    test('returns fallback error on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      final result = await AuthService.register(
        email: 'new@example.com',
        username: 'newuser',
        password: 'password123',
        httpClient: client,
      );

      expect(result, equals('Something went wrong, please try again'));
    });
  });

  // ── getValidToken ─────────────────────────────────────────────────────────

  group('AuthService.getValidToken', () {
    test('returns null when no token is stored', () async {
      final result = await AuthService.getValidToken();
      expect(result, isNull);
    });

    test('returns null and clears token when token is expired', () async {
      // Expired token: exp set to 1 (Unix epoch 1970)
      final payload = base64Url.encode(
        utf8.encode(jsonEncode({'exp': 1, 'type': 'auth'})),
      );
      final expiredToken = 'header.$payload.signature';
      SharedPreferences.setMockInitialValues({'token': expiredToken});

      final result = await AuthService.getValidToken();

      expect(result, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), isNull);
    });

    test('returns token when it is valid and not expired', () async {
      final futureExp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payload = base64Url.encode(
        utf8.encode(jsonEncode({'exp': futureExp, 'type': 'auth'})),
      );
      final validToken = 'header.$payload.signature';
      SharedPreferences.setMockInitialValues({'token': validToken});

      final result = await AuthService.getValidToken();

      expect(result, equals(validToken));
    });

    test('returns null and clears malformed token', () async {
      SharedPreferences.setMockInitialValues({'token': 'not.a.valid.jwt.format'});

      final result = await AuthService.getValidToken();

      expect(result, isNull);
    });
  });
}
