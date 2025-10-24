import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings.dart';

class PreferencesSwitch extends StatelessWidget {
  const PreferencesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsPreferences>(
      builder: (context, settings, _) => SwitchListTile(
        title: const Text('Usar Firebase'),
        subtitle: const Text('Alterna entre dados locais ou Firebase'),
        value: settings.useFirebase,
        onChanged: settings.setUseFirebase,
      ),
    );
  }
}
