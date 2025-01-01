import 'dart:math' as math;

import '../../config/constants.dart';
import '../../extensions/player_list_extension.dart';
import '../player.dart';
import '../game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> getEvents = [
  createGetThreeEvent,
  createGetThreeWarmupEvent,
  createGetAllGetOneEvent,
  createGetAllGetKeyEvent,
  createGetTwoEvent,
  createGetKeyObjectEvent,
];

GameEvent createGetThreeEvent(GameState state) {
  final List<Player> eligiblePlayers = state.players
      .where((p) => p.id != state.currentPlayer.id && !p.isEliminated)
      .toList();

  final choices = EventChoices(
    eligiblePlayers,
    (player) => player.name,
  );

  return GameEvent(
    description: 'Choose a player. They will take a red object, '
        'a green object, and a key object',
    type: EventType.get,
    requiresConfirmation: true,
    choices: choices,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex];
      final updatedPlayers =
          currentState.players.updatePlayer(targetPlayer.copyWith()
            ..addObject('random', 'red')
            ..addObject('random', 'green')
            ..addKeyObject());

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createGetThreeWarmupEvent(GameState state) {
  return GameEvent(
    description: 'ALL players take three different red and green objects',
    type: EventType.get,
    choices: EventChoices(['OK'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        // Create copy of player and add objects
        return player.copyWith()
          ..addObject('random', 'red')
          ..addObject('random', 'red')
          ..addObject('random', 'red')
          ..addObject('random', 'green')
          ..addObject('random', 'green')
          ..addObject('random', 'green');
      });

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createGetAllGetOneEvent(GameState state) {
  return GameEvent(
    description: 'ALL take any object, but NOT a key object',
    type: EventType.get,
    choices: EventChoices(['OK'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players.updateAllPlayers((player) =>
          player.copyWith()
            ..addObject('random', math.Random().nextBool() ? 'red' : 'green'));

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createGetAllGetKeyEvent(GameState state) {
  return GameEvent(
    description: 'ALL take a key object',
    type: EventType.get,
    requiresConfirmation: true,
    choices: EventChoices(['Confirm'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players
          .updateAllPlayers((player) => player.copyWith()..addKeyObject());

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createGetTwoEvent(GameState state) {
  return GameEvent(
    description: 'Take a red object and a green object',
    type: EventType.get,
    choices: EventChoices(['OK'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players
          .updatePlayer(currentState.currentPlayer.copyWith()
            ..addObject('random', 'red')
            ..addObject('random', 'green'));

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createGetKeyObjectEvent(GameState state) {
  final availableObjects = <String>{};

  // Add all objects that are held by players
  for (final player in state.players) {
    player.greenObjects.forEach((object, count) {
      if (count > 0) availableObjects.add(object);
    });
    player.redObjects.forEach((object, count) {
      if (count > 0) availableObjects.add(object);
    });
  }

  // Remove key object and random objects if present
  availableObjects.remove(AppConstants.keyObject);
  availableObjects.remove('random');

  // If less than 4 choices, add random objects
  if (availableObjects.length < 4) {
    for (var i = availableObjects.length; i < 4; i++) {
      // Take random object from the list of all objects
      final randomObject = AppConstants
          .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];
      availableObjects.add(randomObject);
    }
  }

  return GameEvent(
    description:
        'Choose an object. All players holding that object will receive a key object',
    type: EventType.get,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      return currentState;
      // if (choiceIndex == null) return currentState;

      // BL: Omit this logic for now
      // final selectedObject = choices.items[choiceIndex];

      // final updatedPlayers = currentState.players.updateAllPlayers((player) {
      //   if ((player.greenObjects[selectedObject] ?? 0) > 0 ||
      //       (player.redObjects[selectedObject] ?? 0) > 0) {
      //     return player.copyWith()..addKeyObject();
      //   }
      //   return player;

      // return currentState.copyWith(players: updatedPlayers);
    },
  );
}
