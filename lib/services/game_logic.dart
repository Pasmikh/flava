import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/player.dart';
import '../config/theme.dart';

class GameLogic {
  static const List<String> baseObjects = [
    'Шнурок',
    'Червяк',
    'Резинка',
    'Наперсток',
    'Вилка',
    'Ковид',
    'Бусина',
    'Перчик',
    'Прищепка',
    'Головоломка'
  ];

  static const String keyObject = 'Шарик';

  static double calculateGreenProbability(Player player) {
    int greenCount =
        player.greenObjects.values.fold(0, (sum, count) => sum + count);
    int redCount =
        player.redObjects.values.fold(0, (sum, count) => sum + count);

    // Base probability starts at 0.5 and adjusts based on color balance
    return 0.5 - 0.2 * (greenCount - redCount);
  }

  static (String, Color) generateRandomObject({
    required double keyProbability,
    required double greenProbability,
    String? previousObject,
  }) {
    Color color;
    String object;

    color = math.Random().nextDouble() < greenProbability
        ? FlavaTheme.greenObjectColor // green
        : FlavaTheme.redObjectColor; // red

    if (math.Random().nextDouble() < keyProbability) {
      object = keyObject;
    } else {
      do {
        object = baseObjects[math.Random().nextInt(baseObjects.length)];
      } while (previousObject != null && previousObject.contains(object));
    }

    return (object, color);
  }

  static Map<String, double> calculateEventProbabilities(
    GameMode mode,
    int currentRound,
    Map<String, int> eventCounts,
  ) {
    final base = {
      'get': mode.getEventProbability,
      'drop': mode.dropEventProbability,
      'other': mode.otherEventProbability,
      'midgame': mode.midgameEventProbability,
      'strategic': mode.strategicEventProbability,
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
}
