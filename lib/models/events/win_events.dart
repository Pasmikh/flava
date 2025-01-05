import 'dart:math' as math;

import '../game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> winEvents = [
  createWinDropKeysEvent,
  createWinSwitchHandsEvent,
  createWinGiveTwoEvent,
];

GameEvent createWinDropKeysEvent(GameState state) {
  return GameEvent(
    description: 'To win, drop all key objects without dropping other objects',
    type: EventType.win,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: 1.0,
    executeEvent: (currentState, _) {
      // Original logic just sets up the win condition
      // Actual win checking would not be handled in tracking
      return currentState;
    },
  );
}

GameEvent createWinSwitchHandsEvent(GameState state) {
  return GameEvent(
    description: 'To win, switch objects between hands. '
        'You can hold different colors together during this turn.',
    type: EventType.win,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: math.min(state.currentRound * 1.3, 16.0),
    executeEvent: (currentState, _) {
      // Original logic just sets up the win condition
      // Actual win checking would not be handled in tracking
      return currentState;
    },
  );
}

GameEvent createWinGiveTwoEvent(GameState state) {
  return GameEvent(
    description: 'ALL players place two objects in front of you. '
        'To win, take these objects.',
    type: EventType.win,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: 2.0,
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}
