import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/player.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class GameLogic {
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
      object = AppConstants.keyObject;
    } else {
      do {
        object = AppConstants.baseObjects[
            math.Random().nextInt(AppConstants.baseObjects.length)];
      } while (previousObject != null && previousObject.contains(object));
    }

    return (object, color);
  }
}
