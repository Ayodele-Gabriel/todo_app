import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static SharedPreferences? _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_instance == null) {
      throw Exception('Preferences Service not initialized. Call init() first.');
    }
    return _instance!;
  }

  static Future<bool> setString(String key, String value) {
    return instance.setString(key, value);
  }

  static String? getString(String key) {
    return instance.getString(key);
  }

  static Future<bool> setBool(String key, bool value) {
    return instance.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return instance.getBool(key) ?? defaultValue;
  }

  static Future<bool> setInt(String key, int value) {
    return instance.setInt(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return instance.getInt(key) ?? defaultValue;
  }

  static Future<bool> setObject<T>(String key, T object) {
    final jsonString = json.encode(object);
    return setString(key, jsonString);
  }

  static T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      print('Error parsing stored object: $e');
      return null;
    }
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return instance.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return instance.getStringList(key) ?? [];
  }

  static Future<bool> remove(String key) {
    return instance.remove(key);
  }

  static Future<bool> clear() {
    return instance.clear();
  }

  static bool containsKey(String key) {
    return instance.containsKey(key);
  }
}
