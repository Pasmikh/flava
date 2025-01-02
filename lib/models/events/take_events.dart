import 'dart:math' as math;

import '../../config/constants.dart';
import '../../extensions/player_list_extension.dart';
import '../player.dart';
import '../game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> takeEvents = [
  createTakeThreeWarmupEvent, // event_get_3_warmup
  createTakeThreeEvent, // event_get_3
  createTakeAllGetOneEvent, // event_all_get_1
  createTakeAllGetKeyEvent, // event_all_get_key
  createTakeTwoEvent, // event_get_2
  createTakeRotateEvent, // event_get_rotate
  createTakeKeyObjectEvent, // event_get_key_object
  createTakeKeyMinNumCardsEvent, // event_get_key_min_num_cards
  createTakeKeyMaxNumCardsEvent, // event_get_key_max_num_cards
];

GameEvent createTakeThreeEvent(GameState state) {
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
    type: EventType.take,
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

GameEvent createTakeThreeWarmupEvent(GameState state) {
  return GameEvent(
    description: 'ALL players take three different red and green objects',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
    requiresConfirmation: true,
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

GameEvent createTakeAllGetOneEvent(GameState state) {
  return GameEvent(
    description: 'ALL take any object, but NOT a key object',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
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

GameEvent createTakeAllGetKeyEvent(GameState state) {
  return GameEvent(
    description: 'ALL take a key object',
    type: EventType.take,
    requiresConfirmation: true,
    isMidgame: true,
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

GameEvent createTakeTwoEvent(GameState state) {
  return GameEvent(
    description: 'Take a red object and a green object',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
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

GameEvent createTakeRotateEvent(GameState state) {
  final objectColor = math.Random().nextBool() ? 'red' : 'green';
  final randomObject = AppConstants
      .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];

  return GameEvent(
    description: 'Take $randomObject ($objectColor). Play direction reverses.',
    type: EventType.take,
    choices: EventChoices(['Confirm'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players.updatePlayer(
        currentState.currentPlayer.copyWith()
          ..addObject(randomObject, objectColor),
      );

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
        turnRotationClockwise: !currentState.turnRotationClockwise,
      ));
    },
  );
}

GameEvent createTakeKeyMinNumCardsEvent(GameState state) {
  final numChoices = [3, 6, 9, 12];

  return GameEvent(
    description:
        'Choose a number. All players with that many or more objects will take a key object',
    type: EventType.take,
    requiresConfirmation: true,
    isMidgame: true,
    choices: EventChoices(
      numChoices,
      (number) => number.toString(),
    ),
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final selectedNum = numChoices[choiceIndex];
      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        if (player.totalObjectCount >= selectedNum) {
          return player.copyWith()..addKeyObject();
        }
        return player;
      });

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createTakeKeyMaxNumCardsEvent(GameState state) {
  final numChoices = [3, 6, 9, 12];

  return GameEvent(
    description:
        'Choose a number. All players with that many or fewer objects will take a key object',
    type: EventType.take,
    requiresConfirmation: true,
    isMidgame: true,
    choices: EventChoices(
      numChoices,
      (number) => number.toString(),
    ),
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final selectedNum = numChoices[choiceIndex];
      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        if (player.totalObjectCount <= selectedNum) {
          return player.copyWith()..addKeyObject();
        }
        return player;
      });

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createTakeKeyObjectEvent(GameState state) {
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
  while (availableObjects.length < 4) {
    // Take random object from the list of all objects
    final randomObject = AppConstants
        .baseObjects[math.Random().nextInt(AppConstants.baseObjects.length)];
    availableObjects.add(randomObject);
  }

  return GameEvent(
    description:
        'Choose an object. All players holding that object will receive a key object',
    type: EventType.take,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      return currentState;
    },
  );
}
