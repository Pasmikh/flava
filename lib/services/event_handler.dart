import 'dart:math' as math;

import '../config/constants.dart';
import '../models/events/take_events.dart';
import '../models/events/drop_events.dart';
import '../models/events/other_events.dart';
import '../models/events/win_events.dart';
import '../models/game_state.dart';
import '../models/game_event.dart';

class EventManager {
  static GameEvent? createEvent(GameState state) {
    // For testing purposes, we can force an event type
    // if (state.currentRound == 3) {
    //   switch (state.currentPlayerIndex) {
    //     case 0: return createSwitchHandsEvent(state);
    //     case 1: return createGiveOneLeftEvent(state);
    //     case 2: return createGiveOneAnyEvent(state);
    //     case 3: return createStealKeyEvent(state);
    //     default: return null;
    //   }
    // } else if (state.currentRound == 4) {
    //   switch (state.currentPlayerIndex) {
    //     case 0: return createExchangeHandsRedEvent(state);
    //     case 1: return createExchangeHandsGreenEvent(state);
    //     // case 2: return createSwitchHandsEvent(state);
    //     // case 3: return createGiveOneRightEvent(state);
    //     default: return null;
    //   }
    // }

    // First determine if we should trigger an event
    final EventType? eventType = rollEventType(state);
    if (eventType == null) return null;

    // Create the event based on the rolled type
    return rollEvent(eventType, state);
  }

  static EventType? rollEventType(GameState state) {
    // Calculate event probabilities based on game mode and player state
    final Map<EventType, double> probabilities =
        state.currentPlayer.storedEventProbabilities;

    // Check each event type in priority order
    for (var type in EventType.values) {
      if (_isEventTypeAllowedInRound(type, state.currentRound) &&
          _shouldTriggerEventType(type, state.currentRound, probabilities)) {
        return type;
      }
    }
    return null;
  }

  static GameEvent rollEvent(EventType type, GameState state) {
    final List<GameEvent Function(GameState)> typeEvents =
        _getEventsForType(type);

    if (typeEvents.isEmpty) {
      throw StateError('No events available for type $type');
    }

    // Filter based on midgame flag
    final List<GameEvent> availableEvents = typeEvents
        .map((creator) => creator(state))
        .where((event) =>
            !event.isMidgame ||
            state.currentRound >= AppConstants.midgameEventStartRound)
        .toList();

    final eventIndex = math.Random().nextInt(availableEvents.length);
    return availableEvents[eventIndex];
  }

  static GameEvent createWinEvent(GameState state) {
    final List<GameEvent Function(GameState)> typeEvents = winEvents;

    if (typeEvents.isEmpty) {
      throw StateError('No events available for type win');
    }

    // createWinDropKeysEvent if round >= 16
    // createWinSwitchHandsEvent if round >= 10
    // Limit events to those that are allowed in the current round
    final List<GameEvent Function(GameState)> availableEvents = [
      createWinGiveTwoEvent
    ];
    if (state.currentRound >= AppConstants.winDropKeysEventStartRound) {
      availableEvents.add(createWinDropKeysEvent);
    }
    if (state.currentRound >= AppConstants.winSwitchHandsEventStartRound) {
      availableEvents.add(createWinSwitchHandsEvent);
    }

    final eventIndex = math.Random().nextInt(availableEvents.length);
    return availableEvents[eventIndex](state);
  }

  static List<GameEvent Function(GameState)> _getEventsForType(EventType type) {
    switch (type) {
      case EventType.take:
        return takeEvents;
      case EventType.drop:
        return dropEvents;
      case EventType.other:
        return otherEvents;
      // case EventType.strategic:
      //   return strategic;
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
      case EventType.take:
        return true;
      case EventType.drop:
        return currentRound >= AppConstants.dropEventStartRound;
      case EventType.other:
        return currentRound >= AppConstants.otherEventStartRound;
      case EventType.strategic:
        return currentRound >= AppConstants.strategicEventStartRound;
      default:
        return false;
    }
  }
}
