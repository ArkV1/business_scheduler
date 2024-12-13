import 'dart:developer' as dev;

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

enum LogCategory {
  firebase,
  network,
  navigation,
  state,
  performance,
  other,
}

class Logger {
  static bool _enabled = true;
  static Set<LogCategory> _enabledCategories = LogCategory.values.toSet();
  static LogLevel _minLevel = LogLevel.debug;

  // Configuration methods
  static void enable() => _enabled = true;
  static void disable() => _enabled = false;
  static void setMinLevel(LogLevel level) => _minLevel = level;
  
  static void enableCategory(LogCategory category) {
    _enabledCategories.add(category);
  }
  
  static void disableCategory(LogCategory category) {
    _enabledCategories.remove(category);
  }

  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.other,
    String? operation,
    Map<String, dynamic>? data,
    bool forceLog = false,
  }) {
    if (!_shouldLog(level, category) && !forceLog) return;

    final timestamp = DateTime.now();
    final emoji = _getCategoryEmoji(category);
    final prefix = operation != null ? '[$operation]' : '';
    
    final formattedMessage = [
      '$emoji ${level.name.toUpperCase()} $prefix',
      message,
      if (data != null) 'Data: $data',
    ].join(' | ');

    dev.log(
      formattedMessage,
      time: timestamp,
      name: category.name,
      level: _getLogLevel(level),
    );
  }

  // Firebase specific logging methods
  static void firebase(
    String operation,
    String collection, {
    String? docId,
    Map<String, dynamic>? data,
    LogLevel level = LogLevel.info,
    bool forceLog = false,
  }) {
    final details = {
      'collection': collection,
      if (docId != null) 'docId': docId,
      if (data != null) ...data,
    };

    log(
      collection,
      category: LogCategory.firebase,
      operation: operation,
      data: details,
      level: level,
      forceLog: forceLog,
    );
  }

  // Helper methods
  static bool _shouldLog(LogLevel level, LogCategory category) {
    return _enabled && 
           _enabledCategories.contains(category) && 
           level.index >= _minLevel.index;
  }

  static String _getCategoryEmoji(LogCategory category) {
    switch (category) {
      case LogCategory.firebase:
        return '🔥';
      case LogCategory.network:
        return '🌐';
      case LogCategory.navigation:
        return '🧭';
      case LogCategory.state:
        return '⚡';
      case LogCategory.performance:
        return '⚡';
      case LogCategory.other:
        return '📝';
    }
  }

  static int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
} 