import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_view.dart';
import 'package:flutter_config/flutter_config.dart';

/// Edited flutter code sample for [NavigationBar].

class HydrateNavigation extends StatefulWidget {
  const HydrateNavigation({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<HydrateNavigation> createState() => _HydrateNavigationState();
}

class _HydrateNavigationState extends State<HydrateNavigation> {
  int currentPageIndex = 0;

  // Example of how to load environment variable
  String mapskey = FlutterConfig.get("GOOGLE_MAPS_API_KEY");

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.cyanAccent,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Badge(
              label: Text('2'),
              child: Icon(Icons.account_circle)
            ),
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.account_circle_outlined),
            ),
            label: 'Profile',
          ),
          NavigationDestination(
            selectedIcon: Badge(child: Icon(Icons.settings)),
            icon: Badge(child: Icon(Icons.settings_outlined)),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ),

        /// Profile page
        Scaffold(
          appBar: AppBar(
            title: const Text("Profile")
          ),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 1'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 2'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
              ],
            ),
          )
        ),

        /// Settings page
        SettingsView(controller: widget.controller)
      ][currentPageIndex],
    );
  }
}
