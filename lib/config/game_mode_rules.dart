enum GameModeType { beginner, fun, master }

// game_mode_rules.dart
const Map<GameModeType, Map<String, dynamic>> gameModeRules = {
  GameModeType.beginner: {
    'name': 'Learn',
    'description':
        'Perfect for first-time players. Slower pace and helpful prompts.',
    'startTurnLength': 8.0,
    'endTurnLength': 7.0,
    'takeEventProbability': 0.02,
    'dropEventProbability': 0.02,
    'otherEventProbability': 0.01,
    'strategicEventProbability': 0.0,
    'keyObjectProbability': 0.15,
    'requiredKeyObjectsToWin': 4,
    'minRoundsForFinalKeyObject': 12,
    'keyProbabilityGrowthRounds': 7,
    'requiresEventConfirmation': true,
    'minRoundForStrategicEvents': 999,
    'additionalTimeForEvents': 3.0,
  },
  GameModeType.fun: {
    'name': 'Have Fun',
    'description':
        'Balanced gameplay with exciting events. Recommended for casual players.',
    'startTurnLength': 6.0,
    'endTurnLength': 7.0,
    'takeEventProbability': 0.012,
    'dropEventProbability': 0.01,
    'otherEventProbability': 0.015,
    'strategicEventProbability': 0.0,
    'keyObjectProbability': 0.12,
    'requiredKeyObjectsToWin': 4,
    'minRoundsForFinalKeyObject': 12,
    'keyProbabilityGrowthRounds': 7,
    'requiresEventConfirmation': true,
    'minRoundForStrategicEvents': 6,
    'additionalTimeForEvents': 2.0,
  },
  GameModeType.master: {
    'name': 'Master',
    'description':
        'Challenging gameplay with complex strategic events. For experienced players.',
    'startTurnLength': 6.8,
    'endTurnLength': 6.2,
    'takeEventProbability': 0.01,
    'dropEventProbability': 0.01,
    'otherEventProbability': 0.01,
    'strategicEventProbability': 0.01,
    'keyObjectProbability': 0.10,
    'requiredKeyObjectsToWin': 4,
    'minRoundsForFinalKeyObject': 12,
    'keyProbabilityGrowthRounds': 7,
    'requiresEventConfirmation': false,
    'minRoundForStrategicEvents': 6,
    'additionalTimeForEvents': 1.5,
  },
};
