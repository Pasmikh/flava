import 'dart:math' as math;

import '../models/events/get_events.dart';
import '../models/events/drop_events.dart';
import '../models/game_state.dart';
import '../models/game_event.dart';

class EventManager {
  static Map<EventType, double> calculateEventProbabilities(GameState state) {
    final base = {
      EventType.get: state.gameMode.getEventProbability,
      EventType.drop: state.gameMode.dropEventProbability,
      EventType.other: state.gameMode.otherEventProbability,
      EventType.midgame: state.gameMode.midgameEventProbability,
      EventType.strategic: state.gameMode.strategicEventProbability,
    };

    // Adjust probabilities based on event frequency
    final totalEvents = state.currentPlayer.eventCounts.values
        .fold(0, (sum, count) => sum + count);
    final adjustments = state.currentPlayer.eventCounts.map((type, count) {
      final ratio = totalEvents > 0 ? count / totalEvents : 0.0;
      return MapEntry(type, math.max(0.0, 0.005 * (0.2 - ratio)));
    });

    // Apply round restrictions
    final adjusted = Map<EventType, double>.from(base);
    adjusted.forEach((type, probability) {
      if ((type == EventType.drop && state.currentRound < 3) ||
          (type == EventType.other && state.currentRound < 5) ||
          ((type == EventType.midgame || type == EventType.strategic) &&
              state.currentRound < 6)) {
        adjusted[type] = 0.0;
      } else {
        adjusted[type] = probability + (adjustments[type] ?? 0.0);
      }
    });

    return adjusted;
  }

  static EventType? rollEventType(GameState state) {
    // Calculate event probabilities based on game mode and player state
    final Map<EventType, double> eventProbabilities =
        calculateEventProbabilities(state);

    // Check each event type in priority order
    for (var type in EventType.values) {
      if (_shouldTriggerEventType(
          type, state.currentRound, eventProbabilities)) {
        state.currentPlayer.eventCounts[type] =
            (state.currentPlayer.eventCounts[type] ?? 0) + 1;
        return type;
      }
    }
    return null;
  }

  static GameEvent? rollEvent(GameState state) {
    // For testing purposes, we can force an event type
    if (state.currentRound == 3) {
      // return createGetThreeEvent(state);
      return createGetKeyObjectEvent(state);
    }
    // else if (state.currentRound == 4) {
    //   return createGetKeyObjectEvent(state);
    // }

    // First determine if we should trigger an event
    final EventType? eventType = rollEventType(state);
    if (eventType == null) return null;

    // Create the event based on the rolled type
    return createEvent(eventType, state);
  }

  static GameEvent createEvent(EventType type, GameState state) {
    final List<GameEvent Function(GameState)> availableEvents =
        _getEventsForType(type);

    if (availableEvents.isEmpty) {
      throw StateError('No events available for type $type');
    }

    final eventIndex = math.Random().nextInt(availableEvents.length);
    return availableEvents[eventIndex](state);
  }

  static List<GameEvent Function(GameState)> _getEventsForType(EventType type) {
    switch (type) {
      case EventType.get:
        return getEvents;
      case EventType.drop:
        return dropEvents;
      // Add other event type lists here
      default:
        return [];
    }
  }

  static bool _shouldTriggerEventType(
      EventType type, int currentRound, Map<EventType, double> probabilities) {
    if (!_isEventTypeAllowedInRound(type, currentRound)) {
      return false;
    }
    final double probability = probabilities[type] ?? 0.0;
    return math.Random().nextDouble() < probability;
  }

  static bool _isEventTypeAllowedInRound(EventType type, int currentRound) {
    switch (type) {
      case EventType.get:
        return true;
      case EventType.drop:
        return currentRound >= 3;
      case EventType.other:
        return currentRound >= 5;
      case EventType.midgame:
        return currentRound >= 6;
      case EventType.strategic:
        return currentRound >= 6;
      default:
        return false;
    }
  }
}
