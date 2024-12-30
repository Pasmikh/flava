import 'dart:math' as math;
import '../models/game_mode.dart';
import '../models/player.dart';

class GameLogic {
  static const List<String> baseObjects = [
    'Шнурок', 'Червяк', 'Резинка', 'Наперсток', 'Вилка',
    'Ковид', 'Бусина', 'Перчик', 'Прищепка', 'Головоломка'
  ];

  static const String keyObject = 'Шарик';

  static double calculateTurnLength(GameMode mode, int playerCount, int currentRound) {
    double baseLength = GameModeConfig.initialTurnLengths[mode] ?? 6.0;
    double playerAdjustment = playerCount * 0.2;
    double roundAdjustment = math.min((currentRound - 1) * 0.2, 1.0);
    
    return math.max(baseLength - playerAdjustment + roundAdjustment, 3.0);
  }

  static double calculateKeyProbability(GameMode mode, int currentRound, Player player) {
    double baseProbability = GameModeConfig.keyProbabilities[mode] ?? 0.12;
    double roundModifier = math.max(7, currentRound) / 7;
    
    // Reduce probability if player already has many key objects
    if (player.keyObjectCount >= 3 && currentRound < 12) {
      return 0.0;
    }

    return baseProbability * roundModifier;
  }

  static double calculateGreenProbability(Player player) {
    int greenCount = player.greenObjects.values.fold(0, (sum, count) => sum + count);
    int redCount = player.redObjects.values.fold(0, (sum, count) => sum + count);
    
    // Base probability starts at 0.5 and adjusts based on color balance
    return 0.5 - 0.2 * (greenCount - redCount);
  }

  static String generateRandomObject({
    required bool allowKeyObject,
    required double keyProbability,
    required double greenProbability,
    String? previousObject,
  }) {
    if (allowKeyObject && math.Random().nextDouble() < keyProbability) {
      final color = math.Random().nextDouble() < greenProbability ? 'зеленый' : 'красный';
      return '[color=${_getColorCode(color)}]$keyObject[/color]';
    }

    String newObject;
    do {
      newObject = baseObjects[math.Random().nextInt(baseObjects.length)];
    } while (previousObject != null && 
             previousObject.contains(newObject));

    final color = math.Random().nextDouble() < greenProbability ? 'зеленый' : 'красный';
    return '[color=${_getColorCode(color)}]$newObject[/color]';
  }

  static String _getColorCode(String color) {
    return color == 'зеленый' ? '#27ae60' : '#e74c3c';
  }

  static int calculateNextPlayerIndex(int currentIndex, int playerCount, bool isClockwise) {
    if (isClockwise) {
      return (currentIndex + 1) % playerCount;
    } else {
      return (currentIndex - 1 + playerCount) % playerCount;
    }
  }

  static bool checkWinCondition(Player player) {
    return player.keyObjectCount >= 4;
  }

  static int calculateGameScore(Player player, int maxRounds) {
    int baseScore = player.isWinner ? 1000 : 0;
    int objectScore = player.totalObjectCount * 10;
    int keyScore = player.keyObjectCount * 50;
    int roundPenalty = maxRounds * 5;
    
    return baseScore + objectScore + keyScore - roundPenalty;
  }

  static Map<String, double> calculateEventProbabilities(
    GameMode mode,
    int currentRound,
    Map<String, int> eventCounts,
  ) {
    final base = GameModeConfig.eventProbabilities[mode] ?? {
      'get': 0.012,
      'drop': 0.01,
      'other': 0.015,
      'midgame': 0.007,
      'strategic': 0.007,
    };

    // Adjust probabilities based on event frequency
    final totalEvents = eventCounts.values.fold(0, (sum, count) => sum + count);
    final adjustments = eventCounts.map((type, count) {
      final ratio = totalEvents > 0 ? count / totalEvents : 0.0;
      return MapEntry(type, math.max(0.0, 0.005 * (0.2 - ratio)));
    });

    // Apply round restrictions
    final adjusted = Map<String, double>.from(base);
    adjusted.forEach((type, probability) {
      if ((type == 'drop' && currentRound < 3) ||
          (type == 'other' && currentRound < 5) ||
          ((type == 'midgame' || type == 'strategic') && currentRound < 6)) {
        adjusted[type] = 0.0;
      } else {
        adjusted[type] = probability + (adjustments[type] ?? 0.0);
      }
    });

    return adjusted;
  }

  static int estimateRemainingTurns(Player player) {
    final neededKeys = 4 - player.keyObjectCount;
    final keyProbability = 0.12;  // Average probability
    
    return (neededKeys / keyProbability).ceil();
  }

  static List<String> generateHints(Player player, GameMode mode) {
    final hints = <String>[];
    
    if (player.keyObjectCount < 2 && player.totalObjectCount > 8) {
      hints.add('Consider dropping some objects to maintain control');
    }
    
    if (player.keyObjectCount >= 3) {
      hints.add('You\'re close to winning! Focus on getting one more key object');
    }
    
    if (mode == GameMode.master && player.totalObjectCount < 4) {
      hints.add('Try to maintain a minimum number of objects for strategic events');
    }
    
    return hints;
  }
}