import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/game_state.dart';
import '../../../config/theme.dart';

class GameTimer extends StatelessWidget {
  const GameTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return CustomPaint(
          size: Size.fromRadius(MediaQuery.of(context).size.height * 0.2),
          painter: TimerPainter(
            progress: gameState.turnProgress,
            backgroundColor: FlavaTheme.primaryColor.withAlpha(100),
            progressColor: FlavaTheme.primaryColor,
          ),
        );
      },
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  
  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.05;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress, // Progress angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor;
  }
}