import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gnorg_mobile/services/game_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'stored-token'});
  });

  test('returns games list on 200', () async {
    final mockGames = [
      {'_id': 'g1', 'name': 'Chess'},
      {'_id': 'g2', 'name': 'Catan', 'portable': false},
    ];
    final client = MockClient((_) async => http.Response(
          jsonEncode(mockGames),
          200,
          headers: {'content-type': 'application/json'},
        ));

    final result = await GameService.getGames(httpClient: client);

    expect(result.length, equals(2));
    expect(result[0].name, equals('Chess'));
    expect(result[1].name, equals('Catan'));
  });

  test('returns empty list on 404 (no games matched)', () async {
    final client = MockClient((_) async => http.Response('', 404));

    final result = await GameService.getGames(httpClient: client);

    expect(result, isEmpty);
  });

  test('throws UnauthorizedException and clears token on 401', () async {
    final client = MockClient((_) async => http.Response('', 401));

    try {
      await GameService.getGames(httpClient: client);
      fail('expected UnauthorizedException');
    } on UnauthorizedException {
      // expected
    }

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
  });

  test('sends Authorization header with stored token', () async {
    String? capturedAuthHeader;
    final client = MockClient((request) async {
      capturedAuthHeader = request.headers['Authorization'];
      return http.Response(jsonEncode([]), 404);
    });

    await GameService.getGames(httpClient: client);

    expect(capturedAuthHeader, equals('Bearer stored-token'));
  });

  test('sends name filter in request body when provided', () async {
    String? capturedBody;
    final client = MockClient((request) async {
      capturedBody = request.body;
      return http.Response(
        jsonEncode([{'_id': 'g1', 'name': 'Chess'}]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await GameService.getGames(name: 'Chess', httpClient: client);

    final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
    expect(body['name'], equals('Chess'));
  });

  test('persists refreshed token from x-refreshed-token header', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode([{'_id': 'g1', 'name': 'Chess'}]),
          200,
          headers: {
            'content-type': 'application/json',
            'x-refreshed-token': 'new-refreshed-token',
          },
        ));

    await GameService.getGames(httpClient: client);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), equals('new-refreshed-token'));
  });

  test('throws exception on unexpected server error', () async {
    final client = MockClient((_) async => http.Response('', 500));

    expect(
      () => GameService.getGames(httpClient: client),
      throwsException,
    );
  });
}
