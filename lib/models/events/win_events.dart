import 'dart:math' as math;

import 'package:flava/config/constants.dart';

import '../game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> winEvents = [
  createWinDropKeysEvent,
  createWinSwitchHandsEvent,
  createWinGiveTwoEvent,
];

GameEvent createWinDropKeysEvent(GameState state) {
  return GameEvent(
    description:
        'Для победы выложи все ${AppConstants.keyObject}, не уронив другие объекты',
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
    description:
        'Для победы переложи объекты из левой руки в правую и наоборот. '
        'В этот ход можно держать разные цвета вместе.',
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
    description: 'ВСЕ кладут по два объекта перед тобой.'
        'Для победы возьми эти объекты.',
    type: EventType.win,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: 2.0,
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}
