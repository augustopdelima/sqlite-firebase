import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyUseFirebase = 'useFirebase';

  static Future<void> setUseFirebase(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseFirebase, value);
  }

  static Future<bool> getUseFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseFirebase) ?? false;
  }
}
