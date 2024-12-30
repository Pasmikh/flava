import '../models/game_mode.dart';
import '../models/player.dart';

class GameAnalytics {
  final int totalGames;
  final int totalRounds;
  final double averageRoundsPerGame;
  final int totalWins;
  final double winRate;
  final Map<GameMode, int> gamesByMode;
  final Map<GameMode, double> averageRoundsByMode;
  final Map<String, int> eventFrequency;
  final Map<String, int> objectFrequency;

  GameAnalytics({
    required this.totalGames,
    required this.totalRounds,
    required this.averageRoundsPerGame,
    required this.totalWins,
    required this.winRate,
    required this.gamesByMode,
    required this.averageRoundsByMode,
    required this.eventFrequency,
    required this.objectFrequency,
  });
}

class AnalyticsService {
  static AnalyticsService? _instance;
  final Map<int, List<Map<String, dynamic>>> _gameResults = {};
  final Map<int, List<Map<String, dynamic>>> _gameEvents = {};
  
  // Private constructor
  AnalyticsService._();
  
  static AnalyticsService get instance {
    return _instance ??= AnalyticsService._();
  }

  void recordGameResult({
    required int gameId,
    required int userId,
    required GameMode gameMode,
    required List<Player> players,
    required int maxRound,
    required int winnerId,
  }) {
    final result = {
      'gameId': gameId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'gameMode': gameMode.toString(),
      'maxRound': maxRound,
      'playerCount': players.length,
      'winnerId': winnerId,
      'players': players.map((p) => p.toJson()).toList(),
    };

    _gameResults.putIfAbsent(userId, () => []).add(result);
  }

  void recordGameEvent({
    required int gameId,
    required int userId,
    required int playerId,
    required String playerName,
    required String eventType,
    required String eventDetails,
    required int round,
  }) {
    final event = {
      'gameId': gameId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'round': round,
      'playerId': playerId,
      'playerName': playerName,
      'eventType': eventType,
      'eventDetails': eventDetails,
    };

    _gameEvents.putIfAbsent(userId, () => []).add(event);
  }

  GameAnalytics getUserAnalytics(int userId) {
    final userGames = _gameResults[userId] ?? [];
    if (userGames.isEmpty) {
      return GameAnalytics(
        totalGames: 0,
        totalRounds: 0,
        averageRoundsPerGame: 0,
        totalWins: 0,
        winRate: 0,
        gamesByMode: {},
        averageRoundsByMode: {},
        eventFrequency: {},
        objectFrequency: {},
      );
    }

    // Calculate basic stats
    final totalGames = userGames.length;
    final totalRounds = userGames.map((g) => g['maxRound'] as int).sum;
    final averageRounds = totalRounds / totalGames;
    final totalWins = userGames.where((g) => g['winnerId'] == userId).length;
    final winRate = totalWins / totalGames;

    // Calculate games by mode
    final gamesByMode = <GameMode, int>{};
    final roundsByMode = <GameMode, List<int>>{};
    for (final game in userGames) {
      final mode = GameMode.values.firstWhere(
        (m) => m.toString() == game['gameMode'],
      );
      gamesByMode[mode] = (gamesByMode[mode] ?? 0) + 1;
      roundsByMode.putIfAbsent(mode, () => []).add(game['maxRound'] as int);
    }

    // Calculate average rounds by mode
    final averageRoundsByMode = <GameMode, double>{};
    roundsByMode.forEach((mode, rounds) {
      averageRoundsByMode[mode] = rounds.average;
    });

    // Calculate event frequency
    final userEvents = _gameEvents[userId] ?? [];
    final eventFrequency = <String, int>{};
    for (final event in userEvents) {
      final type = event['eventType'] as String;
      eventFrequency[type] = (eventFrequency[type] ?? 0) + 1;
    }

    // Calculate object frequency
    final objectFrequency = <String, int>{};
    for (final event in userEvents) {
      final details = event['eventDetails'] as String;
      if (details.contains('_green') || details.contains('_red')) {
        objectFrequency[details] = (objectFrequency[details] ?? 0) + 1;
      }
    }

    return GameAnalytics(
      totalGames: totalGames,
      totalRounds: totalRounds,
      averageRoundsPerGame: averageRounds,
      totalWins: totalWins,
      winRate: winRate,
      gamesByMode: gamesByMode,
      averageRoundsByMode: averageRoundsByMode,
      eventFrequency: eventFrequency,
      objectFrequency: objectFrequency,
    );
  }

  List<Map<String, dynamic>> getRecentGames(int userId, {int limit = 10}) {
    final userGames = _gameResults[userId] ?? [];
    return userGames
        .sorted((a, b) => b['timestamp'].compareTo(a['timestamp']))
        .take(limit)
        .toList();
  }

  Map<String, dynamic> getGameDetails(int userId, int gameId) {
    final userGames = _gameResults[userId] ?? [];
    final game = userGames.firstWhere(
      (g) => g['gameId'] == gameId,
      orElse: () => {},
    );

    if (game.isEmpty) return {};

    final gameEvents = _gameEvents[userId]
        ?.where((e) => e['gameId'] == gameId)
        .toList() ?? [];

    return {
      ...game,
      'events': gameEvents,
    };
  }

  void clearUserData(int userId) {
    _gameResults.remove(userId);
    _gameEvents.remove(userId);
  }

  void clearAllData() {
    _gameResults.clear();
    _gameEvents.clear();
  }
}