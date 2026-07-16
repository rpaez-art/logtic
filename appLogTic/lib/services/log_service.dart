import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

/// Log severity level.
enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, ' INFO'),
  warn(2, ' WARN'),
  error(3, 'ERROR');

  final int priority;
  final String label;
  const LogLevel(this.priority, this.label);

  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warn:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

/// A single structured log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  String get formatted {
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
    return '$time [${level.label}] ${level.emoji} [$tag] $message';
  }

  String get tsvLine =>
      '${timestamp.toIso8601String()}\t${level.label}\t$tag\t$message';

  Map<String, dynamic> toJson() => {
        'ts': timestamp.toIso8601String(),
        'level': level.label.trim(),
        'tag': tag,
        'msg': message,
      };
}

/// Singleton service that collects structured logs in a ring buffer
/// and can export them to a text file for sharing / debugging.
class LogService {
  static final LogService _instance = LogService._();
  static LogService get instance => _instance;
  LogService._();

  static const int _ringSize = 500;

  final List<LogEntry> _logs = [];
  LogLevel _minLevel = LogLevel.debug;

  /// Minimum level to record. Entries below this are discarded.
  LogLevel get minLevel => _minLevel;
  set minLevel(LogLevel level) => _minLevel = level;

  File? _logFile;
  bool _fileLoggingEnabled = false;

  /// Return a copy of all buffered entries.
  List<LogEntry> get entries => List.unmodifiable(_logs);

  // ── Initialization & Permissions ──

  /// Initialize the logger. Only sets up the file if permissions are already granted.
  /// Won't ask for permissions natively to prevent startup crash.
  Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) return;
    
    try {
      final hasManage = await Permission.manageExternalStorage.isGranted;
      final hasStorage = await Permission.storage.isGranted;
      
      if (hasManage || hasStorage) {
        await _setupFile();
      } else {
        debugPrint('LogService: No storage permissions yet. File logging pending.');
      }
    } catch (e) {
      debugPrint('LogService init error: $e');
    }
  }

  /// Request permissions and initialize file logging.
  /// Safe to call after runApp.
  Future<void> requestPermissionsAndInit() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      debugPrint('LogService: Requesting storage permissions...');
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (status.isGranted) {
        await _setupFile();
      } else {
        debugPrint('LogService: Storage permission denied.');
      }
    } catch (e) {
      debugPrint('LogService: Error requesting permissions: $e');
    }
  }

  Future<void> _setupFile() async {
    try {
      final directory = Directory('/storage/emulated/0/Download/logtic_logs');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final date = DateTime.now().toIso8601String().split('T').first;
      _logFile = File('${directory.path}/log_$date.txt');
      _fileLoggingEnabled = true;
      info('SYSTEM', 'LogService file logging enabled in Download/logtic_logs');
    } catch (e) {
      debugPrint('LogService: Failed to setup log file: $e');
    }
  }

  // ── Core logging ──

  void _log(LogLevel level, String tag, String message) {
    if (level.priority < _minLevel.priority) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
    );

    _logs.add(entry);
    if (_logs.length > _ringSize) {
      _logs.removeAt(0);
    }

    // Also emit to Flutter's debug console in debug mode
    debugPrint(entry.formatted);

    // Append to file if enabled
    if (_fileLoggingEnabled && _logFile != null) {
      try {
        _logFile!.writeAsStringSync('${entry.formatted}\n', mode: FileMode.append);
      } catch (e) {
        debugPrint('LogService: Failed to write to log file: $e');
      }
    }
  }

  void debug(String tag, String message) => _log(LogLevel.debug, tag, message);
  void info(String tag, String message) => _log(LogLevel.info, tag, message);
  void warn(String tag, String message) => _log(LogLevel.warn, tag, message);
  void error(String tag, String message) => _log(LogLevel.error, tag, message);

  /// Log an exception with stack trace.
  void exception(String tag, dynamic exception, [StackTrace? stack]) {
    final msg = exception.toString();
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.error,
      tag: tag,
      message: stack != null ? '$msg\n${stack.toString()}' : msg,
    );
    _logs.add(entry);
    if (_logs.length > _ringSize) _logs.removeAt(0);
    
    debugPrint(entry.formatted);

    // Append exception to file if enabled
    if (_fileLoggingEnabled && _logFile != null) {
      try {
        _logFile!.writeAsStringSync('${entry.formatted}\n', mode: FileMode.append);
      } catch (e) {
        debugPrint('LogService: Failed to write exception to log file: $e');
      }
    }
  }

  // ── File export (legacy) ──

  /// Write all logs to a text file and return the file path.
  /// Each line is one log entry in formatted form.
  Future<String> exportToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final filename =
        'logtic_logs_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.txt';
    final file = File('${dir.path}/$filename');

    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln(' LogTic Log Export');
    buffer.writeln(' Generated: ${now.toIso8601String()}');
    buffer.writeln(' Entries: ${_logs.length}');
    buffer.writeln('=' * 60);
    buffer.writeln('');

    for (final entry in _logs) {
      buffer.writeln(entry.formatted);
    }

    await file.writeAsString(buffer.toString());
    debugPrint('📝 Logs exported to: ${file.path}');
    return file.path;
  }

  /// Open the exported log file in a system viewer.
  Future<void> openLogFile() async {
    final path = await exportToFile();
    final result = await OpenFile.open(path);
    if (result.type == ResultType.error) {
      debugPrint('❌ Failed to open log file: ${result.message}');
    }
  }

  /// Clear all buffered logs.
  void clear() {
    _logs.clear();
    debugPrint('🧹 Logs cleared');
  }

  /// Return logs filtered by level.
  List<LogEntry> filterByLevel(LogLevel minLevel) {
    return _logs.where((e) => e.level.priority >= minLevel.priority).toList();
  }
}
