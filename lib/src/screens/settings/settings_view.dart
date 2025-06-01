import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settingsControler});

  static const routeName = '/settings';

  final SettingsController settingsControler;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glue the SettingsController to the theme selection DropdownButton.
              //
              // When a user selects a theme from the dropdown list, the
              // SettingsController is updated, which rebuilds the MaterialApp.
              DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: settingsControler.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: settingsControler.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Theme'),
                  )
                ],
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Clear the stored tokens
                    AuthService.logout();
            
                    // Navigate to the welcome screen
                    Navigator.of(context).pushReplacementNamed('/welcome');
                  },
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
