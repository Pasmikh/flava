import 'package:flava/extensions/player_list_extension.dart';
import 'package:flava/models/game_state.dart';
import '../game_event.dart';

final List<GameEvent Function(GameState)> dropEvents = [
  createDrop3Event,
  createDropObjectEvent,
  createAllDrop1Event,
  createDropKeyObjectEvent,
];

GameEvent createDrop3Event(GameState state) {
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
    choices: choices,
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final targetPlayer = choices.items[choiceIndex];
      final updatedPlayer = targetPlayer.copyWith();

      // Drop one green object if available
      if (updatedPlayer.greenObjects.values.any((count) => count > 0)) {
        updatedPlayer.removeObject('random', 'green');
      }

      // Drop one red object if available
      if (updatedPlayer.redObjects.values.any((count) => count > 0)) {
        updatedPlayer.removeObject('random', 'red');
      }

      // Drop key object if available
      if (updatedPlayer.keyObjectCount > 0) {
        updatedPlayer.keyObjectCount--;
      }

      final updatedPlayers = currentState.players.updatePlayer(updatedPlayer);

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
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

  return GameEvent(
    description: 'Choose an object. All players will drop all such objects',
    type: EventType.drop,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      if (choiceIndex == null) return currentState;

      final selectedObject = availableObjects.toList()[choiceIndex];

      final updatedPlayers = currentState.players.updateAllPlayers((player) {
        // Create copy with existing objects
        var updatedPlayer = player.copyWith(
          greenObjects: Map.from(player.greenObjects),
          redObjects: Map.from(player.redObjects),
        );

        // Drop all instances of the selected object
        while ((updatedPlayer.greenObjects[selectedObject] ?? 0) > 0) {
          updatedPlayer.removeObject(selectedObject, 'green');
        }
        while ((updatedPlayer.redObjects[selectedObject] ?? 0) > 0) {
          updatedPlayer.removeObject(selectedObject, 'red');
        }

        return updatedPlayer;
      });

      return currentState.copyWith(GameStateUpdate(
        players: updatedPlayers,
      ));
    },
  );
}

GameEvent createAllDrop1Event(GameState state) {
  return GameEvent(
    description: 'ALL players drop any object',
    type: EventType.drop,
    choices: EventChoices(['OK'], (str) => str),
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

  return GameEvent(
    description:
        'Choose an object. All players holding that object will drop a key object',
    type: EventType.drop,
    requiresConfirmation: true,
    choices: EventChoices(availableObjects.toList(), (object) => object),
    executeEvent: (currentState, choiceIndex) {
      return currentState;
      // if (choiceIndex == null) return currentState;

      // final selectedObject = availableObjects.toList()[choiceIndex];

      // final updatedPlayers = currentState.players.updateAllPlayers((player) {
      //   // Create copy with existing objects and key count
      //   var updatedPlayer = player.copyWith(
      //     greenObjects: Map.from(player.greenObjects),
      //     redObjects: Map.from(player.redObjects),
      //     keyObjectCount: player.keyObjectCount,
      //   );

      //   // If player has the selected object and a key object, drop the key object
      //   if (((updatedPlayer.greenObjects[selectedObject] ?? 0) > 0 ||
      //           (updatedPlayer.redObjects[selectedObject] ?? 0) > 0) &&
      //       updatedPlayer.keyObjectCount > 0) {
      //     updatedPlayer.removeKeyObject();
      //   }

      //   return updatedPlayer;
      // });

      // return currentState.copyWith(players: updatedPlayers);
    },
  );
}
