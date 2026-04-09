import 'package:flutter_test/flutter_test.dart';
import 'package:gnorg_mobile/models/game.dart';

void main() {
  group('Game.fromJson', () {
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
      expect(game.genreCategory, equals('Strategy'));
      expect(game.genreType, equals('Eurogame'));
      expect(game.portable, isFalse);
      expect(game.coverImage, equals('http://example.com/catan.jpg'));
    });

    test('parses a minimal game with only required fields', () {
      final json = {'_id': 'xyz', 'name': 'Chess'};

      final game = Game.fromJson(json);

      expect(game.id, equals('xyz'));
      expect(game.name, equals('Chess'));
      expect(game.players, isNull);
      expect(game.genreCategory, isNull);
      expect(game.genreType, isNull);
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
  });

  group('Game.copyText', () {
    test('returns just the name when there are no details', () {
      final game = Game(id: '1', name: 'Chess');
      expect(game.copyText, equals('Chess'));
    });

    test('formats min-max player range', () {
      final game = Game(id: '1', name: 'Catan', players: GamePlayers(min: 3, max: 6));
      expect(game.copyText, contains('3-6 players'));
    });

    test('formats min-only player count', () {
      final game = Game(id: '1', name: 'Poker', players: GamePlayers(min: 2));
      expect(game.copyText, contains('2+ players'));
    });

    test('formats max-only player count', () {
      final game = Game(id: '1', name: 'Solitaire', players: GamePlayers(max: 1));
      expect(game.copyText, contains('up to 1 players'));
    });

    test('formats exact player list', () {
      final game = Game(id: '1', name: 'Duel', players: GamePlayers(exact: [2]));
      expect(game.copyText, contains('2 players'));
    });

    test('formats category and type together', () {
      final game = Game(id: '1', name: 'TI4', genreCategory: 'Strategy', genreType: 'Space Opera');
      expect(game.copyText, contains('Strategy / Space Opera'));
    });

    test('formats category-only genre', () {
      final game = Game(id: '1', name: 'Risk', genreCategory: 'Strategy');
      expect(game.copyText, contains('Strategy'));
      expect(game.copyText, isNot(contains('/')));
    });

    test('formats portable flag as "portable"', () {
      final game = Game(id: '1', name: 'Travel Chess', portable: true);
      expect(game.copyText, contains('portable'));
    });

    test('formats non-portable flag as "not portable"', () {
      final game = Game(id: '1', name: 'Catan', portable: false);
      expect(game.copyText, contains('not portable'));
    });

    test('formats a complete game correctly', () {
      final game = Game(
        id: '1',
        name: 'Catan',
        players: GamePlayers(min: 3, max: 6),
        genreCategory: 'Strategy',
        genreType: 'Eurogame',
        portable: false,
      );
      expect(game.copyText, equals('Catan — 3-6 players, Strategy / Eurogame, not portable'));
    });
  });

  group('Game.subtitle', () {
    test('returns empty string when there are no details', () {
      final game = Game(id: '1', name: 'Chess');
      expect(game.subtitle, equals(''));
    });

    test('includes player range', () {
      final game = Game(id: '1', name: 'Catan', players: GamePlayers(min: 3, max: 6));
      expect(game.subtitle, contains('3-6 players'));
    });

    test('includes genre category', () {
      final game = Game(id: '1', name: 'Risk', genreCategory: 'Strategy');
      expect(game.subtitle, contains('Strategy'));
    });

    test('includes portable badge only when true', () {
      final portableGame = Game(id: '1', name: 'Travel Chess', portable: true);
      final nonPortableGame = Game(id: '2', name: 'Catan', portable: false);

      expect(portableGame.subtitle, contains('portable'));
      expect(nonPortableGame.subtitle, isNot(contains('portable')));
    });

    test('joins multiple details with middot', () {
      final game = Game(
        id: '1',
        name: 'Catan',
        players: GamePlayers(min: 3, max: 6),
        genreCategory: 'Strategy',
      );
      expect(game.subtitle, equals('3-6 players · Strategy'));
    });
  });
}
