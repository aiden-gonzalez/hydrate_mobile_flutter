import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    // TODO set up PopScope to prevent going back to this page when signed in?
    // https://api.flutter.dev/flutter/widgets/PopScope-class.html
    return Scaffold(
      body: const Center(
        child: ScreenTitle(
          title: 'Signup',
        ),
      ),
    );
  }
}
