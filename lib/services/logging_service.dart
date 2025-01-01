enum LogLevel { debug, info, warning, error }

class GameLog {
  final DateTime timestamp;
  final String event;
  final Map<String, dynamic> data;
  final LogLevel level;

  GameLog({
    required this.event,
    required this.data,
    this.level = LogLevel.info,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'event': event,
        'data': data,
        'level': level.toString(),
      };
}

class LoggingService {
  final List<GameLog> _logs = [];

  void log(
    String event, {
    Map<String, dynamic> data = const {},
    LogLevel level = LogLevel.info,
  }) {
    final log = GameLog(
      event: event,
      data: data,
      level: level,
    );
    _logs.add(log);
    _printLog(log);
  }

  void _printLog(GameLog log) {
    print('${log.timestamp} [${log.level}] ${log.event}: ${log.data}');
  }

  List<GameLog> getLogs() => List.unmodifiable(_logs);

  Future<void> exportLogs() async {
    // Implement export functionality if needed
    final jsonLogs = _logs.map((log) => log.toJson()).toList();
    // You can save to file or send to a server
  }

  void clear() {
    _logs.clear();
  }
}
