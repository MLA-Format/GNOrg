import 'package:flutter_test/flutter_test.dart';
import 'package:gnorg_mobile/services/game_service.dart';

void main() {
  test('parses a full game object', () {
    final json = {
      '_id': 'abc123',
      'name': 'Catan',
      'players': {'min': 3, 'max': 6},
      'genre': {'category': 'Strategy', 'type': 'Eurogame'},
      'portable': false,
      'coverImage': 'http://example.com/catan.jpg',
    };

    final game = Game.fromJson(json);

    expect(game.id, equals('abc123'));
    expect(game.name, equals('Catan'));
    expect(game.players?.min, equals(3));
    expect(game.players?.max, equals(6));
    expect(game.genre.category, equals('Strategy'));
    expect(game.genre.type, equals('Eurogame'));
    expect(game.portable, isFalse);
    expect(game.coverImage, equals('http://example.com/catan.jpg'));
  });

  test('parses a minimal game with only required fields', () {
    final json = {'_id': 'xyz', 'name': 'Chess'};

    final game = Game.fromJson(json);

    expect(game.id, equals('xyz'));
    expect(game.name, equals('Chess'));
    expect(game.players, isNull);
    expect(game.genre.category, isNull);
    expect(game.genre.type, isNull);
    expect(game.portable, isNull);
    expect(game.coverImage, isNull);
  });

  test('parses exact player counts', () {
    final json = {
      '_id': 'g1',
      'name': 'Duel',
      'players': {'exact': [2]},
    };

    final game = Game.fromJson(json);

    expect(game.players?.exact, equals([2]));
    expect(game.players?.min, isNull);
    expect(game.players?.max, isNull);
  });

  test('parses min-only player count', () {
    final json = {
      '_id': 'g1',
      'name': 'Poker',
      'players': {'min': 2},
    };

    final game = Game.fromJson(json);

    expect(game.players?.min, equals(2));
    expect(game.players?.max, isNull);
  });
}
