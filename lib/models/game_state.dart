import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import './player.dart';
import './game_mode.dart';
import '../config/constants.dart';
import '../services/event_handler.dart';
import '../services/game_logic.dart';

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
  // Core game state
  late GameMode _gameMode;
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _currentRound = 1;
  GameStatus _status = GameStatus.initial;
  bool _turnRotationClockwise = true;

  // Timer state
  Timer? _timer;
  double _turnTimeLeft = 0.0;
  double _additionalTime = 0.0;

  // Game objects and events
  String _currentObject = '';
  Color _currentObjectColor = const Color(0xFF000000);
  Map<String, double> _eventProbabilities = {};
  String? _eventDescription;
  GameEvent? _currentEvent;

  // Getters
  GameMode get gameMode => _gameMode;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get currentRound => _currentRound;
  GameStatus get status => _status;
  double get turnTimeLeft => _turnTimeLeft;
  double get turnProgress =>
      _turnTimeLeft /
      (_gameMode.calculateTurnLength(_players.length, _currentRound) +
          _additionalTime);
  String get currentObject => _currentObject;
  Color get currentObjectColor => _currentObjectColor;
  bool get isClockwise => _turnRotationClockwise;
  GameEvent? get currentEvent => _currentEvent;
  String? get eventDescription => _eventDescription;

  void initializeGame({
    required List<String> playerNames,
    required GameMode gameMode,
  }) {
    _gameMode = gameMode;
    _players = playerNames.map((name) => Player(name: name)).toList();
    _turnTimeLeft = gameMode.calculateTurnLength(_players.length);
    _currentPlayerIndex =
        DateTime.now().millisecondsSinceEpoch % _players.length;
    _status = GameStatus.ready;
    notifyListeners();
  }

  void startGame() {
    if (_status == GameStatus.ready) {
      _status = GameStatus.playing;
      _startTimer();
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

  void endCurrentTurn() {
    if (_status == GameStatus.playing) {
      _turnTimeLeft = 0;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_turnTimeLeft <= 0) {
          _handleTurnEnd();
        } else {
          _turnTimeLeft -= AppConstants.timerTickDuration;
          notifyListeners();
        }
      },
    );
  }

  Future<void> _handleTurnEnd() async {
    _timer?.cancel();

    if (_checkWinCondition()) {
      _endGame();
      return;
    }

    if (_shouldStartNewRound()) {
      await _startNewRound();
    } else {
      _moveToNextPlayer();
    }

    // Define next player turn type. Process strategic event, trigger new event or generate new object
    _resetTurn();
    _defineNextTurn();

    _startTimer();
    notifyListeners();
  }

  void _moveToNextPlayer() {
    if (_turnRotationClockwise) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    } else {
      _currentPlayerIndex =
          (_currentPlayerIndex - 1 + _players.length) % _players.length;
    }
  }

  bool _shouldStartNewRound() {
    return (_currentPlayerIndex + (_turnRotationClockwise ? 1 : -1)) %
            _players.length ==
        0;
  }

  Future<void> _startNewRound() async {
    _currentRound++;
    _turnTimeLeft = _gameMode.calculateTurnLength(_players.length);
  }

  bool _checkWinCondition() {
    return currentPlayer.keyObjectCount >= _gameMode.requiredKeyObjectsToWin;
  }

  void _endGame() {
    _status = GameStatus.gameOver;
    currentPlayer.isWinner = true;
    _timer?.cancel();
    notifyListeners();
  }

  void _resetTurn() {
    _turnTimeLeft = _gameMode.calculateTurnLength(_players.length);
    _additionalTime = 0.0;
    _currentEvent = null;
    _eventDescription = null;
  }

  void _defineNextTurn() {
    // Check if strategic event is triggered
    if (gameMode.allowsStrategicEvents) {
      _processStrategicEvents();
    }

    // Check if event is triggered
    _eventProbabilities = GameLogic.calculateEventProbabilities(
      _gameMode,
      _currentRound,
      currentPlayer.eventCounts,
    );

    for (final entry in _eventProbabilities.entries) {
      if (math.Random().nextDouble() < entry.value) {
        print('Triggering event: ${entry.key}');
        // TBD: Implement event handling
        break;
      }
    }

    // Generate new object
    final (text, color) = GameLogic.generateRandomObject(
      keyProbability: _gameMode.keyObjectProbability,
      greenProbability: GameLogic.calculateGreenProbability(currentPlayer),
      previousObject: _currentObject,
    );
    _currentObject = text;
    _currentObjectColor = color;
  }

  void _processStrategicEvents() {
    // Implementation for strategic events
  }

  void handleEventChoice(int choice) {
    if (_currentEvent != null) {
      _currentEvent!.onChoice(choice);
      _currentEvent = null;
      _eventDescription = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
