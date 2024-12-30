class AppConstants {
  // App information
  static const String appName = 'Flava';
  static const String appVersion = '1.0.0';
  
  // Game configuration
  static const int minPlayers = 2;
  static const int maxPlayers = 5;
  static const double defaultTurnLength = 6.0;
  static const double timerTickDuration = 0.1;
  static const int minRoundForStrategicEvents = 6;
  static const double turnLengthReductionByPlayersCount = 0.2;
  static const double turnLengthIncrement = 0.1;
  
  // Asset paths
  static const String soundsPath = 'assets/sounds/';
  static const String imagesPath = 'assets/images/';
  
  // Sound assets
  static const String heartbeatSlowSound = '${soundsPath}heartbeat_slow.wav';
  static const String heartbeatNormalSound = '${soundsPath}heartbeat_normal.wav';
  static const String heartbeatFastSound = '${soundsPath}heartbeat_fast.wav';
  static const String endTurnSound = '${soundsPath}end_turn.wav';
  static const String eliminateSound = '${soundsPath}eliminate.wav';
  static const String winSound = '${soundsPath}win.wav';
  
  // Image paths by color
  static const String greenImagesPath = '${imagesPath}green/';
  static const String redImagesPath = '${imagesPath}red/';
  
  // Object image mapping
  static const Map<String, String> objectImageNames = {
    'Шнурок': 'shnurok',
    'Червяк': 'poloska',
    'Резинка': 'rezinka',
    'Наперсток': 'naperstok',
    'Вилка': 'vilka',
    'Ковид': 'covid_big',
    'Бусина': 'busina',
    'Перчик': 'perchik',
    'Прищепка': 'prischepka',
    'Головоломка': 'golovolomka',
    'Шарик': 'sharik',
  };
  
  // Storage keys
  static const String userIdKey = 'user_id';
  static const String gameStatsDirectory = 'stats';
  static const String gameResultsFile = 'game_results.txt';
  static const String eventsFile = 'events.txt';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Timer thresholds
  static const double fastHeartbeatThreshold = 2.0;
  static const double normalHeartbeatThreshold = 4.0;
  
  // Event probabilities
  static const Map<String, double> defaultEventProbabilities = {
    'get': 0.012,
    'drop': 0.01,
    'other': 0.015,
    'midgame': 0.007,
    'strategic': 0.007,
  };

  static const Map<String, double> beginnerEventProbabilities = {
    'get': 0.02,
    'drop': 0.02,
    'other': 0.01,
    'midgame': 0.0,
    'strategic': 0.0,
  };

  static const Map<String, double> funEventProbabilities = {
    'get': 0.012,
    'drop': 0.01,
    'other': 0.015,
    'midgame': 0.007,
    'strategic': 0.0,
  };

  static const Map<String, double> masterEventProbabilities = {
    'get': 0.01,
    'drop': 0.01,
    'other': 0.01,
    'midgame': 0.01,
    'strategic': 0.01,
  };
  
  // Error messages
  static const String errorPlayerLimit = 'Maximum number of players reached';
  static const String errorInvalidPlayerCount = 'Invalid number of players';
  static const String errorGameInProgress = 'Game already in progress';
  static const String errorInvalidGameMode = 'Invalid game mode selected';
  
  // Success messages
  static const String successPlayerAdded = 'Player added successfully';
  static const String successGameStarted = 'Game started successfully';
  static const String successRoundComplete = 'Round completed';
  static const String successGameComplete = 'Game completed successfully';
}