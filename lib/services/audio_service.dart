import 'package:audioplayers/audioplayers.dart';

import 'logging_service.dart';

class AudioService {
  static AudioService? _instance;
  late final AudioPlayer _heartbeatSlowPlayer;
  late final AudioPlayer _heartbeatNormalPlayer;
  late final AudioPlayer _heartbeatFastPlayer;
  late final AudioPlayer _endTurnPlayer;
  late final AudioPlayer _eliminatePlayer;
  late final AudioPlayer _winPlayer;
  bool _isInitialized = false;

  final LoggingService _loggingService = LoggingService();

  // Track last played times to prevent sound overlap
  DateTime? _lastHeartbeatTime;
  bool _isSoundPlaying = false;

  // Constants for timing control
  static const Duration _minHeartbeatInterval = Duration(milliseconds: 100);
  static const double _fastHeartbeatThreshold = 2.0;
  static const double _normalHeartbeatThreshold = 4.0;

  // Private constructor
  AudioService._();

  static AudioService getInstance() {
    _instance ??= AudioService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Create players for each sound effect
    _heartbeatSlowPlayer = AudioPlayer();
    _heartbeatNormalPlayer = AudioPlayer();
    _heartbeatFastPlayer = AudioPlayer();
    _endTurnPlayer = AudioPlayer();
    _eliminatePlayer = AudioPlayer();
    _winPlayer = AudioPlayer();

    // Configure all players
    for (final player in [
      _heartbeatSlowPlayer,
      _heartbeatNormalPlayer,
      _heartbeatFastPlayer,
      _endTurnPlayer,
      _eliminatePlayer,
      _winPlayer,
    ]) {
      await player.setReleaseMode(ReleaseMode.stop);
    }

    // Load sound assets
    await Future.wait([
      _heartbeatSlowPlayer
              .setSource(AssetSource('sounds/heartbeat_slow.wav')),
      _heartbeatNormalPlayer
              .setSource(AssetSource('sounds/heartbeat_normal.wav')),
      _heartbeatFastPlayer
              .setSource(AssetSource('sounds/heartbeat_fast.wav')),
      _endTurnPlayer.setSource(AssetSource('sounds/end_turn.wav')),
      _eliminatePlayer.setSource(AssetSource('sounds/eliminate.wav')),
      _winPlayer.setSource(AssetSource('sounds/win.wav')),
    ]);

    // Set up completion listeners
    for (final player in [
      _heartbeatSlowPlayer,
      _heartbeatNormalPlayer,
      _heartbeatFastPlayer,
      _endTurnPlayer,
      _eliminatePlayer,
      _winPlayer,
    ]) {
      player.onPlayerComplete.listen((_) {
        _isSoundPlaying = false;
      });
    }

    _isInitialized = true;
  }

  Future<void> playHeartbeat(double timeLeft) async {
    if (!_isInitialized) return;
    // Check if enough time has passed since last heartbeat
    final now = DateTime.now();
    if (_lastHeartbeatTime != null &&
        now.difference(_lastHeartbeatTime!) < _minHeartbeatInterval) {
      return;
    }

    // Don't play if another sound is currently playing
    if (_isSoundPlaying) return;

    // Determine which heartbeat to play based on time left
    AudioPlayer? playerToUse;

    if (timeLeft <= _fastHeartbeatThreshold) {
      // Fast heartbeat for last 2 seconds
      playerToUse = _heartbeatFastPlayer;
    } else if (timeLeft <= _normalHeartbeatThreshold) {
      // Normal heartbeat for 2-4 seconds remaining
      playerToUse = _heartbeatNormalPlayer;
    } else {
      playerToUse = _heartbeatSlowPlayer;
    }

    _loggingService.log(
      'Playing heartbeat with threshold $timeLeft',
      data: {
        'threshold': timeLeft,
        'player': playerName(playerToUse),
      },
    );

    // playerToUse cannot be null here
    _isSoundPlaying = true;
    _lastHeartbeatTime = now;
    await stopHeartbeats(); // Stop any playing heartbeat
    await playerToUse.resume();
  }

  Future<void> playEndTurn() async {
    if (!_isInitialized) return;
    await stopAll();
    _isSoundPlaying = true;
    await _endTurnPlayer.resume();
  }

  Future<void> playEliminate() async {
    if (!_isInitialized) return;
    await stopAll();
    _isSoundPlaying = true;
    await _eliminatePlayer.resume();
  }

  Future<void> playWin() async {
    if (!_isInitialized) return;
    await stopAll();
    _isSoundPlaying = true;
    await _winPlayer.resume();
  }

  Future<void> stopHeartbeats() async {
    if (!_isInitialized) return;
    await Future.wait([
      _heartbeatSlowPlayer.stop(),
      _heartbeatNormalPlayer.stop(),
      _heartbeatFastPlayer.stop(),
    ]);
  }

  Future<void> stopAll() async {
    if (!_isInitialized) return;
    await Future.wait([
      _heartbeatSlowPlayer.stop(),
      _heartbeatNormalPlayer.stop(),
      _heartbeatFastPlayer.stop(),
      _endTurnPlayer.stop(),
      _eliminatePlayer.stop(),
      _winPlayer.stop(),
    ]);
    _isSoundPlaying = false;
  }

  String playerName(AudioPlayer player) {
    if (!_isInitialized) return 'Not initialized';
    if (identical(player, _heartbeatSlowPlayer)) return 'Heartbeat slow';
    if (identical(player, _heartbeatNormalPlayer)) return 'Heartbeat normal';
    if (identical(player, _heartbeatFastPlayer)) return 'Heartbeat fast';
    if (identical(player, _endTurnPlayer)) return 'End turn';
    if (identical(player, _eliminatePlayer)) return 'Eliminate';
    if (identical(player, _winPlayer)) return 'Win';
    return 'Unknown';
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;
    await stopAll();
    await Future.wait([
      _heartbeatSlowPlayer.dispose(),
      _heartbeatNormalPlayer.dispose(),
      _heartbeatFastPlayer.dispose(),
      _endTurnPlayer.dispose(),
      _eliminatePlayer.dispose(),
      _winPlayer.dispose(),
    ]);
  }
}
