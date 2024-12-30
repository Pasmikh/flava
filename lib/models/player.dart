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
  int getEvents = 0;
  int dropEvents = 0;
  int otherEvents = 0;
  int getMidgameEvents = 0;
  int strategicEvents = 0;

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
      'getEvents': getEvents,
      'dropEvents': dropEvents,
      'otherEvents': otherEvents,
      'getMidgameEvents': getMidgameEvents,
      'strategicEvents': strategicEvents,
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
    player.getEvents = json['getEvents'];
    player.dropEvents = json['dropEvents'];
    player.otherEvents = json['otherEvents'];
    player.getMidgameEvents = json['getMidgameEvents'];
    player.strategicEvents = json['strategicEvents'];
    return player;
  }
}