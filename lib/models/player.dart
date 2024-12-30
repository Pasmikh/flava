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
  Map<String, int> eventCounts = {
    'get': 0,
    'drop': 0,
    'other': 0,
    'getMidgame': 0,
    'strategic': 0,
  };

  Player({
    required this.name,
  }) : id = DateTime.now().millisecondsSinceEpoch;

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
      'getEvents': eventCounts['get'],
      'dropEvents': eventCounts['drop'],
      'otherEvents': eventCounts['other'],
      'getMidgameEvents': eventCounts['getMidgame'],
      'strategicEvents': eventCounts['strategic'],
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
    player.eventCounts['get'] = json['getEvents'];
    player.eventCounts['drop'] = json['dropEvents'];
    player.eventCounts['other'] = json['otherEvents'];
    player.eventCounts['getMidgame'] = json['getMidgameEvents'];
    player.eventCounts['strategic'] = json['strategicEvents'];
    return player;
  }
}