import 'dart:math' as math;

import '../../extensions/player_list_extension.dart';
import '../game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> otherEvents = [
  createSwitchHandsEvent, // event_switch_hands
  createGiveOneRightEvent, // event_give_1_right
  createGiveOneLeftEvent, // event_give_1_left
  createGiveOneAnyEvent, // event_give_1_any
  createStealKeyEvent, // event_steal_key
  createExchangeHandsRedEvent, // event_exchange_hands_with_player_red
  createExchangeHandsGreenEvent, // event_exchange_hands_with_player_green
];

GameEvent createSwitchHandsEvent(GameState state) {
  return GameEvent(
    description: 'ALL players switch objects between hands. '
        'You can hold different colors together during this turn.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: math.min(state.currentRound * 1.5, 12.0),
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}

GameEvent createGiveOneRightEvent(GameState state) {
  return GameEvent(
    description:
        'ALL players place an object in front of the player to their RIGHT. '
        'After timer starts, take the object in front of you.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: -1.0, // Reduces available time
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}

GameEvent createGiveOneLeftEvent(GameState state) {
  return GameEvent(
    description:
        'ALL players place an object in front of the player to their LEFT. '
        'After timer starts, take the object in front of you.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: -1.0,
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}

GameEvent createGiveOneAnyEvent(GameState state) {
  return GameEvent(
    description: 'ALL players place an object in front of ANY player. '
        'After timer starts, take the object in front of you.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    additionalTime: -1.0,
    executeEvent: (currentState, _) {
      return currentState;
    },
  );
}

GameEvent createStealKeyEvent(GameState state) {
  final choices = EventChoices(
    state.players
        .where((p) => p.id != state.currentPlayer.id && !p.isEliminated)
        .toList(),
    (player) => player.name,
  );

  return GameEvent(
    description: 'Choose a player. If they have a key object, '
        'they place it in front of you. After timer starts, take it.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: choices,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex].copyWith();
      final currentPlayer = currentState.currentPlayer.copyWith();

      if (targetPlayer.keyObjectCount > 0) {
        targetPlayer.removeKeyObject();
        currentPlayer.addKeyObject();
      }

      final updatedPlayers =
          currentState.players.updatePlayers([targetPlayer, currentPlayer]);

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createExchangeHandsRedEvent(GameState state) {
  final choices = EventChoices(
    state.players
        .where((p) => p.id != state.currentPlayer.id && !p.isEliminated)
        .toList(),
    (player) => player.name,
  );

  return GameEvent(
    description: 'Choose a player. You will exchange all your red objects.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: choices,
    additionalTime: 2.0,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex].copyWith();
      final currentPlayer = currentState.currentPlayer.copyWith();

      // Exchange red objects
      final currentPlayerRed = Map<String, int>.from(currentPlayer.redObjects);
      currentPlayer.redObjects = Map<String, int>.from(targetPlayer.redObjects);
      targetPlayer.redObjects = currentPlayerRed;

      final updatedPlayers =
          currentState.players.updatePlayers([targetPlayer, currentPlayer]);

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createExchangeHandsGreenEvent(GameState state) {
  final choices = EventChoices(
    state.players
        .where((p) => p.id != state.currentPlayer.id && !p.isEliminated)
        .toList(),
    (player) => player.name,
  );

  return GameEvent(
    description: 'Choose a player. You will exchange all your green objects.',
    type: EventType.other,
    requiresConfirmation: true,
    choices: choices,
    additionalTime: 2.0,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex].copyWith();
      final currentPlayer = currentState.currentPlayer.copyWith();

      // Exchange green objects
      final currentPlayerGreen =
          Map<String, int>.from(currentPlayer.greenObjects);
      currentPlayer.greenObjects =
          Map<String, int>.from(targetPlayer.greenObjects);
      targetPlayer.greenObjects = currentPlayerGreen;

      final updatedPlayers =
          currentState.players.updatePlayers([targetPlayer, currentPlayer]);

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}
