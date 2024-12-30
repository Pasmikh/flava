import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../config/theme.dart';

class PlayerDisplay extends StatelessWidget {
  final Player player;
  final String turnText;
  final bool isTop;

  const PlayerDisplay({
    super.key,
    required this.player,
    required this.turnText,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player name banner
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: double.infinity,
            color: FlavaTheme.primaryColor,
            alignment: Alignment.center,
            child: Text(
              player.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Turn text area
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                turnText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FlavaTheme.textColor,
                  fontSize: 22,
                  height: 1.2,
                  // Parse and maintain markup from the original implementation
                  fontWeight: turnText.contains('UPPER') ? 
                    FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}