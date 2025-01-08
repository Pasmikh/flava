import 'package:flava/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class ReadyCheckScreen extends StatelessWidget {
  const ReadyCheckScreen({super.key});

  void _startGame(BuildContext context) async {
    await AudioService.getInstance().initialize();

    if (!context.mounted) return;

    final gameProvider = context.read<GameProvider>();
    gameProvider.startGame();
    Navigator.pushReplacementNamed(context, AppRoutes.game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Ready!',
                      style: FlavaTheme.headerStyle,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Players: ${gameState.players.length}',
                      style: FlavaTheme.textStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Game Mode: ${gameState.gameMode.name}',
                      style: FlavaTheme.textStyle,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () => _startGame(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlavaTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
