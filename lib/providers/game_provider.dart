import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  // Services
  final AudioService _audioService;
  final AnalyticsService _analyticsService;
  final StorageService _storageService;
  
  // Game State
  List<Player> _players = [];
  late GameMode _gameMode;
  int _currentPlayerIndex = 0;
  int _currentRound = 1;
  bool _isClockwise = true;
  Timer? _gameTimer;
  
  // Timer State
  double _baseTurnLength = 6.0;
  double _currentTurnTimeLeft = 6.0;
  double _additionalTime = 0.0;
  bool _isPaused = false;
  
  // Game Objects and Events
  String _currentObject = '';
  String _previousObject = '';
  List<String> _eventChoices = [];
  String? _eventDescription;
  bool _isEventActive = false;
  final List<Map<String, dynamic>> _strategicEvents = [];
  
  // Event Probabilities
  double _getEventChance = 0.0;
  double _dropEventChance = 0.0;
  double _otherEventChance = 0.0;
  double _getMidgameEventChance = 0.0;
  double _strategicEventChance = 0.0;

  // Game ID and tracking
  late int _gameId;
  late int _userId;
  
  GameProvider({
    required AudioService audioService,
    required AnalyticsService analyticsService,
    required StorageService storageService,
  })  : _audioService = audioService,
        _analyticsService = analyticsService,
        _storageService = storageService {
    _initializeTracking();
  }

  // Getters
  List<Player> get players => _players;
  GameMode get gameMode => _gameMode;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get currentRound => _currentRound;
  bool get isClockwise => _isClockwise;
  double get turnTimeLeft => _currentTurnTimeLeft;
  double get turnProgress => _currentTurnTimeLeft / (_baseTurnLength + _additionalTime);
  String get currentObject => _currentObject;
  bool get isPaused => _isPaused;
  List<String> get eventChoices => _eventChoices;
  String? get eventDescription => _eventDescription;
  bool get isEventActive => _isEventActive;

  Future<void> _initializeTracking() async {
    _userId = _storageService.getUserId();
    _gameId = await _storageService.getLastGameId() + 1;
  }

  Future<void> initializeGame({
    required List<String> playerNames,
    required GameMode gameMode,
    double initialTurnLength = 6.0,
  }) async {
    _players = playerNames.map((name) => Player(name: name)).toList();
    _gameMode = gameMode;
    _baseTurnLength = initialTurnLength;
    _currentTurnTimeLeft = initialTurnLength;
    _currentPlayerIndex = DateTime.now().millisecondsSinceEpoch % _players.length;
    _initializeEventProbabilities();
    notifyListeners();
  }

  void startGame() {
    if (!_isPaused) {
      _startTimer();
      _generateNewObject();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      _handleTimerTick,
    );
  }

  void _handleTimerTick(Timer timer) async {
    if (_currentTurnTimeLeft <= 0) {
      await _handleTurnEnd();
    } else {
      _currentTurnTimeLeft -= 0.1;
      _playHeartbeatSounds();
      notifyListeners();
    }
  }

  Future<void> _playHeartbeatSounds() async {
    await _audioService.playHeartbeat(_currentTurnTimeLeft);
  }

  void togglePause() {
    if (_isPaused) {
      _startTimer();
    } else {
      _gameTimer?.cancel();
    }
    _isPaused = !_isPaused;
    notifyListeners();
  }

  Future<void> _handleTurnEnd() async {
    _gameTimer?.cancel();
    await _audioService.playEndTurn();
    _previousObject = _currentObject;
    
    if (_checkWinCondition()) {
      await _endGame();
      return;
    }

    if (_shouldStartNewRound()) {
      await _startNewRound();
    } else {
      _moveToNextPlayer();
    }
    
    _resetTurnTimer();
    _generateNewObject();
    notifyListeners();
  }

  void _moveToNextPlayer() {
    if (_isClockwise) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    } else {
      _currentPlayerIndex = (_currentPlayerIndex - 1 + _players.length) % _players.length;
    }
  }

  bool _shouldStartNewRound() {
    return (_currentPlayerIndex + (_isClockwise ? 1 : -1)) % _players.length == 0;
  }

  Future<void> _startNewRound() async {
    _currentRound++;
    _processStrategicEvents();
    _adjustTurnLength();
    
    await _storageService.logGameEvent(
      turnRound: _currentRound,
      playerId: currentPlayer.id,
      playerName: currentPlayer.name,
      event: 'round_start',
      extra: _currentRound.toString(),
    );
  }

  void _adjustTurnLength() {
    if (_gameMode != GameMode.master) {
      _baseTurnLength = (_baseTurnLength + 0.2).clamp(0.0, 7.0);
    }
  }

  void _generateNewObject() {
    final event = _calculateEvent();
    if (event != null) {
      _handleEvent(event);
    } else {
      _generateRandomObject();
    }
  }

  String? _calculateEvent() {
    // Event probability calculations based on game mode
    // Returns event type or null if no event should occur
    return null; // Placeholder
  }

  void _handleEvent(String eventType) {
    // Handle different event types
    // This will be implemented based on the original game's event system
  }

  void _generateRandomObject() {
    // Generate random object based on game rules
    // This will be implemented based on the original game's object system
  }

  bool _checkWinCondition() {
    return currentPlayer.keyObjectCount >= 4;
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    currentPlayer.isWinner = true;
    await _audioService.playWin();
    
    // Record game results
    await _recordGameEnd();
    notifyListeners();
  }

  void _initializeEventProbabilities() {
    switch (_gameMode) {
      case GameMode.beginner:
        _getEventChance = 0.02;
        _dropEventChance = 0.02;
        _otherEventChance = 0.01;
        _getMidgameEventChance = 0.0;
        _strategicEventChance = 0.0;
        break;
      case GameMode.fun:
        _getEventChance = 0.012;
        _dropEventChance = 0.01;
        _otherEventChance = 0.015;
        _getMidgameEventChance = 0.007;
        _strategicEventChance = 0.007;
        break;
      case GameMode.master:
        _getEventChance = 0.015;
        _dropEventChance = 0.01;
        _otherEventChance = 0.015;
        _getMidgameEventChance = 0.007;
        _strategicEventChance = 0.007;
        break;
    }
  }

  void _resetTurnTimer() {
    _currentTurnTimeLeft = _baseTurnLength;
    _additionalTime = 0.0;
    notifyListeners();
  }

  void _processStrategicEvents() {
    final currentEvents = List<Map<String, dynamic>>.from(_strategicEvents);
    for (final event in currentEvents) {
      if (event['round'] == _currentRound) {
        event['action']();
        _strategicEvents.remove(event);
        
        _storageService.logGameEvent(
          turnRound: _currentRound,
          playerId: currentPlayer.id,
          playerName: currentPlayer.name,
          event: 'strategic_event',
          extra: event['type'],
        );
      }
    }
  }

  Future<void> _recordGameEnd() async {
    await _storageService.saveGameResults({
      'user_id': _userId,
      'game_id': _gameId,
      'game_mode': _gameMode.toString(),
      'players': _players.map((p) => p.toJson()).toList(),
      'max_round': _currentRound,
      'winner_id': currentPlayer.id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    _analyticsService.recordGameResult(
      gameId: _gameId,
      userId: _userId,
      gameMode: _gameMode,
      players: _players,
      maxRound: _currentRound,
      winnerId: currentPlayer.id,
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}