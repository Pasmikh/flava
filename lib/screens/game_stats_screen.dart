import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class GameStatsScreen extends StatelessWidget {
  const GameStatsScreen({super.key});

  void _restartGame(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final List<String> playerNames = 
        gameProvider.state.players.map((p) => p.name).toList();
    final gameMode = gameProvider.state.gameMode;
    
    gameProvider.initializeGame(
      playerNames: playerNames,
      gameMode: gameMode,
    );
    Navigator.pushReplacementNamed(context, AppRoutes.readyCheck);
  }

  void _goToMainMenu(BuildContext context) {
    AppRoutes.popToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Safely find winner or return null
          final winner = gameState.players.where((p) => p.isWinner).firstOrNull;
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Game Over!',
                    style: FlavaTheme.headerStyle,
                  ),
                  const SizedBox(height: 32),
                  if (winner != null) Text(
                    'Winner: ${winner.name}',
                    style: FlavaTheme.subheaderStyle,
                  ),
                  const SizedBox(height: 24),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Statistics',
                            style: FlavaTheme.subheaderStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Rounds Played: ${gameState.currentRound}'),
                          if (winner != null) ...[
                            Text('Total Objects: ${winner.totalObjectCount}'),
                            Text('Key Objects: ${winner.keyObjectCount}'),
                          ],
                          const SizedBox(height: 8),
                          Text('Game Mode: ${gameState.gameMode.name}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _restartGame(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlavaTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _goToMainMenu(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlavaTheme.accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Main Menu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}