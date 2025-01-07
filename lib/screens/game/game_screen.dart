import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import 'widgets/game_timer.dart';
import 'widgets/player_display.dart';
import 'widgets/object_display.dart';
import 'widgets/event_buttons.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameProvider gameProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameProvider = context.read<GameProvider>();
    gameProvider.setGameOverCallback(_handleGameOver);
  }

  void _handleGameOver() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.gameStats);
    }
  }

  @override
  void dispose() {
    if (mounted) {
      gameProvider.clearGameOverCallback();
    }
    super.dispose();
  }

  void _handlePause(BuildContext context) {
    context.read<GameProvider>().togglePause();
  }

  void _handleEndTurn(BuildContext context) {
    context.read<GameProvider>().endTurn();
  }

  void _handleExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text(
            'Are you sure you want to exit? The game progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _handleWinTest(BuildContext context) {
    context.read<GameProvider>().startWinTest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Only show event description if we're in eventChoice status
          final displayText = gameState.currentInterruption != null
              ? gameState.currentInterruption?.description ?? ''
              : gameState.currentObject ?? gameState.currentEventDescription ?? '';

          return SafeArea(
            child: Column(
              children: [
                // Top player (rotated)
                Transform.rotate(
                  angle: math.pi,
                  child: PlayerDisplay(
                    player: gameState.currentPlayer,
                    turnText: displayText,
                    isTop: true,
                  ),
                ),

                // Game area
                Expanded(
                  child: _buildGameArea(context, gameState),
                ),

                // Bottom player
                PlayerDisplay(
                  player: gameState.currentPlayer,
                  turnText: displayText,
                  isTop: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameArea(BuildContext context, GameState gameState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        final buttonRadius = math.min(centerX, centerY) * 1.02;
        final timerSize = math.min(centerX, centerY) * 0.72;
        final objectSize = math.min(centerX, centerY) * 0.68;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Center circle (timer)
            Center(
              child: Container(
                width: timerSize * 2,
                height: timerSize * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const GameTimer(),
              ),
            ),

            // Object display in center
            Center(
              child: SizedBox(
                width: objectSize * 2,
                height: objectSize * 2,
                child: (gameState.currentInterruption != null)
                    ? EventButtons()
                    : ObjectDisplay(
                        objectName: gameState.currentChoice ??
                            gameState.currentObject ??
                            '',
                        objectColor:
                            gameState.currentObjectColor ?? Colors.white,
                        forceTextDisplay: gameState.currentChoice != null,
                      ),
              ),
            ),

            // Control buttons
            ..._buildControlButtons(
              centerX: centerX,
              centerY: centerY,
              radius: buttonRadius,
              gameState: gameState,
              context: context,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildControlButtons({
    required double centerX,
    required double centerY,
    required double radius,
    required GameState gameState,
    required BuildContext context,
  }) {
    // Use the larger buttonRadius passed from parent
    final buttonSize = 56.0;
    final halfButtonSize = buttonSize / 2;

    final buttons = [
      // Top-right (Pause)
      {
        'x': centerX + (radius * math.cos(math.pi / 4)),
        'y': centerY - (radius * math.sin(math.pi / 4)),
        'icon': Icon(
          gameState.status == GameStatus.playing
              // ? FontAwesomeIcons.pause
              ? Icons.pause
              // : FontAwesomeIcons.play,
              : Icons.play_arrow,
          color: FlavaTheme.primaryColor,
        ),
        'onPressed': () => _handlePause(context),
      },
      // Top-left (End Turn)
      {
        'x': centerX - (radius * math.cos(math.pi / 4)),
        'y': centerY - (radius * math.sin(math.pi / 4)),
        // 'icon': Icon(FontAwesomeIcons.forward, color: FlavaTheme.primaryColor),
        'icon': Icon(Icons.forward, color: FlavaTheme.primaryColor),
        'onPressed': () => _handleEndTurn(context),
      },
      // Bottom-right (Exit)
      {
        'x': centerX + (radius * math.cos(math.pi / 4)),
        'y': centerY + (radius * math.sin(math.pi / 4)),
        // 'icon': Icon(FontAwesomeIcons.rightFromBracket,
        'icon': Icon(Icons.exit_to_app, color: FlavaTheme.primaryColor),
        'onPressed': () => _handleExit(context),
      },
      // Bottom-left (Finish)
      {
        'x': centerX - (radius * math.cos(math.pi / 4)),
        'y': centerY + (radius * math.sin(math.pi / 4)),
        // 'icon': Icon(FontAwesomeIcons.flagCheckered,
        'icon': Icon(Icons.flag, color: FlavaTheme.primaryColor),
        'onPressed': () => _handleWinTest(context), // No action for now
      },
    ];

    return buttons.map((button) {
      return Positioned(
        left: (button['x'] as double) - halfButtonSize,
        top: (button['y'] as double) - halfButtonSize,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            iconSize: 32,
            icon: button['icon'] as Icon,
            onPressed: button['onPressed'] as VoidCallback,
          ),
        ),
      );
    }).toList();
  }
}
