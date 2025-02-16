import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: ScreenTitle(
          title: 'Signup',
        ),
      ),
    );
  }
}
