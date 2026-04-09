import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gnorg_mobile/services/games_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'stored-token'});
  });

  group('GamesService.getGames', () {
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

      final result = await GamesService.getGames(httpClient: client);

      expect(result.unauthorized, isFalse);
      expect(result.games, isNotNull);
      expect(result.games!.length, equals(2));
      expect(result.games![0].name, equals('Chess'));
      expect(result.games![1].name, equals('Catan'));
    });

    test('returns empty list on 404 (no games matched)', () async {
      final client = MockClient((_) async => http.Response('', 404));

      final result = await GamesService.getGames(httpClient: client);

      expect(result.unauthorized, isFalse);
      expect(result.games, isEmpty);
    });

    test('returns unauthorized:true and clears token on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));

      final result = await GamesService.getGames(httpClient: client);

      expect(result.unauthorized, isTrue);
      expect(result.games, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), isNull);
    });

    test('sends Authorization header with stored token', () async {
      String? capturedAuthHeader;
      final client = MockClient((request) async {
        capturedAuthHeader = request.headers['Authorization'];
        return http.Response(jsonEncode([]), 404);
      });

      await GamesService.getGames(httpClient: client);

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

      await GamesService.getGames(name: 'Chess', httpClient: client);

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

      await GamesService.getGames(httpClient: client);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), equals('new-refreshed-token'));
    });

    test('returns empty list on unexpected server error', () async {
      final client = MockClient((_) async => http.Response('', 500));

      final result = await GamesService.getGames(httpClient: client);

      expect(result.unauthorized, isFalse);
      expect(result.games, isEmpty);
    });
  });
}
