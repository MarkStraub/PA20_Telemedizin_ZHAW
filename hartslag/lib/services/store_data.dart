import 'package:shared_preferences/shared_preferences.dart';

// https://pub.dev/packages/shared_preferences
class StoreData {
  /// Try saving data to the key
  static Future<bool> save(String key, String value) async {
    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Set value
    return await prefs.setString(key, value);
  }

  /// Try updating data to the key
  static Future<bool> update(String key, String value) async {
    return await StoreData.save(key, value);
  }

  /// Try reading data from the key
  static Future<String> read(String key) async {
    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Read value
    return prefs.getString(key);
  }

  /// Try removing data from the key
  static Future<bool> delete(String key) async {
    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Delete value
    return await prefs.remove(key);
  }
}
