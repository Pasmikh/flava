import 'game_event.dart';

abstract class GameInterruption {
  String get description;
  List<String> getChoices();
  bool get requiresConfirmation;
  double get additionalTime;
}

class EventInterruption extends GameInterruption {
  final GameEvent event;

  EventInterruption(this.event);

  @override
  String get description => event.description;

  @override
  List<String> getChoices() => event.getChoices();

  @override
  bool get requiresConfirmation => event.requiresConfirmation;

  @override
  double get additionalTime => event.additionalTime;
}

// lib/models/interruptions/win_test_interruption.dart
enum WinTestPhase { confirmation, test, result }

class WinTestInterruption extends GameInterruption {
  final WinTestPhase phase;
  final GameEvent? winEvent;

  WinTestInterruption(
    this.winEvent,
    {this.phase = WinTestPhase.confirmation});

  @override
  String get description => 
    phase == WinTestPhase.result ? 'How did it go?' : winEvent?.description ?? '';

  @override
  List<String> getChoices() =>
      phase == WinTestPhase.confirmation ? ["Confirm"] : ["Success", "Failure"];

  @override
  bool get requiresConfirmation => phase == WinTestPhase.confirmation;

  @override
  double get additionalTime => phase == WinTestPhase.test ? winEvent?.additionalTime ?? 0.0 : 0.0;
}

class RoundEndInterruption extends GameInterruption {
  @override
  String get description => "Ready for next round?";

  @override
  List<String> getChoices() => ["Confirm"];

  @override
  bool get requiresConfirmation => true;

  @override
  double get additionalTime => 0.0;
}
