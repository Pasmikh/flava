import 'package:flava/screens/game_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Import local files
import 'models/game_state.dart';
import 'providers/game_provider.dart';
import 'services/storage_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/player_setup/player_setup_screen.dart';
import 'screens/ready_check/ready_check_screen.dart';
import 'screens/game/game_screen.dart';
import 'services/audio_service.dart';
import 'config/theme.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations based on PRD requirement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize services
  final audioService = await AudioService.initialize();

  // Create game provider instance
  final gameProvider = GameProvider(
    audioService: audioService,
    storageService: StorageService(),
  );

  // Set up test game
  // gameProvider.setupTestGame();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameProvider),
        ProxyProvider<GameProvider, GameState>(
          update: (context, gameProvider, previous) => gameProvider.state,
        ),
      ],
      child: const FlavaApp(),
    ),
  );
}

class FlavaApp extends StatelessWidget {
  const FlavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flava',
      theme: FlavaTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      // initialRoute: AppRoutes.readyCheck, // For test
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.playerSetup: (context) => const PlayerSetupScreen(),
        AppRoutes.readyCheck: (context) => const ReadyCheckScreen(),
        AppRoutes.game: (context) => const GameScreen(),
        AppRoutes.gameStats: (context) => const GameStatsScreen(),
      },
      builder: (context, child) {
        // Apply any app-wide configurations here
        return MediaQuery(
          // Force app to maintain its own text scaling
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
