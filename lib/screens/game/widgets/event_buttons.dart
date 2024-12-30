import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/game_state.dart';
import '../../../config/theme.dart';

class EventButtons extends StatelessWidget {
  const EventButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final screenSize = MediaQuery.of(context).size;
        final buttonSize = screenSize.height * 0.4 * 0.7;
        
        return SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Stack(
            children: [
              // Background circle
              CustomPaint(
                size: Size(buttonSize, buttonSize),
                painter: EventButtonsPainter(
                  backgroundColor: FlavaTheme.primaryColor,
                  buttonCount: 4, // Default to 4 buttons
                ),
              ),
              
              // Event choice buttons
              ...List.generate(4, (index) {
                final angle = (index * 90 - 45) * 3.14159 / 180;
                return Positioned(
                  left: buttonSize / 2 + buttonSize * 0.3 * cos(angle) - 60,
                  top: buttonSize / 2 + buttonSize * 0.3 * sin(angle) - 30,
                  child: SizedBox(
                    width: 120,
                    height: 60,
                    child: EventChoiceButton(
                      index: index,
                      onPressed: () => _handleEventChoice(context, index),
                    ),
                  ),
                );
              }),
              
              // Center text display
              if (gameState.currentEvent?.description != null)
                Transform.rotate(
                  angle: 3.14159, // 180 degrees
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        gameState.currentEvent!.description, // What if it's null?
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleEventChoice(BuildContext context, int index) {
    final gameState = context.read<GameState>();
    gameState.handleEventChoice(index);
  }
}

class EventChoiceButton extends StatelessWidget {
  final int index;
  final VoidCallback onPressed;

  const EventChoiceButton({
    super.key,
    required this.index,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final buttonText = gameState.currentEvent?.choices[index];
        
        if (buttonText == null) return const SizedBox.shrink();

        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}

class EventButtonsPainter extends CustomPainter {
  final Color backgroundColor;
  final int buttonCount;

  EventButtonsPainter({
    required this.backgroundColor,
    required this.buttonCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Draw main circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw dividing lines
    paint.color = Colors.white.withOpacity(0.3);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    if (buttonCount >= 2) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
    
    if (buttonCount >= 4) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(EventButtonsPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.buttonCount != buttonCount;
  }
}