/// Data model for a game in the GNOrg collection.
class Game {
  final String id;
  final String name;
  final GamePlayers? players;
  final String? genreCategory;
  final String? genreType;
  final bool? portable;
  final String? coverImage;

  const Game({
    required this.id,
    required this.name,
    this.players,
    this.genreCategory,
    this.genreType,
    this.portable,
    this.coverImage,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    GamePlayers? players;
    final rawPlayers = json['players'];
    if (rawPlayers != null && rawPlayers is Map<String, dynamic>) {
      players = GamePlayers(
        min: rawPlayers['min'] as int?,
        max: rawPlayers['max'] as int?,
        exact: (rawPlayers['exact'] as List<dynamic>?)
            ?.whereType<int>()
            .toList(),
      );
    }

    String? genreCategory;
    String? genreType;
    final rawGenre = json['genre'];
    if (rawGenre != null && rawGenre is Map<String, dynamic>) {
      genreCategory = rawGenre['category'] as String?;
      genreType = rawGenre['type'] as String?;
    }

    return Game(
      id: json['_id'] as String,
      name: json['name'] as String,
      players: players,
      genreCategory: genreCategory,
      genreType: genreType,
      portable: json['portable'] as bool?,
      coverImage: json['coverImage'] as String?,
    );
  }

  /// Single-line text suitable for copying and pasting into a message.
  /// Example: "Catan — 2-4 players, Strategy / Eurogame, not portable"
  String get copyText {
    final details = <String>[];

    if (players != null) {
      final p = players!;
      if (p.exact != null && p.exact!.isNotEmpty) {
        details.add('${p.exact!.join('/')} players');
      } else if (p.min != null && p.max != null) {
        details.add('${p.min}-${p.max} players');
      } else if (p.min != null) {
        details.add('${p.min}+ players');
      } else if (p.max != null) {
        details.add('up to ${p.max} players');
      }
    }

    if (genreCategory != null && genreType != null) {
      details.add('$genreCategory / $genreType');
    } else if (genreCategory != null) {
      details.add(genreCategory!);
    } else if (genreType != null) {
      details.add(genreType!);
    }

    if (portable != null) {
      details.add(portable! ? 'portable' : 'not portable');
    }

    if (details.isEmpty) return name;
    return '$name — ${details.join(', ')}';
  }

  /// Short subtitle shown beneath the game name on its card.
  String get subtitle {
    final parts = <String>[];

    if (players != null) {
      final p = players!;
      if (p.exact != null && p.exact!.isNotEmpty) {
        parts.add('${p.exact!.join('/')} players');
      } else if (p.min != null && p.max != null) {
        parts.add('${p.min}-${p.max} players');
      } else if (p.min != null) {
        parts.add('${p.min}+ players');
      } else if (p.max != null) {
        parts.add('up to ${p.max} players');
      }
    }

    if (genreCategory != null) parts.add(genreCategory!);
    if (genreType != null) parts.add(genreType!);
    if (portable == true) parts.add('portable');

    return parts.join(' · ');
  }
}

class GamePlayers {
  final int? min;
  final int? max;
  final List<int>? exact;

  const GamePlayers({this.min, this.max, this.exact});
}
