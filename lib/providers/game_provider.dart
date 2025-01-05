import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/game_state.dart';
import '../models/game_event.dart';
import '../services/game_logic.dart';
import '../services/event_handler.dart';
import '../services/logging_service.dart';
import '../config/theme.dart';
import '../extensions/player_list_extension.dart';

class GameProvider extends ChangeNotifier {
  late GameState _state;

  final LoggingService _loggingService = LoggingService();
  final AudioService _audioService;
  final StorageService _storageService;
  Timer? _gameTimer;
  late int _gameId;
  late int _userId;

  GameProvider({
    required AudioService audioService,
    required StorageService storageService,
  })  : _audioService = audioService,
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
  Player get currentPlayer => _state.players[_state.currentPlayerIndex];
  bool get isPaused => _state.status == GameStatus.paused;

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
        DateTime.now().millisecondsSinceEpoch % players.length;

    _state = _state.copyWith(GameStateUpdate(
      gameMode: gameMode,
      players: players,
      currentPlayerIndex: currentPlayerIndex,
      turnTimeLeft: turnTimeLeft,
      status: GameStatus.ready,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentEvent: true,
      clearCurrentChoice: true,
      choices: [],
    ));

    notifyListeners();
  }

  void setupTestGame() {
    initializeGame(
      playerNames: ['Andy', 'Bob', 'Celene', 'Dwayne'],
      gameMode: FunGameMode(),
    );
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
    if (_state.status == GameStatus.playing) {
      if (_state.status == GameStatus.playing) {
        _state = _state.copyWith(GameStateUpdate(
          turnTimeLeft: 0.1,
        ));
        notifyListeners();
      }
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
    if (_state.status == GameStatus.eventChoice ||
        _state.status == GameStatus.winTestConfirmation) {
      return;
    }

    if (_state.turnTimeLeft <= 0) {
      await _handleTurnEnd();
    } else {
      final newTimeLeft = _state.turnTimeLeft - 0.1;
      _state = _state.copyWith(GameStateUpdate(
        turnTimeLeft: newTimeLeft,
      ));
      // _loggingService.log('Heartbeat method trigger', data:{});
      await _playHeartbeatSounds();
      notifyListeners();
    }
  }

  Future<void> _playHeartbeatSounds() async {
    await _audioService.playHeartbeat(_state.turnTimeLeft);
  }

  Future<void> _handleTurnEnd() async {
    // Handle win test results if active.
    if (state.status == GameStatus.winTest) {
      _gameTimer?.cancel();
      _showWinTestButtons();
      return;
    }

    _loggingService.log(
      'turn_end',
      data: {
        'player': currentPlayer.name,
        'round': _state.currentRound,
        'objects_count': {
          'red': currentPlayer.redObjects,
          'green': currentPlayer.greenObjects,
          'key': currentPlayer.keyObjectCount,
        },
      },
    );

    _gameTimer?.cancel();
    await _audioService.playEndTurn();

    // Handle any pending event before ending the turn
    if (_state.status == GameStatus.eventChoice &&
        _state.currentEvent != null) {
      final newState = _state.currentEvent!.execute(_state, 0);
      // Make sure to reset the status to playing
      _state = newState.copyWith(GameStateUpdate(
        status: GameStatus.playing,
      ));
    }

    if (_checkGameFinish()) {
      await _endGame();
      return;
    }

    if (_shouldStartNewRound()) {
      await _startNewRound();
    }

    _moveToNextPlayer();
    _resetTurn();
    _generateNewTurn();
    _startTimer();

    notifyListeners();
  }

  void _moveToNextPlayer() {
    final newIndex = _state.turnRotationClockwise
        ? (_state.currentPlayerIndex + 1) % _state.players.length
        : (_state.currentPlayerIndex - 1 + _state.players.length) %
            _state.players.length;

    _state = _state.copyWith(GameStateUpdate(
      currentPlayerIndex: newIndex,
    ));
  }

  bool _shouldStartNewRound() {
    return (_state.currentPlayerIndex +
                (_state.turnRotationClockwise ? 1 : -1)) %
            _state.players.length ==
        0;
  }

  Future<void> _startNewRound() async {
    final newRound = _state.currentRound + 1;
    _state = _state.copyWith(GameStateUpdate(
      currentRound: newRound,
    ));

    // await _storageService.logGameEvent(
    //   turnRound: newRound,
    //   playerId: currentPlayer.id,
    //   playerName: currentPlayer.name,
    //   event: 'round_start',
    //   extra: newRound.toString(),
    // );
  }

  void _resetTurn() {
    final newTurnLength = _state.gameMode.calculateTurnLength(
      _state.players.length,
      _state.currentRound,
    );

    // _audioService.resetAudioState();

    _state = _state.copyWith(GameStateUpdate(
      turnTimeLeft: newTurnLength,
      additionalTime: 0.0,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentEvent: true,
      clearCurrentChoice: true,
      choices: [],
    ));
  }

  void _generateNewTurn() {
    // Increase event probabilities
    _accumulateEventProbabilities();

    // Calculate whether event should be triggered
    final GameEvent? event = EventManager.createEvent(_state);

    if (event != null) {
      _handleEvent(event);
    } else {
      // Generate a new object if no event is triggered
      _generateRandomObject();
    }
  }

  void _handleEvent(GameEvent event) {
    // Log event
    _loggingService.log(
      'event_triggered',
      data: {
        'event_type': event.type.toString(),
        'description': event.description,
        'player': currentPlayer.name,
        'round': _state.currentRound,
        'choices': event.getChoices(),
      },
    );

    if (event.resetsEventChance) {
      // Reset the probability for this event type
      state.currentPlayer.storedEventProbabilities[event.type] = 0.0;
    }

    // Pause the game timer when event triggers in fun mode
    _gameTimer?.cancel();

    _state = _state.copyWith(GameStateUpdate(
      currentEvent: event,
      choices: event.getChoices(),
      status: event.type == EventType.win
          ? GameStatus.winTestConfirmation
          : GameStatus.eventChoice,
      additionalTime: event.additionalTime,
      turnTimeLeft: _state.turnTimeLeft + event.additionalTime,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
    ));

    // If the event doesn't require confirmation, execute it immediately (but not in beginner mode)
    if ((!event.requiresConfirmation) &&
        (_state.gameMode is! BeginnerGameMode)) {
      final newState = event.execute(_state, 0);
      _state = newState.copyWith(GameStateUpdate(
        status: GameStatus.playing,
        currentChoice: event.choices.displayNames[0],
        choices: [],
      ));
      _startTimer();
    }

    notifyListeners();
  }

  void handleEventChoice(int choice) {
    // Handle win test if active
    if (_state.status == GameStatus.winTestConfirmation) {
      _state = _state.copyWith(GameStateUpdate(
        status: GameStatus.winTest,
        currentChoice: _state.choices[choice],
        choices: [],
      ));
      _startTimer();
      notifyListeners();
      return;
    } else if (_state.status == GameStatus.winTest) {
      _handleWinEventChoice(choice);
      return;
    }

    if (_state.status == GameStatus.eventChoice &&
        _state.currentEvent != null) {
      final event = _state.currentEvent!;

      // Log the event choice
      _loggingService.log(
        'event_choice',
        data: {
          'event_type': event.type.toString(),
          'description': event.description,
          'choice_index': choice,
          'choice_text': event.choices.displayNames[choice],
          'player': currentPlayer.name,
          'round': _state.currentRound,
        },
      );

      // Execute event and get new state
      final GameState newState = event.execute(_state, choice);

      // Update state with event results and reset event status
      _state = newState.copyWith(GameStateUpdate(
        status: GameStatus.playing,
        currentChoice: event.choices.displayNames[choice],
        choices: [],
      ));

      // Start the game timer again
      _startTimer();

      notifyListeners();
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
    _handleEvent(winEvent);
  }

  void _showWinTestButtons() {
    // After win test, show success and failure buttons
    _state = _state.copyWith(GameStateUpdate(
      choices: ['Success', 'Failure'],
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
    ));

    notifyListeners();
  }

  void _handleWinEventChoice(int choice) {
    if (choice == 0) {
      _handleWinSuccess();
    } else {
      _handleWinFailure();
    }

    _loggingService.log(
      'win_test_choice',
      data: {
        'player': currentPlayer.name,
        'round': _state.currentRound,
        'choice': choice,
      },
    );

    _state = _state.copyWith(GameStateUpdate(
      status: GameStatus.playing,
      currentChoice: _state.choices[choice],
      choices: [],
    ));

    _handleTurnEnd();
  }

  void _handleWinSuccess() {
    // If first to win, player is winner
    currentPlayer.isWinner = _state.players.every((player) => !player.isWinner);
    // After win, player is eliminated
    currentPlayer.isEliminated = true;
    _state.players.updatePlayer(currentPlayer);
  }

  void _handleWinFailure() {
    // If not first to win, player is eliminated
    currentPlayer.removeKeyObject();
    _state.players.updatePlayer(currentPlayer);
  }

  bool _checkGameFinish() {
    // If only one player not eliminated, game is finished
    return _state.players.where((p) => !p.isEliminated).length == 1;
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();

    final String winnerPlayerName =
        _state.players.firstWhere((p) => p.isWinner).name;

    _state = _state.copyWith(GameStateUpdate(
      status: GameStatus.gameOver,
      // players: updatedPlayers,
      clearCurrentEvent: true,
      clearCurrentObject: true,
      clearCurrentObjectColor: true,
      clearCurrentChoice: true,
      choices: [],
    ));

    await _audioService.playWin();
    await _recordGameEnd();

    notifyListeners();
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
