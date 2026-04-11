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
}
