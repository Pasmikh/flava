import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import 'widgets/game_timer.dart';
import 'widgets/player_display.dart';
import 'widgets/object_display.dart';
import 'widgets/event_buttons.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _handlePause(BuildContext context) {
    final gameState = context.read<GameState>();
    if (gameState.status == GameStatus.playing) {
      gameState.pauseGame();
    } else if (gameState.status == GameStatus.paused) {
      gameState.resumeGame();
    }
  }

  void _handleNextTurn(BuildContext context) {
    final gameState = context.read<GameState>();
    // Force end current turn
    // This will trigger the turn end logic in GameState
    gameState.endCurrentTurn();
  }

  void _handleExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit? The game progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top player display (rotated 180 degrees)
                    Transform.rotate(
                      angle: 3.14159, // 180 degrees in radians
                      child: PlayerDisplay(
                        player: gameState.currentPlayer,
                        turnText: gameState.currentObject,
                        isTop: true,
                      ),
                    ),
                    
                    // Game area with timer and object
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Timer circle
                          const GameTimer(),
                          
                          // Object display
                          ObjectDisplay(
                            objectName: gameState.currentObject,
                          ),
                          
                          // Event buttons (when needed)
                          if (gameState.status == GameStatus.eventChoice)
                            const EventButtons(),
                        ],
                      ),
                    ),

                    // Bottom player display
                    PlayerDisplay(
                      player: gameState.currentPlayer,
                      turnText: gameState.currentObject,
                      isTop: false,
                    ),
                  ],
                ),

                // Control buttons
                Positioned(
                  left: 0,
                  bottom: kToolbarHeight + 80,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            gameState.status == GameStatus.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () => _handlePause(context),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () => _handleNextTurn(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Exit button
                Positioned(
                  right: 8,
                  bottom: kToolbarHeight + 80,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => _handleExit(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}