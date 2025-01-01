import 'dart:math' as math;
import 'package:flava/models/game_event.dart';

class Player {
  final int id;
  final String name;
  bool isEliminated = false;
  bool isWinner = false;
  int actionsCount = 0;

  // Object counts
  Map<String, int> greenObjects = {};
  Map<String, int> redObjects = {};
  int keyObjectCount = 0;

  // Event counts
  Map<EventType, int> eventCounts = {
    EventType.get: 0,
    EventType.drop: 0,
    EventType.other: 0,
    EventType.midgame: 0,
    EventType.strategic: 0,
  };

  // Strategic events
  Map<GameEvent, int> strategicEvents = {};

  Player({
    required this.name,
  }) : id = math.Random().nextInt(1000000);

  int get totalObjectCount {
    int greenCount = greenObjects.values.fold(0, (sum, count) => sum + count);
    int redCount = redObjects.values.fold(0, (sum, count) => sum + count);
    return greenCount + redCount + keyObjectCount;
  }

  void addObject(String objectName, String color) {
    if (color == 'green') {
      greenObjects[objectName] = (greenObjects[objectName] ?? 0) + 1;
    } else if (color == 'red') {
      redObjects[objectName] = (redObjects[objectName] ?? 0) + 1;
    }
  }

  void removeObject(String objectName, String color) {
    if (color == 'green' && greenObjects.containsKey(objectName)) {
      if (greenObjects[objectName]! > 0) {
        greenObjects[objectName] = greenObjects[objectName]! - 1;
      }
    } else if (color == 'red' && redObjects.containsKey(objectName)) {
      if (redObjects[objectName]! > 0) {
        redObjects[objectName] = redObjects[objectName]! - 1;
      }
    }
  }

  void addKeyObject() {
    keyObjectCount++;
  }

  void removeKeyObject() {
    if (keyObjectCount > 0) {
      keyObjectCount--;
    }
  }

  Player copyWith({
    String? name,
    Map<String, int>? greenObjects,
    Map<String, int>? redObjects,
    int? keyObjectCount,
    bool? isEliminated,
    bool? isWinner,
    int? actionsCount,
    Map<EventType, int>? eventCounts,
  }) {
    final newPlayer = Player(name: name ?? this.name)
      ..greenObjects = Map.from(greenObjects ?? this.greenObjects)
      ..redObjects = Map.from(redObjects ?? this.redObjects)
      ..keyObjectCount = keyObjectCount ?? this.keyObjectCount
      ..isEliminated = isEliminated ?? this.isEliminated
      ..isWinner = isWinner ?? this.isWinner
      ..actionsCount = actionsCount ?? this.actionsCount
      ..eventCounts = Map.from(eventCounts ?? this.eventCounts);
    return newPlayer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isEliminated': isEliminated,
      'isWinner': isWinner,
      'actionsCount': actionsCount,
      'greenObjects': greenObjects,
      'redObjects': redObjects,
      'keyObjectCount': keyObjectCount,
      'getEvents': eventCounts[EventType.get],
      'dropEvents': eventCounts[EventType.drop],
      'otherEvents': eventCounts[EventType.other],
      'midgameEvents': eventCounts[EventType.midgame],
      'strategicEvents': eventCounts[EventType.strategic],
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    final player = Player(name: json['name']);
    player.isEliminated = json['isEliminated'];
    player.isWinner = json['isWinner'];
    player.actionsCount = json['actionsCount'];
    player.greenObjects = Map<String, int>.from(json['greenObjects']);
    player.redObjects = Map<String, int>.from(json['redObjects']);
    player.keyObjectCount = json['keyObjectCount'];
    player.eventCounts = {
      EventType.get: json['getEvents'],
      EventType.drop: json['dropEvents'],
      EventType.other: json['otherEvents'],
      EventType.midgame: json['midgameEvents'],
      EventType.strategic: json['strategicEvents'],
    };

    return player;
  }
}
