import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';
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
  final _focusNode = FocusNode();
  final List<String> _playerNames = [];
  static const int maxPlayers = 5;
  static const int minPlayers = 2;

  @override
  void dispose() {
    _playerNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && _playerNames.length < maxPlayers) {
      setState(() {
        _playerNames.add(name);
        _playerNameController.clear();
        // Unfocus before clearing
        _focusNode.unfocus();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _playerNames.removeAt(index);
    });
  }

  void _startGame(GameMode mode) {
    if (_playerNames.length >= minPlayers) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.initializeGame(
        playerNames: _playerNames,
        gameMode: mode,
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
              // Header
              Text(
                'Enter Player Names',
                style: FlavaTheme.headerStyle,
              ),
              const SizedBox(height: 16),
              // Player name input field
              TextField(
                controller: _playerNameController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Player name',
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

              // Hint if not enough players
              if (_playerNames.length < minPlayers) ...[
                const SizedBox(height: 16),
                Text(
                  'Add at least $minPlayers players to start the game',
                  style: FlavaTheme.textStyle,
                ),
              ],

              // Action buttons
              // if (_playerNames.isNotEmpty) ...[
              //   ElevatedButton(
              //     onPressed: _clearPlayers,
              //     child: const Text('Clear All Players'),
              //   ),
              //   const SizedBox(height: 16),
              // ],

              // Game mode selection
              if (_playerNames.length >= minPlayers) ...[
                Text(
                  'Select Game Mode',
                  style: FlavaTheme.headerStyle,
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _GameModeButton(
                          modeName: BeginnerGameMode().name,
                          onPressed: () => _startGame(BeginnerGameMode()),
                        ),
                        _GameModeButton(
                          modeName: FunGameMode().name,
                          onPressed: () => _startGame(FunGameMode()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Add some spacing between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _GameModeButton(
                          modeName: MasterGameMode().name,
                          onPressed: () => _startGame(MasterGameMode()),
                        ),
                        _GameModeButton(
                          modeName: MasterPlusGameMode().name,
                          onPressed: () => _startGame(MasterPlusGameMode()),
                        ),
                      ],
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
  final String modeName;
  final VoidCallback onPressed;

  const _GameModeButton({
    required this.modeName,
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
        modeName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
