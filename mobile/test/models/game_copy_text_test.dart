import 'package:flutter_test/flutter_test.dart';
import 'package:gnorg_mobile/services/game_service.dart';

void main() {
  test('returns just the name when there are no details', () {
    final game = Game(id: '1', name: 'Chess');
    expect(game.copyText, equals('Chess'));
  });

  test('formats min-max player range', () {
    final game = Game(id: '1', name: 'Catan', players: Players(min: 3, max: 6));
    expect(game.copyText, contains('3-6 players'));
  });

  test('formats min-only player count', () {
    final game = Game(id: '1', name: 'Poker', players: Players(min: 2));
    expect(game.copyText, contains('2+ players'));
  });

  test('formats max-only player count', () {
    final game = Game(id: '1', name: 'Solitaire', players: Players(max: 1));
    expect(game.copyText, contains('up to 1 players'));
  });

  test('formats exact player list', () {
    final game = Game(id: '1', name: 'Duel', players: Players(exact: [2]));
    expect(game.copyText, contains('2 players'));
  });

  test('formats category and type together', () {
    final game = Game(
        id: '1', name: 'TI4', genre: Genre(category: 'Strategy', type: 'Space Opera'));
    expect(game.copyText, contains('Strategy / Space Opera'));
  });

  test('formats category-only genre', () {
    final game = Game(id: '1', name: 'Risk', genre: Genre(category: 'Strategy'));
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
      players: Players(min: 3, max: 6),
      genre: Genre(category: 'Strategy', type: 'Eurogame'),
      portable: false,
    );
    expect(game.copyText, equals('Catan \u2014 3-6 players, Strategy / Eurogame, not portable'));
  });
}
