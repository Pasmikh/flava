import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                Text(
                  AppConstants.appName,
                  style: FlavaTheme.headerStyle.copyWith(
                    fontSize: 48,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Main Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => AppRoutes.navigateToPlayerSetup(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Start New Game',
                      style: FlavaTheme.buttonTextStyle.copyWith(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Secondary Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => AppRoutes.navigateToStatistics(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlavaTheme.accentColor,
                        ),
                        child: Text(
                          'Statistics',
                          style: FlavaTheme.buttonTextStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => AppRoutes.navigateToSettings(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlavaTheme.accentColor,
                        ),
                        child: Text(
                          'Settings',
                          style: FlavaTheme.buttonTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Version Info
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: FlavaTheme.textStyle.copyWith(
                    color: FlavaTheme.textColor.withAlpha(150),
                  ),
                ),
                
                const Spacer(),
                
                // How to Play
                TextButton(
                  onPressed: () => _showGameRules(context),
                  child: Text(
                    'How to Play',
                    style: FlavaTheme.textStyle.copyWith(
                      color: FlavaTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to Play',
                style: FlavaTheme.subheaderStyle,
              ),
              const SizedBox(height: 16),
              const Text(
                'Flava is a companion app for the physical board game. '
                'It helps manage turns, track game events, and calculate scores.\n\n'
                '1. Select 2-5 players to start a game\n'
                '2. Choose your game mode (Learn, Have Fun, or Master)\n'
                '3. Follow the on-screen instructions during gameplay\n'
                '4. Use the timer to track turn duration\n'
                '5. Handle special events as they occur',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}