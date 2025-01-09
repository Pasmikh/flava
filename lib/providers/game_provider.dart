import 'dart:async';
import 'dart:math' as math;

import 'package:flava/config/game_mode_rules.dart';
import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/game_state.dart';
import '../models/game_event.dart';
import '../models/game_interruption.dart';
import '../services/game_logic.dart';
import '../services/event_handler.dart';
import '../services/logging_service.dart';
import '../config/theme.dart';
import '../extensions/player_list_extension.dart';

class GameProvider extends ChangeNotifier {
  late GameState _state;
  VoidCallback? _onGameOver;

  final LoggingService _loggingService = LoggingService();
  final AudioService _audioService;
  final StorageService _storageService;
  Timer? _gameTimer;
  late int _gameId;
  int playerTurnCount = 1;
  bool skipNextEndRoundSound = false;

  GameProvider({
    required StorageService storageService,
  })  : _audioService = AudioService.getInstance(),
        _storageService = storageService,
        _state = GameState(
          gameMode: BeginnerGameMode(),
          players: [],
        ) {
    // _initializeTracking();
  }

  // Getters
  GameState get state => _state;
  List<Player> get players => _state.players;
  int get currentPlayerIndex => _state.currentPlayerIndex;
  Player get currentPlayer => _state.players[_state.currentPlayerIndex];
  bool get isPaused => _state.status == GameStatus.paused;
  bool get isGameOver => _state.status == GameStatus.gameOver;

  // Future<void> _initializeTracking() async {
  //   _userId = _storageService.getUserId();
  //   _gameId = await _storageService.getLastGameId() + 1;
  // }

  void initializeGame({
    required List<String> playerNames,
    required GameMode gameMode,
  }) {
    final players = playerNames.map((name) => Player(name: name)).toList();
    final turnTimeLeft = gameMode.calculateTurnLength(players.length);
    final currentPlayerIndex =
        0; // DateTime.now().millisecondsSinceEpoch % players.length;
    playerTurnCount = 1;
    _gameId = DateTime.now().millisecondsSinceEpoch;

    _state = _state.copyWith(GameStateUpdate(
      currentRound: 1,
      gameMode: gameMode,
      players: players,
      currentPlayerIndex: currentPlayerIndex,
      turnTimeLeft: turnTimeLeft,
      turnRotationClockwise: true,
      status: GameStatus.ready,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentChoice: true,
      clearCurrentEventDescription: true,
      clearCurrentInterruption: true,
    ));

    notifyListeners();
  }

  void setupTestGame() {
    initializeGame(
      playerNames: ['Andy', 'Bob'], // 'Celene', 'Dwayne'],
      gameMode: FunGameMode(),
    );
  }

  void setGameOverCallback(VoidCallback callback) {
    _onGameOver = callback;
  }

  void clearGameOverCallback() {
    _onGameOver = null;
  }

  void startGame() {
    if (_state.status == GameStatus.ready) {
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.playing,
      ));
      _startTimer();
      _generateNewTurn();
      notifyListeners();
    }
  }

  void togglePause() {
    if (_state.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.paused,
      ));
    } else if (_state.status == GameStatus.paused) {
      _startTimer();
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.playing,
      ));
    }
    notifyListeners();
  }

  void endTurn() {
    // Preliminary ends the turn
    if (_state.status == GameStatus.playing ||
        _state.status == GameStatus.winTest) {
      _state = _state.copyWith(GameStateUpdate(
        turnTimeLeft: 0.1,
      ));
      notifyListeners();
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
    if (_state.currentInterruption != null) {
      return;
    }

    if (_state.turnTimeLeft <= 0) {
      skipNextEndRoundSound
          ? skipNextEndRoundSound = false
          : await _audioService.playEndTurn();
      await _handleTurnEnd();
    }

    final newTimeLeft = _state.turnTimeLeft - 0.1;
    _state = _state.copyWith(GameStateUpdate(
      turnTimeLeft: newTimeLeft,
    ));

    await _audioService.playHeartbeat(_state.turnTimeLeft);
    notifyListeners();
  }

  Future<void> _handleTurnEnd() async {
    // Handle win test results if active.
    if (_state.status == GameStatus.winTest) {
      _handleInterruption(
          WinTestInterruption(null, phase: WinTestPhase.result));
      return;
    }
    _gameTimer?.cancel();

    // Check if round is complete
    // TODO: Fix round end bug when last player is eliminated.
    // Interruption is shown after 1st player then, not before.
    if (playerTurnCount >= _state.players.length) {
      if (_state.gameMode is MasterGameMode) {
        _incrementRound();
      } else {
        _handleInterruption(RoundEndInterruption());
        return;
      }
    }

    _moveToNextPlayer();
    _resetTurn();
    _generateNewTurn();
    _startTimer();

    notifyListeners();
  }

  void _moveToNextPlayer() {
    // Calculate new player index
    final int newIndex = _state.turnRotationClockwise
        ? (_state.currentPlayerIndex + 1) % _state.players.length
        : (_state.currentPlayerIndex - 1 + _state.players.length) %
            _state.players.length;

    // Save new player index
    _state = _state.copyWith(GameStateUpdate(
      currentPlayerIndex: newIndex,
    ));

    playerTurnCount++;

    if (_state.players[newIndex].isEliminated) {
      _moveToNextPlayer();
    }
  }

  void _resetTurn() {
    _state = _state.copyWith(GameStateUpdate(
      additionalTime: 0.0,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentInterruption: true,
      clearCurrentEventDescription: true,
      clearCurrentChoice: true,
      // clearCurrentEvent: true,
    ));

    _resetTurnTimeLeft();
  }

  void _generateNewTurn() {
    // Increase event probabilities
    _accumulateEventProbabilities();

    // Check for strategic events
    if (_state.scheduledEvents.isNotEmpty) {
      for (var event in _state.scheduledEvents) {
        if (event.triggerRound == _state.currentRound &&
            event.triggerPlayerIndex == _state.currentPlayerIndex) {
          _handleInterruption(EventInterruption(event.executionEvent));
          // Remove event from list
          _state = _state.copyWith(GameStateUpdate(
            scheduledEvents:
                _state.scheduledEvents.where((e) => e != event).toList(),
          ));
          return;
        }
      }
    }

    // Calculate whether event should be triggered
    final GameEvent? event = EventManager.createEvent(_state);

    if (event != null) {
      _handleInterruption(EventInterruption(event));
    } else {
      // Generate a new object if no event is triggered
      _generateRandomObject();
    }
  }

  void _handleInterruption(GameInterruption interruption) {
    _gameTimer?.cancel();

    _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.interrupted,
        currentInterruption: interruption,
        clearCurrentChoice: true));

    _skipChoiceIfNeeded(interruption); // Skips "Confirm" button in Master game mode

    notifyListeners();
  }

  void _skipChoiceIfNeeded(GameInterruption interruption) {
    if (_state.gameMode is MasterGameMode 
        && interruption is EventInterruption
        && interruption.event.requiresConfirmation == false){
          handleInterruptionChoice(0);
    }
  }

  void handleInterruptionChoice(int choice) {
    final interruption = _state.currentInterruption;
    if (interruption == null) return;

    if (interruption is EventInterruption) {
      _handleEventInterruptionChoice(interruption, choice);
    } else if (interruption is WinTestInterruption) {
      _handleWinTestInterruptionChoice(interruption, choice);
    } else if (interruption is RoundEndInterruption) {
      _handleRoundEndInterruptionChoice(interruption, choice);
    }
  }

  void _handleEventInterruptionChoice(
      EventInterruption interruption, int choice) {
    final newState = interruption.event.execute(_state, choice);

    _state = newState.copyWith(GameStateUpdate(
        status: GameStatus.playing,
        additionalTime: interruption.additionalTime,
        currentEventDescription: interruption.description,
        currentChoice: interruption.getChoices()[choice],
        clearCurrentInterruption: true));

    _resetTurnTimeLeft();
    _startTimer();
    notifyListeners();
  }

  void _resetTurnTimeLeft() {
    _state = _state.copyWith(GameStateUpdate(
        turnTimeLeft: _state.gameMode.calculateTurnLength(
                _state.players.length, _state.currentRound) +
            _state.additionalTime));
  }

  void _handleWinTestInterruptionChoice(
      WinTestInterruption interruption, int choice) {
    switch (interruption.phase) {
      case WinTestPhase.confirmation:
        _state = _state.copyWith(GameStateUpdate(
          status: GameStatus.winTest,
          additionalTime: interruption.additionalTime,
          clearCurrentObject: true,
          clearCurrentObjectColor: true,
          clearCurrentInterruption: true,
          currentChoice: interruption.winEvent!.getChoices()[0],
          currentEventDescription: interruption.description,
        ));
        _resetTurnTimeLeft();
        _startTimer();
        notifyListeners();
        break;

      case WinTestPhase.test:
        // _handleInterruption(WinTestInterruption(interruption.winEvent, phase: WinTestPhase.result));
        break;

      case WinTestPhase.result:
        if (choice == 0) {
          _handleWinSuccess();
          if (_state.status == GameStatus.gameOver) {
            return;
          }
        } else {
          _handleWinFailure();
        }
        _state = _state.copyWith(GameStateUpdate(
          status: GameStatus.playing,
          clearCurrentInterruption: true,
        ));
        _handleTurnEnd();
        break;
    }
    notifyListeners();
  }

  void _handleRoundEndInterruptionChoice(
      RoundEndInterruption interruption, int choice) {
    skipNextEndRoundSound = true;
    _incrementRound();
    _startTimer();
  }

  void _incrementRound() {
    playerTurnCount = 0;
    final newRound = _state.currentRound + 1;

    if (_state.gameMode is MasterPlusGameMode){
      final shuffledPlayers = List<Player>.from(_state.players)..shuffle();
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.playing,
        currentRound: newRound,
        players: shuffledPlayers,
        currentPlayerIndex: 0,  // Reset to first player in new order
        clearCurrentInterruption: true,
      ));
    } else {
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.playing,
        currentRound: newRound,
        clearCurrentInterruption: true,
      ));
    }
  }

  void _accumulateEventProbabilities() {
    // Add base probabilities every turn
    _state.currentPlayer.storedEventProbabilities.forEach((type, prob) {
      final base = _state.gameMode.getBaseEventProbability(type);
      _state.currentPlayer.storedEventProbabilities[type] = prob + base;
    });
  }

  void _generateRandomObject() {
    final (object, color) = GameLogic.generateRandomObject(
      keyProbability: _state.gameMode.calculateKeyProbability(
        _state.currentRound,
        currentPlayer.keyObjectCount,
      ),
      greenProbability: GameLogic.calculateGreenProbability(currentPlayer),
      previousObject: _state.currentObject,
    );

    _loggingService.log(
      'generate_object',
      data: {
        'object': object,
        'color': color,
        'player': currentPlayer.name,
        'round': _state.currentRound,
      },
    );

    // Add object to list of player objects
    String colorString = color == FlavaTheme.greenObjectColor ? 'green' : 'red';

    currentPlayer.addObject(object, colorString);
    _state.players.updatePlayer(currentPlayer);

    // Fix: Assign the state update properly
    _state = _state.copyWith(GameStateUpdate(
      // Add assignment operator here
      currentObject: object,
      currentObjectColor: color,
      players: _state.players,
    ));

    notifyListeners();
  }

  void startWinTest() {
    GameEvent winEvent = EventManager.createWinEvent(_state);
    _handleInterruption(
        WinTestInterruption(winEvent, phase: WinTestPhase.confirmation));
  }

  void _handleWinSuccess() async {
    await _audioService.playWin();
    // If first to win, player is winner
    currentPlayer.isWinner = _state.players.every((player) => !player.isWinner);
    // After win, player is eliminated
    currentPlayer.isEliminated = true;

    _state = _state.copyWith(
        GameStateUpdate(players: _state.players.updatePlayer(currentPlayer)));

    if (_checkGameFinish()) {
      _endGame();
    }
  }

  void _handleWinFailure() async {
    // If not first to win, player is eliminated
    await _audioService.playEliminate();
    currentPlayer.removeKeyObject();
    _state = _state.copyWith(
        GameStateUpdate(players: _state.players.updatePlayer(currentPlayer)));
  }

  bool _checkGameFinish() {
    // If only one player not eliminated, game is finished
    return _state.players.where((p) => !p.isEliminated).length == 1;
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();

    _state = _state.copyWith(GameStateUpdate(
      status: GameStatus.gameOver,
      // players: updatedPlayers,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentInterruption: true,
    ));

    await _recordGameEnd();

    notifyListeners();

    _onGameOver?.call();
  }

  Future<void> _recordGameEnd() async {
    // await _storageService.saveGameResults({
    //   'user_id': _userId,
    //   'game_id': _gameId,
    //   'game_mode': _state.gameMode.toString(),
    //   'players': _state.players.map((p) => p.toJson()).toList(),
    //   'max_round': _state.currentRound,
    //   'winner_id': currentPlayer.id,
    //   'timestamp': DateTime.now().millisecondsSinceEpoch,
    // });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
