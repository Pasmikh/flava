import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:collection/collection.dart';

import 'player.dart';
import 'game_mode.dart';
import '../config/constants.dart';
import '../utils/event_handler.dart';

enum GameStatus {
  initial,
  ready,
  playing,
  paused,
  roundComplete,
  gameOver,
  eventChoice
}

class GameState extends ChangeNotifier {
  // Game configuration
  List<Player> _players = [];
  GameMode _gameMode = GameMode.fun;
  int _currentPlayerIndex = 0;
  int _currentRound = 1;
  GameStatus _status = GameStatus.initial;
  bool _turnRotationClockwise = true;
  
  // Timer related
  Timer? _timer;
  double _turnLength = 6.0;
  double _currentTurnTimeLeft = 6.0;
  double _additionalTurnTime = 0.0;
  
  // Game objects and events
  String _currentObject = '';
  String _previousObject = '';
  bool _isKeyObjectAvailable = false;
  List<String> _strategicEventPool = [];
  String? _eventDescription;
  GameEvent? _currentEvent;
  
  // Event probabilities
  double _getEventChance = 0.0;
  double _dropEventChance = 0.0;
  double _otherEventChance = 0.0;
  double _getMidgameEventChance = 0.0;
  double _strategicEventChance = 0.0;

  // Getters
  List<Player> get players => _players;
  GameMode get gameMode => _gameMode;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get currentRound => _currentRound;
  GameStatus get status => _status;
  double get turnTimeLeft => _currentTurnTimeLeft;
  double get turnProgress => _currentTurnTimeLeft / (_turnLength + _additionalTurnTime);
  String get currentObject => _currentObject;
  bool get isClockwise => _turnRotationClockwise;
  GameEvent? get currentEvent => _currentEvent;

  // Initialize game
  void initializeGame({
    required List<String> playerNames,
    required GameMode gameMode,
    double initialTurnLength = 6.0,
  }) {
    _players = playerNames.map((name) => Player(name: name)).toList();
    _gameMode = gameMode;
    _turnLength = initialTurnLength;
    _currentTurnTimeLeft = initialTurnLength;
    _status = GameStatus.ready;
    
    // Randomize first player
    _currentPlayerIndex = DateTime.now().millisecondsSinceEpoch % _players.length;
    
    // Initialize event probabilities based on game mode
    _initializeEventProbabilities();
    
    notifyListeners();
  }

  void startGame() {
    if (_status == GameStatus.ready) {
      _status = GameStatus.playing;
      _startTimer();
      notifyListeners();
    }
  }

  void endCurrentTurn() {
    if (_status == GameStatus.playing) {
      _currentTurnTimeLeft = 0;
      notifyListeners();
    }
  }

  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      _startTimer();
      notifyListeners();
    }
  }

  void _startTimer() {
    const tickDuration = Duration(milliseconds: 100);
    _timer?.cancel();
    _timer = Timer.periodic(tickDuration, (timer) {
      if (_currentTurnTimeLeft <= 0) {
        _handleTurnEnd();
      } else {
        _currentTurnTimeLeft -= 0.1;
        notifyListeners();
      }
    });
  }

  void _handleTurnEnd() {
    _timer?.cancel();
    _previousObject = _currentObject;
    
    if (_checkWinCondition()) {
      _endGame();
      return;
    }

    if (_shouldStartNewRound()) {
      _startNewRound();
    } else {
      _moveToNextPlayer();
    }
    
    _resetTurnTimer();
    notifyListeners();
  }

  void _moveToNextPlayer() {
    if (_turnRotationClockwise) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    } else {
      _currentPlayerIndex = (_currentPlayerIndex - 1 + _players.length) % _players.length;
    }
  }

  bool _shouldStartNewRound() {
    int activePlayers = _players.where((p) => !p.isEliminated).length;
    return _currentPlayerIndex == activePlayers - 1;
  }

  void _startNewRound() {
    _currentRound++;
    // Adjust turn length based on game mode and round
    _adjustTurnLength();
    // Process strategic events
    _processStrategicEvents();
  }

  void _adjustTurnLength() {
    // Adjust turn length based on game mode and round
    if (_gameMode != GameMode.master) {
      _turnLength = (_turnLength + 0.2).clamp(0.0, 7.0);
    }
  }

  bool _checkWinCondition() {
    return currentPlayer.keyObjectCount >= 4;
  }

  void _endGame() {
    _status = GameStatus.gameOver;
    currentPlayer.isWinner = true;
    _timer?.cancel();
    notifyListeners();
  }

  void _resetTurnTimer() {
    _currentTurnTimeLeft = _turnLength;
    _additionalTurnTime = 0.0;
    notifyListeners();
  }

  void _processStrategicEvents() {
    // Process events that were scheduled for future rounds
    _strategicEventPool.removeWhere((event) {
      if (event.startsWith('$_currentRound:')) {
        // Parse and execute the strategic event
        final eventDetails = event.split(':')[1];
        _executeStrategicEvent(eventDetails);
        return true;
      }
      return false;
    });
  }

  void _executeStrategicEvent(String eventDetails) {
    // Implementation will handle different types of strategic events
    // This will be expanded based on the specific event requirements
    notifyListeners();
  }

void _initializeEventProbabilities() {
  final eventProbabilitiesMap = {
    GameMode.beginner: AppConstants.beginnerEventProbabilities,
    GameMode.fun: AppConstants.funEventProbabilities,
    GameMode.master: AppConstants.masterEventProbabilities,
  };

  final eventProbabilities = eventProbabilitiesMap[_gameMode]!;

  _getEventChance = eventProbabilities['get']!;
  _dropEventChance = eventProbabilities['drop']!;
  _otherEventChance = eventProbabilities['other']!;
  _getMidgameEventChance = eventProbabilities['midgame']!;
  _strategicEventChance = eventProbabilities['strategic']!;
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}