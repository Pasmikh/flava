import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/player_setup/player_setup_screen.dart';
import '../screens/ready_check/ready_check_screen.dart';
import '../screens/game/game_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String playerSetup = '/player-setup';
  static const String readyCheck = '/ready-check';
  static const String game = '/game';
  static const String settings = '/settings';
  static const String statistics = '/statistics';

  // Route map
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      playerSetup: (context) => const PlayerSetupScreen(),
      readyCheck: (context) => const ReadyCheckScreen(),
      game: (context) => const GameScreen(),
    };
  }

  // Navigation helpers
  static Future<T?> navigateToPlayerSetup<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, playerSetup);
  }

  static Future<T?> navigateToReadyCheck<T>(BuildContext context) {
    return Navigator.pushReplacementNamed<T, void>(context, readyCheck);
  }

  static Future<T?> navigateToGame<T>(BuildContext context) {
    return Navigator.pushReplacementNamed<T, void>(context, game);
  }

  static Future<T?> navigateToSettings<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, settings);
  }

  static Future<T?> navigateToStatistics<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, statistics);
  }

  static void popToHome(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName(home));
  }

  // Custom transitions
  static PageRoute createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}