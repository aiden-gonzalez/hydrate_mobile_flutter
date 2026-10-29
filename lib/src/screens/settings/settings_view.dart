import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settingsControler});

  static const routeName = '/settings';

  final SettingsController settingsControler;

  void signOut(BuildContext context) {
    // Clear the entire navigation stack and push welcome screen
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/welcome',
      (route) => false, // This predicate removes all previous routes
    );
  }

  Future<void> confirmDeleteAccount(BuildContext context) async {
    String password = "";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete account?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("This permanently deletes your account, ratings and photos. "
                "Places you added stay on the map without your name. This can't be undone."),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              autofocus: true,
              onChanged: (value) => password = value,
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (await AuthService.deleteAccount(context, password) && context.mounted) {
      signOut(context);
    }
  }

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
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () => launchUrl(Uri.parse(constants.privacyPolicyUrl)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Use'),
                onTap: () => launchUrl(Uri.parse(constants.termsOfUseUrl)),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Clear the stored tokens
                    await AuthService.logout();
                    if (context.mounted) signOut(context);
                  },
                  child: const Text('Sign Out'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => confirmDeleteAccount(context),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  child: const Text('Delete Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
