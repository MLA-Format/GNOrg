import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _baseUrl = 'https://gnorg.net/api';

// ── Models ─────────────────────────────────────────────────────────────────────

class Genre {
  final String? category;
  final String? type;
  const Genre({this.category, this.type});

  factory Genre.fromJson(Map<String, dynamic> j) =>
      Genre(category: j['category'] as String?, type: j['type'] as String?);

  Map<String, dynamic> toJson() => {'category': category, 'type': type};
}

class Players {
  final int? min;
  final int? max;
  final List<int>? exact;
  const Players({this.min, this.max, this.exact});

  factory Players.fromJson(Map<String, dynamic> j) => Players(
        min: j['min'] as int?,
        max: j['max'] as int?,
        exact: (j['exact'] as List<dynamic>?)?.map((e) => e as int).toList(),
      );

  Map<String, dynamic> toJson() => {
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        if (exact != null && exact!.isNotEmpty) 'exact': exact,
      };
}

class Game {
  final String id;
  final String name;
  final Players? players;
  final Genre genre;
  final bool? portable;
  final String? coverImage;

  const Game({
    required this.id,
    required this.name,
    this.players,
    required this.genre,
    this.portable,
    this.coverImage,
  });

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: j['_id'] as String,
        name: j['name'] as String,
        players: j['players'] != null
            ? Players.fromJson(j['players'] as Map<String, dynamic>)
            : null,
        genre: j['genre'] != null
            ? Genre.fromJson(j['genre'] as Map<String, dynamic>)
            : const Genre(),
        portable: j['portable'] as bool?,
        coverImage: j['coverImage'] as String?,
      );

  String get playerLabel {
    if (players == null) return '';
    final parts = <String>[];
    if (players!.min != null && players!.max != null) {
      parts.add('${players!.min}–${players!.max}');
    } else if (players!.min != null) {
      parts.add('${players!.min}+');
    } else if (players!.max != null) {
      parts.add('up to ${players!.max}');
    }
    if (players!.exact != null && players!.exact!.isNotEmpty) {
      parts.add(players!.exact!.join(', '));
    }
    return parts.join(' · ');
  }
}

// ── Service ────────────────────────────────────────────────────────────────────

class GameService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Handles token refresh from X-Refreshed-Token header.
  static Future<void> _handleRefresh(http.Response res) async {
    final refreshed = res.headers['x-refreshed-token'];
    if (refreshed != null && refreshed.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', refreshed);
    }
  }

  /// Returns list of games or throws [UnauthorizedException] / [Exception].
  static Future<List<Game>> getGames({
    String? name,
    int? playerCount,
    String? genreCategory,
    bool? portable,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (playerCount != null) body['players'] = {'count': playerCount};
    if (genreCategory != null && genreCategory.isNotEmpty) {
      body['genre'] = {'category': genreCategory};
    }
    if (portable != null) body['portable'] = portable;

    final res = await http.post(
      Uri.parse('$_baseUrl/games/get'),
      headers: headers,
      body: utf8.encode(jsonEncode(body)),
    );
    await _handleRefresh(res);
    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 404) return [];
    if (res.statusCode != 200) throw Exception('Fetch failed');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Creates a new game. Returns null on success, error string on failure.
  static Future<String?> createGame(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/games/create'),
        headers: headers,
        body: utf8.encode(jsonEncode(payload)),
      );
      await _handleRefresh(res);
      if (res.statusCode == 401) return '__unauthorized__';
      if (res.statusCode == 200 || res.statusCode == 201) return null;
      return 'Failed to save. Please try again.';
    } catch (_) {
      return 'Network error. Please try again.';
    }
  }

  /// Edits an existing game. Returns null on success, error string on failure.
  static Future<String?> editGame(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final res = await http.patch(
        Uri.parse('$_baseUrl/games/edit'),
        headers: headers,
        body: utf8.encode(jsonEncode(payload)),
      );
      await _handleRefresh(res);
      if (res.statusCode == 401) return '__unauthorized__';
      if (res.statusCode == 200) return null;
      return 'Failed to save. Please try again.';
    } catch (_) {
      return 'Network error. Please try again.';
    }
  }

  /// Deletes a game by name. Returns null on success, error string on failure.
  static Future<String?> deleteGame(String name) async {
    try {
      final token = await _getToken();
      final res = await http.delete(
        Uri.parse('$_baseUrl/games/delete'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: utf8.encode(jsonEncode({'name': name})),
      );
      await _handleRefresh(res);
      if (res.statusCode == 401) return '__unauthorized__';
      if (res.statusCode == 200) return null;
      return 'Delete failed. Please try again.';
    } catch (_) {
      return 'Network error.';
    }
  }

  /// Uploads a cover image. Returns the URL on success, or null on failure
  /// (sets [error] via callback).
  static Future<String?> uploadImage(
    File file, {
    required void Function(String) onError,
  }) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/games/upload-image'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      await _handleRefresh(res);
      if (res.statusCode == 401) {
        onError('Session expired.');
        return null;
      }
      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          onError(body['error'] == 'FILE_TOO_LARGE'
              ? 'Image must be under 5 MB.'
              : 'Upload failed. Please try again.');
        } catch (_) {
          onError('Upload failed. Please try again.');
        }
        return null;
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['url'] as String?;
    } catch (e) {
      debugPrint('[uploadImage] $e');
      onError('Network error during upload.');
      return null;
    }
  }
}

class UnauthorizedException implements Exception {}
