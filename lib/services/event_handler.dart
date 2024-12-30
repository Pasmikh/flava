import 'dart:math' as math;
import '../models/player.dart';
import '../models/game_mode.dart';
import './game_logic.dart';

enum EventType {
  get,
  drop,
  other,
  midgame,
  strategic
}

class GameEvent {
  final String description;
  final List<String> choices;
  final Function(int) onChoice;
  final bool requiresConfirmation;
  final double additionalTime;

  GameEvent({
    required this.description,
    required this.choices,
    required this.onChoice,
    this.requiresConfirmation = false,
    this.additionalTime = 0.0,
  });
}

class EventHandler {
  static GameEvent createGetThreeEvent(
    List<Player> players,
    Player currentPlayer,
    Function(Player, String, String) onObjectAdded
  ) {
    final eligiblePlayers = players
        .where((p) => p.id != currentPlayer.id && !p.isEliminated)
        .toList();

    return GameEvent(
      description: 'Choose a player. They will take a red object, '
          'a green object, and ${GameLogic.keyObject}',
      choices: eligiblePlayers.map((p) => p.name).toList(),
      onChoice: (index) {
        final targetPlayer = eligiblePlayers[index];
        final objects = GameLogic.baseObjects;
        final randomObject = objects[math.Random().nextInt(objects.length)];
        
        onObjectAdded(targetPlayer, randomObject, 'red');
        onObjectAdded(targetPlayer, randomObject, 'green');
        targetPlayer.addKeyObject();
      },
    );
  }

  static GameEvent createDropThreeEvent(
    List<Player> players,
    Player currentPlayer,
    Function(Player, String, String) onObjectRemoved
  ) {
    final eligiblePlayers = players
        .where((p) => p.id != currentPlayer.id && !p.isEliminated)
        .toList();

    return GameEvent(
      description: 'Choose a player. They must drop a red object, '
          'a green object, and ${GameLogic.keyObject}',
      choices: eligiblePlayers.map((p) => p.name).toList(),
      onChoice: (index) {
        final targetPlayer = eligiblePlayers[index];
        
        // Find objects to remove
        if (targetPlayer.redObjects.isNotEmpty) {
          final redObject = targetPlayer.redObjects.keys.first;
          onObjectRemoved(targetPlayer, redObject, 'red');
        }
        
        if (targetPlayer.greenObjects.isNotEmpty) {
          final greenObject = targetPlayer.greenObjects.keys.first;
          onObjectRemoved(targetPlayer, greenObject, 'green');
        }
        
        if (targetPlayer.keyObjectCount > 0) {
          targetPlayer.removeKeyObject();
        }
      },
    );
  }

  static GameEvent createSwitchHandsEvent() {
    return GameEvent(
      description: 'All players must switch objects between hands. '
          'Different colors can be held together during this turn.',
      choices: ['Confirm'],
      onChoice: (_) {}, // Purely informational event
      requiresConfirmation: true,
      additionalTime: 2.0,
    );
  }

  static GameEvent createGiveObjectEvent(
    List<Player> players,
    Player currentPlayer,
    String direction,
    Function(Player, Player, String, String) onObjectTransferred
  ) {
    final description = direction == 'right'
        ? 'Place one object in front of the player to your right'
        : direction == 'left'
            ? 'Place one object in front of the player to your left'
            : 'Place one object in front of any player';

    return GameEvent(
      description: '$description. Take the object in front of you when the timer starts.',
      choices: direction == 'any' 
          ? players.where((p) => p.id != currentPlayer.id).map((p) => p.name).toList()
          : ['Confirm'],
      onChoice: (index) {
        if (direction == 'any') {
          final targetPlayer = players.where((p) => p.id != currentPlayer.id).toList()[index];
          // Implementation for specific player selection
          // This would be handled in the UI layer
        }
      },
      requiresConfirmation: true,
      additionalTime: 1.0,
    );
  }

  static GameEvent createKeyObjectEvent(
    List<String> objects,
    List<Player> players,
    Function(Player) onKeyObjectAdded
  ) {
    return GameEvent(
      description: 'Choose an object. All players holding that object '
          'will receive ${GameLogic.keyObject}',
      choices: objects,
      onChoice: (index) {
        final selectedObject = objects[index];
        for (final player in players) {
          if (player.greenObjects[selectedObject] != null || 
              player.redObjects[selectedObject] != null) {
            onKeyObjectAdded(player);
          }
        }
      },
    );
  }

  static GameEvent createStrategicEvent(
    String eventType,
    int targetRound,
    List<Player> players,
    Function(String, List<Player>) onEventTriggered
  ) {
    final description = 'A strategic event will occur in round $targetRound';
    
    return GameEvent(
      description: description,
      choices: ['Acknowledge'],
      onChoice: (_) {
        // Store event for future execution
        onEventTriggered(eventType, players);
      },
      requiresConfirmation: true,
    );
  }

  static GameEvent createWinTestEvent(
    Player player,
    int currentRound,
    Function(bool) onWinAttemptResult
  ) {
    String description;
    double additionalTime;

    if (currentRound >= 16) {
      description = 'To win, drop all ${GameLogic.keyObject}s without dropping other objects';
      additionalTime = 1.0;
    } else if (currentRound >= 10) {
      description = 'To win, switch objects between hands without dropping any. '
          'Different colors can be held together during this turn.';
      additionalTime = 2.0;
    } else {
      description = 'To win, take two objects from other players';
      additionalTime = 2.0;
    }

    return GameEvent(
      description: description,
      choices: ['Success', 'Failure'],
      onChoice: (index) => onWinAttemptResult(index == 0),
      requiresConfirmation: true,
      additionalTime: additionalTime,
    );
  }

  static bool shouldTriggerEvent(
    EventType type,
    GameMode mode,
    int currentRound,
    Map<String, double> probabilities
  ) {
    if (!_isEventAllowedInRound(type, currentRound)) {
      return false;
    }

    final probability = probabilities[type.toString().split('.').last] ?? 0.0;
    return math.Random().nextDouble() < probability;
  }

  static bool _isEventAllowedInRound(EventType type, int currentRound) {
    switch (type) {
      case EventType.get:
        return true;
      case EventType.drop:
        return currentRound >= 3;
      case EventType.other:
        return currentRound >= 5;
      case EventType.midgame:
      case EventType.strategic:
        return currentRound >= 6;
    }
  }
}