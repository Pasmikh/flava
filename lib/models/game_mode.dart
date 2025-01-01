import 'dart:math' as math;
import '../config/constants.dart';
import '../config/game_mode_rules.dart';

abstract class GameMode {
  // Basic properties
  final String name;
  final String description;

  // Timer configurations
  final double startTurnLength;
  final double endTurnLength;

  // Event probabilities
  final double getEventProbability;
  final double dropEventProbability;
  final double otherEventProbability;
  final double midgameEventProbability;
  final double strategicEventProbability;

  // Key object configuration
  final double keyObjectProbability;
  final int requiredKeyObjectsToWin;
  final int minRoundsForFinalKeyObject;
  final int keyProbabilityGrowthRounds;

  // Game rules
  final bool requiresEventConfirmation;
  final int minRoundForStrategicEvents;
  final double additionalTimeForEvents;

  const GameMode({
    required this.name,
    required this.description,
    required this.startTurnLength,
    required this.endTurnLength,
    required this.getEventProbability,
    required this.dropEventProbability,
    required this.otherEventProbability,
    required this.midgameEventProbability,
    required this.strategicEventProbability,
    required this.keyObjectProbability,
    required this.requiredKeyObjectsToWin,
    required this.minRoundsForFinalKeyObject,
    required this.keyProbabilityGrowthRounds,
    required this.requiresEventConfirmation,
    required this.minRoundForStrategicEvents,
    required this.additionalTimeForEvents,
  });

  // Default methods that can be overridden
  double calculateTurnLength(int playerCount, [int currentRound = 1]) {
    final startTurnLengthAdjusted = startTurnLength -
        (playerCount * AppConstants.turnLengthReductionByPlayersCount);
    final endTurnLengthAdjusted = endTurnLength -
        (playerCount * AppConstants.turnLengthReductionByPlayersCount);

    if (currentRound == 1) return startTurnLengthAdjusted;
    // Interpolate between start and end turn lengths with increment
    return math.min(
        startTurnLengthAdjusted +
            (endTurnLengthAdjusted - startTurnLengthAdjusted) *
                (currentRound - 1) *
                AppConstants.turnLengthIncrement,
        endTurnLengthAdjusted);
  }

  double calculateKeyProbability(int currentRound, int currentKeyCount) {
    // Prevent key object probability if player already has many key objects until round 12
    if (currentKeyCount >= (requiredKeyObjectsToWin - 1) &&
        currentRound < minRoundsForFinalKeyObject) return 0.0;
    // Increase probability with rounds. After round 7, it grows linearly by 1/7 per round.
    return keyObjectProbability *
        (math.max(keyProbabilityGrowthRounds, currentRound) /
            keyProbabilityGrowthRounds);
  }
}

/// Beginner mode
class BeginnerGameMode extends GameMode {
  BeginnerGameMode()
      : super(
          name: gameModeRules[GameModeType.beginner]!['name'],
          description: gameModeRules[GameModeType.beginner]!['description'],
          startTurnLength:
              gameModeRules[GameModeType.beginner]!['startTurnLength'],
          endTurnLength: gameModeRules[GameModeType.beginner]!['endTurnLength'],
          getEventProbability:
              gameModeRules[GameModeType.beginner]!['getEventProbability'],
          dropEventProbability:
              gameModeRules[GameModeType.beginner]!['dropEventProbability'],
          otherEventProbability:
              gameModeRules[GameModeType.beginner]!['otherEventProbability'],
          midgameEventProbability:
              gameModeRules[GameModeType.beginner]!['midgameEventProbability'],
          strategicEventProbability: gameModeRules[GameModeType.beginner]![
              'strategicEventProbability'],
          keyObjectProbability:
              gameModeRules[GameModeType.beginner]!['keyObjectProbability'],
          requiredKeyObjectsToWin:
              gameModeRules[GameModeType.beginner]!['requiredKeyObjectsToWin'],
          minRoundsForFinalKeyObject: gameModeRules[GameModeType.beginner]![
              'minRoundsForFinalKeyObject'],
          keyProbabilityGrowthRounds: gameModeRules[GameModeType.beginner]![
              'keyProbabilityGrowthRounds'],
          requiresEventConfirmation: gameModeRules[GameModeType.beginner]![
              'requiresEventConfirmation'],
          minRoundForStrategicEvents: gameModeRules[GameModeType.beginner]![
              'minRoundForStrategicEvents'],
          additionalTimeForEvents:
              gameModeRules[GameModeType.beginner]!['additionalTimeForEvents'],
        );
}

/// Fun mode
class FunGameMode extends GameMode {
  FunGameMode()
      : super(
          name: gameModeRules[GameModeType.fun]!['name'],
          description: gameModeRules[GameModeType.fun]!['description'],
          startTurnLength: gameModeRules[GameModeType.fun]!['startTurnLength'],
          endTurnLength: gameModeRules[GameModeType.fun]!['endTurnLength'],
          getEventProbability:
              gameModeRules[GameModeType.fun]!['getEventProbability'],
          dropEventProbability:
              gameModeRules[GameModeType.fun]!['dropEventProbability'],
          otherEventProbability:
              gameModeRules[GameModeType.fun]!['otherEventProbability'],
          midgameEventProbability:
              gameModeRules[GameModeType.fun]!['midgameEventProbability'],
          strategicEventProbability:
              gameModeRules[GameModeType.fun]!['strategicEventProbability'],
          keyObjectProbability:
              gameModeRules[GameModeType.fun]!['keyObjectProbability'],
          requiredKeyObjectsToWin:
              gameModeRules[GameModeType.fun]!['requiredKeyObjectsToWin'],
          minRoundsForFinalKeyObject:
              gameModeRules[GameModeType.fun]!['minRoundsForFinalKeyObject'],
          keyProbabilityGrowthRounds:
              gameModeRules[GameModeType.fun]!['keyProbabilityGrowthRounds'],
          requiresEventConfirmation:
              gameModeRules[GameModeType.fun]!['requiresEventConfirmation'],
          minRoundForStrategicEvents:
              gameModeRules[GameModeType.fun]!['minRoundForStrategicEvents'],
          additionalTimeForEvents:
              gameModeRules[GameModeType.fun]!['additionalTimeForEvents'],
        );
}

/// Master mode
class MasterGameMode extends GameMode {
  MasterGameMode()
      : super(
          name: gameModeRules[GameModeType.master]!['name'],
          description: gameModeRules[GameModeType.master]!['description'],
          startTurnLength:
              gameModeRules[GameModeType.master]!['startTurnLength'],
          endTurnLength: gameModeRules[GameModeType.master]!['endTurnLength'],
          getEventProbability:
              gameModeRules[GameModeType.master]!['getEventProbability'],
          dropEventProbability:
              gameModeRules[GameModeType.master]!['dropEventProbability'],
          otherEventProbability:
              gameModeRules[GameModeType.master]!['otherEventProbability'],
          midgameEventProbability:
              gameModeRules[GameModeType.master]!['midgameEventProbability'],
          strategicEventProbability:
              gameModeRules[GameModeType.master]!['strategicEventProbability'],
          keyObjectProbability:
              gameModeRules[GameModeType.master]!['keyObjectProbability'],
          requiredKeyObjectsToWin:
              gameModeRules[GameModeType.master]!['requiredKeyObjectsToWin'],
          minRoundsForFinalKeyObject:
              gameModeRules[GameModeType.master]!['minRoundsForFinalKeyObject'],
          keyProbabilityGrowthRounds:
              gameModeRules[GameModeType.master]!['keyProbabilityGrowthRounds'],
          requiresEventConfirmation:
              gameModeRules[GameModeType.master]!['requiresEventConfirmation'],
          minRoundForStrategicEvents:
              gameModeRules[GameModeType.master]!['minRoundForStrategicEvents'],
          additionalTimeForEvents:
              gameModeRules[GameModeType.master]!['additionalTimeForEvents'],
        );

  @override
  double calculateTurnLength(int playerCount, [int currentRound = 1]) {
    // Example override
    final base = super.calculateTurnLength(playerCount, currentRound);
    final minTurnLength = 3.0;
    final decayFactor = 0.5;
    return minTurnLength +
        (base - minTurnLength) * math.exp(-decayFactor * currentRound);
  }

  @override
  double calculateKeyProbability(int currentRound, int currentKeyCount) {
    final base = super.calculateKeyProbability(currentRound, currentKeyCount);
    return base * (1 + currentRound / 20);
  }
}
