import 'package:audioplayers/audioplayers.dart';

import 'logging_service.dart';

class AudioService {
  static AudioService? _instance;
  final AudioPlayer _heartbeatSlowPlayer;
  final AudioPlayer _heartbeatNormalPlayer;
  final AudioPlayer _heartbeatFastPlayer;
  final AudioPlayer _endTurnPlayer;
  final AudioPlayer _eliminatePlayer;
  final AudioPlayer _winPlayer;

  final LoggingService _loggingService = LoggingService();

  // Track last played times to prevent sound overlap
  DateTime? _lastHeartbeatTime;
  bool _isSoundPlaying = false;

  // Constants for timing control
  static const Duration _minHeartbeatInterval = Duration(milliseconds: 100);
  static const double _fastHeartbeatThreshold = 2.0;
  static const double _normalHeartbeatThreshold = 4.0;
  // Private constructor
  AudioService._({
    required AudioPlayer heartbeatSlowPlayer,
    required AudioPlayer heartbeatNormalPlayer,
    required AudioPlayer heartbeatFastPlayer,
    required AudioPlayer endTurnPlayer,
    required AudioPlayer eliminatePlayer,
    required AudioPlayer winPlayer,
  })  : _heartbeatSlowPlayer = heartbeatSlowPlayer,
        _heartbeatNormalPlayer = heartbeatNormalPlayer,
        _heartbeatFastPlayer = heartbeatFastPlayer,
        _endTurnPlayer = endTurnPlayer,
        _eliminatePlayer = eliminatePlayer,
        _winPlayer = winPlayer {
    // Set up completion listeners for all players
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
  }

  static Future<AudioService> initialize() async {
    if (_instance != null) return _instance!;

    // Create players for each sound effect
    final heartbeatSlowPlayer = AudioPlayer();
    final heartbeatNormalPlayer = AudioPlayer();
    final heartbeatFastPlayer = AudioPlayer();
    final endTurnPlayer = AudioPlayer();
    final eliminatePlayer = AudioPlayer();
    final winPlayer = AudioPlayer();

    // Configure all players
    for (final player in [
      heartbeatSlowPlayer,
      heartbeatNormalPlayer,
      heartbeatFastPlayer,
      endTurnPlayer,
      eliminatePlayer,
      winPlayer,
    ]) {
      await player.setReleaseMode(ReleaseMode.stop);
    }

    // Load sound assets
    await Future.wait([
      heartbeatSlowPlayer.setSource(AssetSource('sounds/heartbeat_slow.wav')),
      heartbeatNormalPlayer
          .setSource(AssetSource('sounds/heartbeat_normal.wav')),
      heartbeatFastPlayer.setSource(AssetSource('sounds/heartbeat_fast.wav')),
      endTurnPlayer.setSource(AssetSource('sounds/end_turn.wav')),
      eliminatePlayer.setSource(AssetSource('sounds/eliminate.wav')),
      winPlayer.setSource(AssetSource('sounds/win.wav')),
    ]);

    _instance = AudioService._(
      heartbeatSlowPlayer: heartbeatSlowPlayer,
      heartbeatNormalPlayer: heartbeatNormalPlayer,
      heartbeatFastPlayer: heartbeatFastPlayer,
      endTurnPlayer: endTurnPlayer,
      eliminatePlayer: eliminatePlayer,
      winPlayer: winPlayer,
    );

    return _instance!;
  }

  Future<void> playHeartbeat(double timeLeft) async {
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
    await stopAll();
    _isSoundPlaying = true;
    await _endTurnPlayer.resume();
  }

  Future<void> playEliminate() async {
    await stopAll();
    _isSoundPlaying = true;
    await _eliminatePlayer.resume();
  }

  Future<void> playWin() async {
    await stopAll();
    _isSoundPlaying = true;
    await _winPlayer.resume();
  }

  Future<void> stopHeartbeats() async {
    await Future.wait([
      _heartbeatSlowPlayer.stop(),
      _heartbeatNormalPlayer.stop(),
      _heartbeatFastPlayer.stop(),
    ]);
  }

  Future<void> stopAll() async {
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
    if (identical(player, _heartbeatSlowPlayer)) return 'Heartbeat slow';
    if (identical(player, _heartbeatNormalPlayer)) return 'Heartbeat normal';
    if (identical(player, _heartbeatFastPlayer)) return 'Heartbeat fast';
    if (identical(player, _endTurnPlayer)) return 'End turn';
    if (identical(player, _eliminatePlayer)) return 'Eliminate';
    if (identical(player, _winPlayer)) return 'Win';
    return 'Unknown';
  }

  Future<void> dispose() async {
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
