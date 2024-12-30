import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioService? _instance;
  final AudioPlayer _heartbeatSlowPlayer;
  final AudioPlayer _heartbeatNormalPlayer;
  final AudioPlayer _heartbeatFastPlayer;
  final AudioPlayer _endTurnPlayer;
  final AudioPlayer _eliminatePlayer;
  final AudioPlayer _winPlayer;

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
        _winPlayer = winPlayer;

  static Future<AudioService> initialize() async {
    if (_instance != null) return _instance!;

    // Create players for each sound effect
    final heartbeatSlowPlayer = AudioPlayer();
    final heartbeatNormalPlayer = AudioPlayer();
    final heartbeatFastPlayer = AudioPlayer();
    final endTurnPlayer = AudioPlayer();
    final eliminatePlayer = AudioPlayer();
    final winPlayer = AudioPlayer();

    // Load sound assets
    await Future.wait([
      heartbeatSlowPlayer.setSource(AssetSource('sounds/heartbeat_slow.wav')),
      heartbeatNormalPlayer.setSource(AssetSource('sounds/heartbeat_normal.wav')),
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
    if (timeLeft <= 2) {
      await _heartbeatFastPlayer.resume();
    } else if (timeLeft <= 4) {
      await _heartbeatNormalPlayer.resume();
    } else if (timeLeft % 1 == 0) {  // Play on whole seconds
      await _heartbeatSlowPlayer.resume();
    }
  }

  Future<void> playEndTurn() async {
    await _endTurnPlayer.resume();
  }

  Future<void> playEliminate() async {
    await _eliminatePlayer.resume();
  }

  Future<void> playWin() async {
    await _winPlayer.resume();
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
  }

  Future<void> dispose() async {
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