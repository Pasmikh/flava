import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../../models/game_state.dart';
import '../../../config/theme.dart';

class EventButtons extends StatelessWidget {
  const EventButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final buttonSize = min(constraints.maxWidth, constraints.maxHeight);
            final choicesCount =
                gameState.currentInterruption?.getChoices().length ?? 0;

            return SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: CustomPaint(
                child: GestureDetector(
                  onTapDown: (details) => _handleTap(
                    context,
                    details.localPosition,
                    Size(buttonSize, buttonSize),
                    choicesCount,
                  ),
                  child: CustomPaint(
                    painter: CircularSectionsPainter(
                      sections: choicesCount,
                      choices:
                          gameState.currentInterruption?.getChoices() ?? [],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(
      BuildContext context, Offset tapPosition, Size size, int sections) {
    if (sections == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate the angle of the tap relative to the center
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    double angle = (atan2(dy, dx) * 180 / pi + 360) % 360;

    // Check if tap is within the circle
    final distance = sqrt(dx * dx + dy * dy);
    if (distance > radius) return;

    // Determine which section was tapped based on the angle
    int section;
    switch (sections) {
      case 1:
        section = 0;
        break;
      case 2:
        section = angle < 180 ? 0 : 1;
        break;
      case 3:
        section = (angle / 120).floor();
        break;
      case 4:
        section = (angle / 90).floor();
        break;
      default:
        return;
    }

    context.read<GameProvider>().handleInterruptionChoice(section);
  }
}

class CircularSectionsPainter extends CustomPainter {
  final int sections;
  final List<String> choices;

  CircularSectionsPainter({
    required this.sections,
    required this.choices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle paint
    final backgroundPaint = Paint()
      ..color = FlavaTheme.primaryColor
      ..style = PaintingStyle.fill;

    // Section divider paint
    final dividerPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw main circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw sections
    if (sections == 1) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.text = TextSpan(
        text: choices[0],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout(maxWidth: radius * 1.5);

      final textX = center.dx - textPainter.width / 2;
      final textY = center.dy - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));
      return;
    } else if (sections > 1) {
      final sectionAngle = 360 / sections;
      for (int i = 0; i < sections; i++) {
        final startAngle = i * sectionAngle * pi / 180;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(startAngle);
        canvas.drawLine(
          Offset(0, 0),
          Offset(radius, 0),
          dividerPaint,
        );
        canvas.restore();
      }
    }

    // Draw text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < sections; i++) {
      if (i >= choices.length) break;

      final sectionAngle = 360 / sections;
      final angle = (i * sectionAngle + sectionAngle / 2) * pi / 180;

      textPainter.text = TextSpan(
        text: choices[i],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      );

      textPainter.layout(maxWidth: radius);

      final textX =
          center.dx + cos(angle) * radius * 0.6 - textPainter.width / 2;
      final textY =
          center.dy + sin(angle) * radius * 0.6 - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(CircularSectionsPainter oldDelegate) {
    return oldDelegate.sections != sections || oldDelegate.choices != choices;
  }
}
