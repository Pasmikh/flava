import 'package:flutter/material.dart';
import 'package:flava/models/game_mode.dart';
import 'package:flava/models/player.dart';
import 'package:flava/models/game_event.dart';
import 'package:flava/providers/game_provider.dart';

class GameState {
  // Core game state (data only)
  final GameMode gameMode;
  final List<Player> players;
  final int currentPlayerIndex;
  final int currentRound;
  final GameStatus status;
  final bool turnRotationClockwise;

  // Timer state
  final double turnTimeLeft;
  final double additionalTime;

  // Game objects and events
  final String? currentObject;
  final Color? currentObjectColor;
  final GameEvent? currentEvent;
  final List<String> choices;
  final String? currentChoice;

  const GameState({
    required this.gameMode,
    required this.players,
    this.currentPlayerIndex = 0,
    this.currentRound = 1,
    this.status = GameStatus.initial,
    this.turnRotationClockwise = true,
    this.turnTimeLeft = 0.0,
    this.additionalTime = 0.0,
    this.currentObject,
    this.currentObjectColor,
    this.currentEvent,
    this.choices = const [],
    this.currentChoice,
  });

  // Computed properties
  Player get currentPlayer => players[currentPlayerIndex];

  double get turnProgress =>
      turnTimeLeft /
      (gameMode.calculateTurnLength(players.length, currentRound) +
          additionalTime);

  // Create a new state with updated values
  GameState copyWith(GameStateUpdate update) {
    return GameState(
      gameMode: update.gameMode ?? gameMode,
      players: update.players ?? players,
      currentPlayerIndex: update.currentPlayerIndex ?? currentPlayerIndex,
      currentRound: update.currentRound ?? currentRound,
      status: update.status ?? status,
      turnRotationClockwise:
          update.turnRotationClockwise ?? turnRotationClockwise,
      turnTimeLeft: update.turnTimeLeft ?? turnTimeLeft,
      additionalTime: update.additionalTime ?? additionalTime,
      currentObject: update.clearCurrentObject
          ? null
          : (update.currentObject ?? currentObject),
      currentObjectColor: update.clearCurrentObjectColor
          ? null
          : (update.currentObjectColor ?? currentObjectColor),
      currentEvent: update.clearCurrentEvent
          ? null
          : (update.currentEvent ?? currentEvent),
      choices: update.choices ?? choices,
      currentChoice: update.clearCurrentChoice
          ? null
          : (update.currentChoice ?? currentChoice),
    );
  }
}

class GameStateUpdate {
  final GameMode? gameMode;
  final List<Player>? players;
  final int? currentPlayerIndex;
  final int? currentRound;
  final GameStatus? status;
  final bool? turnRotationClockwise;
  final double? turnTimeLeft;
  final double? additionalTime;
  final String? currentObject;
  final Color? currentObjectColor;
  final GameEvent? currentEvent;
  final List<String>? choices;
  final String? currentChoice;
  final bool clearCurrentObject;
  final bool clearCurrentObjectColor;
  final bool clearCurrentEvent;
  final bool clearCurrentChoice;

  GameStateUpdate({
    this.gameMode,
    this.players,
    this.currentPlayerIndex,
    this.currentRound,
    this.status,
    this.turnRotationClockwise,
    this.turnTimeLeft,
    this.additionalTime,
    this.currentObject,
    this.currentObjectColor,
    this.currentEvent,
    this.choices,
    this.currentChoice,
    this.clearCurrentObject = false,
    this.clearCurrentObjectColor = false,
    this.clearCurrentEvent = false,
    this.clearCurrentChoice = false,
  });
}
