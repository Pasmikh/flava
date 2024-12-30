import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userIdKey = 'user_id';
  static const String _gameStatsDirectory = 'stats';
  static const String _gameResultsFile = 'game_results.txt';
  static const String _eventsFile = 'events.txt';
  
  late SharedPreferences _prefs;
  late Directory _appDirectory;
  
  static StorageService? _instance;
  
  StorageService._();
  
  static Future<StorageService> initialize() async {
    if (_instance != null) return _instance!;
    
    final instance = StorageService._();
    await instance._init();
    _instance = instance;
    return _instance!;
  }
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _appDirectory = await getApplicationDocumentsDirectory();
    
    // Create stats directory if it doesn't exist
    final statsDir = Directory('${_appDirectory.path}/$_gameStatsDirectory');
    if (!await statsDir.exists()) {
      await statsDir.create(recursive: true);
    }
    
    // Initialize user ID if not exists
    if (!_prefs.containsKey(_userIdKey)) {
      await _prefs.setInt(_userIdKey, DateTime.now().millisecondsSinceEpoch % 100000000);
    }
  }

  int getUserId() {
    return _prefs.getInt(_userIdKey) ?? 0;
  }

  Future<void> saveGameResults(Map<String, dynamic> results) async {
    final file = File('${_appDirectory.path}/$_gameStatsDirectory/$_gameResultsFile');
    final exists = await file.exists();
    
    // Convert map to CSV format
    final header = results.keys.join(',');
    final values = results.values.map((v) => v.toString()).join(',');
    
    if (!exists) {
      await file.writeAsString('$header\n$values\n');
    } else {
      await file.writeAsString('$values\n', mode: FileMode.append);
    }
  }

  Future<void> logGameEvent({
    required int turnRound,
    required int playerId,
    required String playerName,
    required String event,
    required String extra,
  }) async {
    final file = File('${_appDirectory.path}/$_gameStatsDirectory/$_eventsFile');
    
    final eventData = [
      getUserId(),
      getLastGameId() + 1,
      turnRound,
      playerId,
      playerName,
      event,
      extra,
    ].join(',');
    
    await file.writeAsString('$eventData\n', mode: FileMode.append);
  }

  Future<int> getLastGameId() async {
    final file = File('${_appDirectory.path}/$_gameStatsDirectory/$_gameResultsFile');
    if (!await file.exists()) return 0;
    
    final lines = await file.readAsLines();
    if (lines.length <= 1) return 0;  // Only header or empty
    
    int maxGameId = 0;
    for (var i = 1; i < lines.length; i++) {  // Skip header
      final columns = lines[i].split(',');
      if (columns.length > 1) {
        final gameId = int.tryParse(columns[1]) ?? 0;
        maxGameId = gameId > maxGameId ? gameId : maxGameId;
      }
    }
    
    return maxGameId;
  }

  Future<List<Map<String, dynamic>>> getGameHistory() async {
    final file = File('${_appDirectory.path}/$_gameStatsDirectory/$_gameResultsFile');
    if (!await file.exists()) return [];
    
    final lines = await file.readAsLines();
    if (lines.isEmpty) return [];
    
    final header = lines[0].split(',');
    final results = <Map<String, dynamic>>[];
    
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');
      if (values.length == header.length) {
        final map = <String, dynamic>{};
        for (var j = 0; j < header.length; j++) {
          // Try to parse as number first
          map[header[j]] = num.tryParse(values[j]) ?? values[j];
        }
        results.add(map);
      }
    }
    
    return results;
  }

  Future<void> clearGameHistory() async {
    final resultsFile = File('${_appDirectory.path}/$_gameStatsDirectory/$_gameResultsFile');
    final eventsFile = File('${_appDirectory.path}/$_gameStatsDirectory/$_eventsFile');
    
    if (await resultsFile.exists()) await resultsFile.delete();
    if (await eventsFile.exists()) await eventsFile.delete();
  }
}