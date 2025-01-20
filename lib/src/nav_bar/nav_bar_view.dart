import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/environment.dart';
import 'package:hydrate_mobile_flutter/src/google_maps/google_maps_view.dart';
import 'package:hydrate_mobile_flutter/src/profile/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_view.dart';

/// Edited flutter code sample for [NavigationBar].

class HydrateNavigation extends StatefulWidget {
  const HydrateNavigation({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<HydrateNavigation> createState() => _HydrateNavigationState();
}

class _HydrateNavigationState extends State<HydrateNavigation> {
  int currentPageIndex = 0;

  // Example of accessing environment variables
  String apiKey = Environment.googleMapsKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon:
                Badge(label: Text('2'), child: Icon(Icons.account_circle)),
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
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          /// Home page
          SafeArea(child: MapSample()),

          /// Profile page
          ProfileView(settingsController: widget.controller),

          /// Settings page
          SettingsView(settingsControler: widget.controller)
        ]),
    );
  }
}
