enum GameMode {
  beginner,
  fun,
  master,
}

class GameModeConfig {
  static const Map<GameMode, String> displayNames = {
    GameMode.beginner: 'Learn',
    GameMode.fun: 'Have Fun',
    GameMode.master: 'Master',
  };

  static const Map<GameMode, double> initialTurnLengths = {
    GameMode.beginner: 8.0,
    GameMode.fun: 6.0,
    GameMode.master: 6.8,
  };

  static const Map<GameMode, double> endTurnLengths = {
    GameMode.beginner: 7.0,
    GameMode.fun: 7.0,
    GameMode.master: 6.2,
  };

  static const Map<GameMode, double> keyProbabilities = {
    GameMode.beginner: 0.15,
    GameMode.fun: 0.12,
    GameMode.master: 0.10,
  };

  static double getInitialTurnLength(GameMode mode, int playerCount) {
    double baseLength = initialTurnLengths[mode] ?? 6.0;
    return baseLength - (playerCount * 0.2);
  }

  static double getEndTurnLength(GameMode mode, int playerCount) {
    double baseLength = endTurnLengths[mode] ?? 6.0;
    return baseLength - (playerCount * 0.2);
  }

  static bool requiresEventConfirmation(GameMode mode) {
    return mode == GameMode.beginner;
  }

  static bool allowsStrategicEvents(GameMode mode) {
    return mode == GameMode.fun || mode == GameMode.master;
  }

  static List<String> getAllowedObjects(GameMode mode) {
    // Basic objects available in all modes
    const baseObjects = [
      'Шнурок', 'Червяк', 'Резинка', 'Наперсток', 'Вилка',
      'Ковид', 'Бусина', 'Перчик', 'Прищепка', 'Головоломка'
    ];
    
    return baseObjects;
  }

  static String getKeyObject() {
    return 'Шарик';
  }
}