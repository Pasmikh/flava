import 'dart:math' as math;

import '../game_state.dart';
import '../game_event.dart';
import '../../config/constants.dart';

final List<StrategicEvent Function(GameState)> strategicEvents = [
  createTakeObjectFutureTakeKeyEvent,
  createTakeObjectFutureDropKeyEvent,
];

class StrategicEvent extends GameEvent {
  final int triggerRound;
  final int roundsAhead;
  final int triggerPlayerIndex;
  final GameEvent executionEvent;

  const StrategicEvent({
    required this.triggerRound,
    required this.roundsAhead,
    required this.triggerPlayerIndex,
    required this.executionEvent,
    required super.description,
    required super.type,
    required super.choices,
    required super.requiresConfirmation,
    super.additionalTime = 0,
    required super.executeEvent,
  });

  @override
  GameState execute(GameState state, int? choiceIndex) {
    if (choiceIndex == null) return state;

    // Store the strategic event data for later execution
    final List<StrategicEvent> updatedScheduledEvents = [
      ...state.scheduledEvents,
      this,
    ];

    return state.copyWith(GameStateUpdate(
      scheduledEvents: updatedScheduledEvents,
    ));
  }
}

StrategicEvent createTakeObjectFutureTakeKeyEvent(GameState state) {
  final roundsAhead = math.Random().nextInt(3) + 2;
  // Randomly choose red or green for both current and future trigger
  final currentObject = AppConstants
      .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];
  final futureObject = AppConstants
      .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];

  // Create the execution event that will trigger in the future
  final executionEvent = GameEvent(
    description: 'ВСЕ игроки с $futureObject берут ${AppConstants.keyObject}',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
    executeEvent: (futureState, _) {
      final updatedPlayers = futureState.players.map((player) {
        if ((player.redObjects[futureObject] ?? 0) +
                (player.greenObjects[futureObject] ?? 0) >
            0) {
          return player.copyWith()..addKeyObject();
        }
        return player;
      }).toList();

      return futureState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );

  // Create the initial strategic event
  return StrategicEvent(
    description:
        'Возьми $currentObject. Все игроки с $futureObject через $roundsAhead раунда возьмут ${AppConstants.keyObject}',
    type: EventType.strategic,
    choices: EventChoices(['Confirm'], (str) => str),
    requiresConfirmation: true,
    triggerRound: state.currentRound + roundsAhead,
    roundsAhead: roundsAhead,
    triggerPlayerIndex: state.currentPlayerIndex,
    executionEvent: executionEvent,
    executeEvent: (currentState, _) {
      // Add the initial object to the current player
      // final updatedPlayer = currentState.currentPlayer.copyWith()
      //   ..addObject(currentObject, 'green');
      // return currentState.copyWith(GameStateUpdate(
      //   players: currentState.players.updatePlayer(updatedPlayer),
      // ));
      return currentState;
    },
  );
}

StrategicEvent createTakeObjectFutureDropKeyEvent(GameState state) {
  final roundsAhead = math.Random().nextInt(3) + 2;
  final currentObject = AppConstants
      .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];
  final futureObject = AppConstants
      .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];

  // Create the execution event that will trigger in the future
  final executionEvent = GameEvent(
    description:
        'ВСЕ игроки с $futureObject сбрасывают ${AppConstants.keyObject}',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
    executeEvent: (futureState, _) {
      final updatedPlayers = futureState.players.map((player) {
        if ((player.redObjects[futureObject] ?? 0) +
                (player.greenObjects[futureObject] ?? 0) >
            0) {
          return player.copyWith()..removeKeyObject();
        }
        return player;
      }).toList();

      return futureState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );

  // Create the initial strategic event
  return StrategicEvent(
    description:
        'Возьми $currentObject. Все игроки с $futureObject через $roundsAhead раунда сбросят ${AppConstants.keyObject}',
    type: EventType.strategic,
    choices: EventChoices(['Confirm'], (str) => str),
    requiresConfirmation: true,
    triggerRound: state.currentRound + roundsAhead,
    roundsAhead: roundsAhead,
    triggerPlayerIndex: state.currentPlayerIndex,
    executionEvent: executionEvent,
    executeEvent: (currentState, _) {
      // Add the initial object to the current player
      // final updatedPlayer = currentState.currentPlayer.copyWith()
      //   ..addObject(currentObject, currentColor);
      // return currentState.copyWith(GameStateUpdate(
      //   players: currentState.players.updatePlayer(updatedPlayer),
      // ));
      return currentState;
    },
  );
}
