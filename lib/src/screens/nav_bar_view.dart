import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/screens/map/open_map_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';

/// Edited flutter code sample for [NavigationBar].

class HydrateNavigation extends StatefulWidget {
  const HydrateNavigation({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  State<HydrateNavigation> createState() => _HydrateNavigationState();
}

class _HydrateNavigationState extends State<HydrateNavigation> {
  int currentPageIndex = 0;

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
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          /// Home page
          OpenMapView(settingsController: widget.settingsController, camera: widget.camera),

          /// Profile page
          ProfileView(settingsController: widget.settingsController)
        ]),
    );
  }
}
