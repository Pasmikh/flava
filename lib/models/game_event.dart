import 'package:flava/models/game_state.dart';

enum EventType {
  take,
  drop,
  other,
  strategic,
  win,
}

const maxChoices = 4;

class GameEvent {
  final String description;
  final EventType type;
  final double additionalTime;
  final bool requiresConfirmation;
  final bool resetsEventChance;
  final bool isMidgame;
  final EventChoices choices;
  final GameState Function(GameState, int?) executeEvent;

  const GameEvent({
    required this.description,
    required this.type,
    required this.executeEvent,
    required this.choices,
    this.additionalTime = 0,
    this.requiresConfirmation = false,
    this.resetsEventChance = true,
    this.isMidgame = false,
  });

  // Returns new state after executing the event
  GameState execute(GameState state, int? choiceIndex) {
    return executeEvent(state, choiceIndex);
  }

  List<String> getChoices() => choices.displayNames;
}

class EventChoices<T> {
  final List<String> displayNames;
  final List<T> items;

  EventChoices(List<T> allItems, String Function(T) getName)
      : items = allItems.length <= maxChoices
            ? allItems
            : _selectRandomItems(allItems, maxChoices),
        displayNames = allItems.length <= maxChoices
            ? allItems.map(getName).toList()
            : _selectRandomItems(allItems, maxChoices).map(getName).toList();

  static List<T> _selectRandomItems<T>(List<T> items, int count) {
    if (items.isEmpty) return [];

    final shuffled = List<T>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  T getItem(int index) => items[index];

  int get length => items.length;
}
