import 'package:flutter_test/flutter_test.dart';
import 'package:gnorg_mobile/services/game_service.dart';

void main() {
  test('returns empty string when there are no details', () {
    final game = Game(id: '1', name: 'Chess');
    expect(game.subtitle, equals(''));
  });

  test('includes player range', () {
    final game = Game(id: '1', name: 'Catan', players: Players(min: 3, max: 6));
    expect(game.subtitle, contains('3-6 players'));
  });

  test('includes genre category', () {
    final game = Game(id: '1', name: 'Risk', genre: Genre(category: 'Strategy'));
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
      players: Players(min: 3, max: 6),
      genre: Genre(category: 'Strategy'),
    );
    expect(game.subtitle, equals('3-6 players · Strategy'));
  });
}
