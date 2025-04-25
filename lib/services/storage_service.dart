import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _prefix = 'orbirq_';
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Future<bool> setValue<T>(String key, T value) async {
    key = _prefix + key;

    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      return await _prefs.setString(key, jsonEncode(value));
    }
  }

  T? getValue<T>(String key) {
    key = _prefix + key;

    if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == List<String>) {
      return _prefs.getStringList(key) as T?;
    } else {
      final value = _prefs.getString(key);
      if (value != null) {
        return jsonDecode(value) as T?;
      }
    }
    return null;
  }

  Future<bool> removeValue(String key) async {
    key = _prefix + key;
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  bool hasKey(String key) {
    key = _prefix + key;
    return _prefs.containsKey(key);
  }

  Set<String> getAllKeys() {
    return _prefs.getKeys().where((key) => key.startsWith(_prefix)).toSet();
  }
}
