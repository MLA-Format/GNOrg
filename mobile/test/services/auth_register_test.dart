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
}
