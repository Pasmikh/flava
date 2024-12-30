import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _confirmEventsKey = 'confirm_events';
  static const String _fullscreenEnabledKey = 'fullscreen_enabled';
  static const String _doNotDisturbKey = 'do_not_disturb';
  static const String _lastGameModeKey = 'last_game_mode';
  static const String _vibrateOnEventsKey = 'vibrate_on_events';
  
  late SharedPreferences _prefs;
  
  // Settings state
  bool _soundEnabled = true;
  bool _confirmEvents = false;
  bool _fullscreenEnabled = false;
  bool _doNotDisturb = false;
  String _lastGameMode = 'fun';
  bool _vibrateOnEvents = true;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get confirmEvents => _confirmEvents;
  bool get fullscreenEnabled => _fullscreenEnabled;
  bool get doNotDisturb => _doNotDisturb;
  String get lastGameMode => _lastGameMode;
  bool get vibrateOnEvents => _vibrateOnEvents;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _confirmEvents = _prefs.getBool(_confirmEventsKey) ?? false;
    _fullscreenEnabled = _prefs.getBool(_fullscreenEnabledKey) ?? false;
    _doNotDisturb = _prefs.getBool(_doNotDisturbKey) ?? false;
    _lastGameMode = _prefs.getString(_lastGameModeKey) ?? 'fun';
    _vibrateOnEvents = _prefs.getBool(_vibrateOnEventsKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _prefs.setBool(_soundEnabledKey, _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleEventConfirmation() async {
    _confirmEvents = !_confirmEvents;
    await _prefs.setBool(_confirmEventsKey, _confirmEvents);
    notifyListeners();
  }

  Future<void> toggleFullscreen() async {
    _fullscreenEnabled = !_fullscreenEnabled;
    await _prefs.setBool(_fullscreenEnabledKey, _fullscreenEnabled);
    notifyListeners();
  }

  Future<void> toggleDoNotDisturb() async {
    _doNotDisturb = !_doNotDisturb;
    await _prefs.setBool(_doNotDisturbKey, _doNotDisturb);
    notifyListeners();
  }

  Future<void> setLastGameMode(String mode) async {
    _lastGameMode = mode;
    await _prefs.setString(_lastGameModeKey, mode);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrateOnEvents = !_vibrateOnEvents;
    await _prefs.setBool(_vibrateOnEventsKey, _vibrateOnEvents);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _soundEnabled = true;
    _confirmEvents = false;
    _fullscreenEnabled = false;
    _doNotDisturb = false;
    _lastGameMode = 'fun';
    _vibrateOnEvents = true;

    await Future.wait([
      _prefs.setBool(_soundEnabledKey, true),
      _prefs.setBool(_confirmEventsKey, false),
      _prefs.setBool(_fullscreenEnabledKey, false),
      _prefs.setBool(_doNotDisturbKey, false),
      _prefs.setString(_lastGameModeKey, 'fun'),
      _prefs.setBool(_vibrateOnEventsKey, true),
    ]);

    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': _soundEnabled,
      'confirmEvents': _confirmEvents,
      'fullscreenEnabled': _fullscreenEnabled,
      'doNotDisturb': _doNotDisturb,
      'lastGameMode': _lastGameMode,
      'vibrateOnEvents': _vibrateOnEvents,
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    _soundEnabled = settings['soundEnabled'] ?? true;
    _confirmEvents = settings['confirmEvents'] ?? false;
    _fullscreenEnabled = settings['fullscreenEnabled'] ?? false;
    _doNotDisturb = settings['doNotDisturb'] ?? false;
    _lastGameMode = settings['lastGameMode'] ?? 'fun';
    _vibrateOnEvents = settings['vibrateOnEvents'] ?? true;

    await Future.wait([
      _prefs.setBool(_soundEnabledKey, _soundEnabled),
      _prefs.setBool(_confirmEventsKey, _confirmEvents),
      _prefs.setBool(_fullscreenEnabledKey, _fullscreenEnabled),
      _prefs.setBool(_doNotDisturbKey, _doNotDisturb),
      _prefs.setString(_lastGameModeKey, _lastGameMode),
      _prefs.setBool(_vibrateOnEventsKey, _vibrateOnEvents),
    ]);

    notifyListeners();
  }
}