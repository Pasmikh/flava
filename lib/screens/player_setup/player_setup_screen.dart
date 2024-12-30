import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../models/game_mode.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final _playerNameController = TextEditingController();
  final List<String> _playerNames = [];
  static const int maxPlayers = 5;
  static const int minPlayers = 2;

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && _playerNames.length < maxPlayers) {
      setState(() {
        _playerNames.add(name);
        _playerNameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _playerNames.removeAt(index);
    });
  }

  void _clearPlayers() {
    setState(() {
      _playerNames.clear();
      _playerNameController.clear();
    });
  }

  void _startGame(GameMode mode) {
    if (_playerNames.length >= minPlayers) {
      final gameState = context.read<GameState>();
      gameState.initializeGame(
        playerNames: _playerNames,
        gameMode: mode,
        initialTurnLength: GameModeConfig.getInitialTurnLength(mode, _playerNames.length),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.readyCheck);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAddPlayer = _playerNames.length < maxPlayers;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Player name input field
              TextField(
                controller: _playerNameController,
                decoration: InputDecoration(
                  hintText: 'Enter player name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: canAddPlayer ? _addPlayer : null,
                  ),
                ),
                enabled: canAddPlayer,
                onSubmitted: (_) => canAddPlayer ? _addPlayer() : null,
              ),
              const SizedBox(height: 16),

              // Player list
              Expanded(
                child: ListView.builder(
                  itemCount: _playerNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _playerNames[index],
                        style: FlavaTheme.textStyle,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removePlayer(index),
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              if (_playerNames.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: _clearPlayers,
                  child: const Text('Clear All Players'),
                ),
                const SizedBox(height: 16),
              ],

              // Game mode selection
              if (_playerNames.length >= minPlayers) ...[
                const Text(
                  'Select Game Mode',
                  style: FlavaTheme.headerStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _GameModeButton(
                      mode: GameMode.beginner,
                      onPressed: () => _startGame(GameMode.beginner),
                    ),
                    _GameModeButton(
                      mode: GameMode.fun,
                      onPressed: () => _startGame(GameMode.fun),
                    ),
                    _GameModeButton(
                      mode: GameMode.master,
                      onPressed: () => _startGame(GameMode.master),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GameModeButton extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onPressed;

  const _GameModeButton({
    required this.mode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FlavaTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        GameModeConfig.displayNames[mode]!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}