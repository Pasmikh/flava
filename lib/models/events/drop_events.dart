import 'dart:math' as math;

import '../../extensions/player_list_extension.dart';
import '../game_state.dart';
import '../game_event.dart';
import '../../config/constants.dart';

final List<GameEvent Function(GameState)> dropEvents = [
  createDropThreeEvent,
  createDropObjectEvent,
  createAllDropOneEvent,
  createDropKeyObjectEvent,
];

GameEvent createDropThreeEvent(GameState state) {
  final choices = EventChoices(
    state.players
        .where((p) => p.id != state.currentPlayer.id && !p.isEliminated)
        .toList(),
    (player) => player.name,
  );

  return GameEvent(
    description: 'Choose a player. They will drop a red object, '
        'a green object, and a key object',
    type: EventType.drop,
    requiresConfirmation: true,
    additionalTime: 1,
    choices: choices,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex];
      final updatedPlayer = targetPlayer.copyWith();

      // Drop one of each type if available
      if (updatedPlayer.greenObjects.values.any((count) => count > 0)) {
        updatedPlayer.removeObject('random', 'green');
      }
      if (updatedPlayer.redObjects.values.any((count) => count > 0)) {
        updatedPlayer.removeObject('random', 'red');
      }
      if (updatedPlayer.keyObjectCount > 0) {
        updatedPlayer.removeKeyObject();
      }

      final updatedPlayers = currentState.players.updatePlayer(updatedPlayer);
      return currentState.copyWith(GameStateUpdate(players: updatedPlayers));
    },
  );
}

GameEvent createDropObjectEvent(GameState state) {
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

  // Remove key object and random if present
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
    description: 'Choose an object. All players will drop all such objects',
    type: EventType.drop,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final selectedObject = availableObjects.toList()[choiceIndex];
      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        var updatedPlayer = player.copyWith();

        // Drop all instances of the selected object
        while (updatedPlayer.greenObjects[selectedObject] != null &&
            updatedPlayer.greenObjects[selectedObject]! > 0) {
          updatedPlayer.removeObject(selectedObject, 'green');
        }
        while (updatedPlayer.redObjects[selectedObject] != null &&
            updatedPlayer.redObjects[selectedObject]! > 0) {
          updatedPlayer.removeObject(selectedObject, 'red');
        }

        return updatedPlayer;
      });

      return currentState.copyWith(GameStateUpdate(players: updatedPlayers));
    },
  );
}

GameEvent createAllDropOneEvent(GameState state) {
  return GameEvent(
    description: 'ALL players drop any object',
    type: EventType.drop,
    choices: EventChoices(['Confirm'], (str) => str),
    executeEvent: (currentState, _) {
      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        // Create copy with existing objects
        var updatedPlayer = player.copyWith(
          greenObjects: Map.from(player.greenObjects),
          redObjects: Map.from(player.redObjects),
        );

        // Drop either green or red object if available
        if (updatedPlayer.greenObjects.values.any((count) => count > 0)) {
          updatedPlayer.removeObject('random', 'green');
        } else if (updatedPlayer.redObjects.values.any((count) => count > 0)) {
          updatedPlayer.removeObject('random', 'red');
        }

        return updatedPlayer;
      });

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createDropKeyObjectEvent(GameState state) {
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

  // Remove key object and random if present
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
        'Choose an object. All players holding that object will drop a key object',
    type: EventType.drop,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      // Skip tracking logic for now
      return currentState;
    },
  );
}
