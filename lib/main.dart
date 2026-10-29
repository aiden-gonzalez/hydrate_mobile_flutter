import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

import 'src/app.dart';
import 'src/screens/settings/settings_controller.dart';
import 'src/screens/settings/settings_service.dart';
import 'src/utils/constants.dart';
import 'src/utils/storage.dart';

// Prefer the first back camera. Some devices (tablets, Chromebooks, emulators) have no camera at
// all, or the lookup fails: fall back to a placeholder so the app still starts, and the camera
// screen shows an error if someone tries to use it.
Future<CameraDescription> pickCamera() async {
  try {
    final cameras = await availableCameras();
    final backCameras = cameras.where((cam) => cam.lensDirection == CameraLensDirection.back);
    if (backCameras.isNotEmpty) return backCameras.first;
    if (cameras.isNotEmpty) return cameras.first;
  } catch (e) {
    debugPrint("Unable to list cameras: $e");
  }
  return const CameraDescription(
      name: noCameraName, lensDirection: CameraLensDirection.external, sensorOrientation: 0);
}

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  final selectedCamera = await pickCamera();

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

  // Load tokens from storage
  final tokens = await readTokens(getConfiguredStorage());
  if (tokens != null) {
    // If tokens are found, store them in the zustand store
    useTokenStore().setTokens(tokens);
  }

  // TODO Add retrieveLostData(): https://pub.dev/packages/image_picker#handling-mainactivity-destruction-on-android

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(StoreScope(
      child: MyApp(
          settingsController: settingsController, camera: selectedCamera)));
}
