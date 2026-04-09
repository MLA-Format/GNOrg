import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

const String _baseUrl = 'http://143.198.2.194/api';

class GamesService {
  /// Fetches the user's games with optional search/filter criteria.
  ///
  /// Returns a record:
  /// - `games`: matching games (empty list if none), or null on auth failure.
  /// - `unauthorized`: true when the server returned 401 — caller should
  ///   redirect to login.
  static Future<({List<Game>? games, bool unauthorized})> getGames({
    String? name,
    int? playerCount,
    String? genreCategory,
    bool? portable,
    http.Client? httpClient,
  }) async {
    final client = httpClient ?? http.Client();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (playerCount != null) body['players'] = {'count': playerCount};
    if (genreCategory != null && genreCategory.isNotEmpty) {
      body['genre'] = {'category': genreCategory};
    }
    if (portable != null) body['portable'] = portable;

    final response = await client.post(
      Uri.parse('$_baseUrl/games/get'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    // Persist a refreshed token when the server issues one.
    final refreshed = response.headers['x-refreshed-token'];
    if (refreshed != null && refreshed.isNotEmpty) {
      await prefs.setString('token', refreshed);
    }

    if (response.statusCode == 401) {
      await prefs.remove('token');
      return (games: null, unauthorized: true);
    }

    // 404 means no games matched — not a real error.
    if (response.statusCode == 404) {
      return (games: <Game>[], unauthorized: false);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final games = data
          .map((g) => Game.fromJson(g as Map<String, dynamic>))
          .toList();
      return (games: games, unauthorized: false);
    }

    return (games: <Game>[], unauthorized: false);
  }

  /// Calls the server logoff endpoint to invalidate the current token,
  /// then removes it from local storage.
  static Future<void> logoff({http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        await client.get(
          Uri.parse('$_baseUrl/logoff'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (_) {}
    }
    await prefs.remove('token');
  }
}
