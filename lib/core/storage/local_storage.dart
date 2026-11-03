import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Pure Dart & built-in Flutter platform channel local storage.
/// Uses internal app directory via Android filesDir, and falls back to Current Directory / AppData on desktop.
class LocalStorage {
  static const MethodChannel _channel = MethodChannel('com.habitly.app/storage');
  static String? _baseDirPath;

  /// Initializes the base storage directory path
  static Future<String> getBaseDirectoryPath() async {
    if (_baseDirPath != null) return _baseDirPath!;

    if (!kIsWeb && Platform.isAndroid) {
      try {
        final String? path = await _channel.invokeMethod<String>('getFilesDir');
        if (path != null && path.isNotEmpty) {
          _baseDirPath = path;
          return _baseDirPath!;
        }
      } catch (e) {
        debugPrint('Could not retrieve Android filesDir via MethodChannel: $e');
      }
    }

    // Fallback for desktop / development testing or if native channel is unavailable
    final dir = Directory('.habitly_data');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _baseDirPath = dir.path;
    return _baseDirPath!;
  }

  /// Read JSON data from a local file
  static Future<dynamic> readJson(String fileName) async {
    try {
      final baseDir = await getBaseDirectoryPath();
      final file = File('$baseDir/$fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          return jsonDecode(content);
        }
      }
    } catch (e) {
      debugPrint('Error reading $fileName: $e');
    }
    return null;
  }

  /// Write JSON serializable data to a local file
  static Future<bool> writeJson(String fileName, dynamic data) async {
    try {
      final baseDir = await getBaseDirectoryPath();
      final file = File('$baseDir/$fileName');
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString, flush: true);
      return true;
    } catch (e) {
      debugPrint('Error writing to $fileName: $e');
      return false;
    }
  }

  /// Delete a file
  static Future<bool> deleteFile(String fileName) async {
    try {
      final baseDir = await getBaseDirectoryPath();
      final file = File('$baseDir/$fileName');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting $fileName: $e');
    }
    return false;
  }

  /// Clear all data files
  static Future<void> clearAll() async {
    final files = [
      'habitly_habits.json',
      'habitly_completions.json',
      'habitly_profile.json',
      'habitly_settings.json',
    ];
    for (final f in files) {
      await deleteFile(f);
    }
  }

  /// Export all data as a single JSON string
  static Future<String> exportAllData() async {
    final habits = await readJson('habitly_habits.json') ?? [];
    final completions = await readJson('habitly_completions.json') ?? [];
    final profile = await readJson('habitly_profile.json') ?? {};
    final settings = await readJson('habitly_settings.json') ?? {};

    final exportData = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'habits': habits,
      'completions': completions,
      'profile': profile,
      'settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }
}

