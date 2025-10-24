import 'package:flutter/material.dart';
import 'preferences.dart';

class SettingsPreferences extends ChangeNotifier {
  bool _useFirebase = false;
  bool get useFirebase => _useFirebase;

  SettingsPreferences() {
    _load();
  }

  Future<void> _load() async {
    _useFirebase = await PreferencesService.getUseFirebase();
    notifyListeners();
  }

  Future<void> setUseFirebase(bool value) async {
    await PreferencesService.setUseFirebase(value);
    _useFirebase = value;
    notifyListeners();
  }
}
