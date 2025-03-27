import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';
import 'src/screens/settings/settings_controller.dart';
import 'src/screens/settings/settings_service.dart';

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  CameraDescription? selectedCamera;
  final backCameras = cameras
      .where((CameraDescription cam) =>
          cam.lensDirection == CameraLensDirection.back)
      .toList();
  // If there are any back cameras available, take the first
  if (backCameras.isEmpty) {
    selectedCamera = cameras.first;
  } else {
    // Otherwise default to the first camera
    selectedCamera = backCameras.first;
  }

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");

  // TODO Add retrieveLostData(): https://pub.dev/packages/image_picker#handling-mainactivity-destruction-on-android

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(StoreScope(
      child: MyApp(
          settingsController: settingsController, camera: selectedCamera)));
}
