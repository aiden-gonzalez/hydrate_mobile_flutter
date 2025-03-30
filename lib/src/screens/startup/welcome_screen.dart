import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/top_screen_image.dart';
import 'package:hydrate_mobile_flutter/src/screens/nav_bar_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/screens/startup/login_screen.dart';
import 'package:hydrate_mobile_flutter/src/screens/startup/signup_screen.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    final storedTokens = useTokenStore().select(context, (state) => state);

    Future<void> tokenCheck(BuildContext context) async {
      // If no tokens, stop now
      if (storedTokens.isEmpty) {
        return;
      }

      // If token expired, try to refresh
      if (storedTokens.isExpired) {
        final newTokens = await AuthService.refreshToken(storedTokens.refreshToken, storedTokens.accessToken);
        if (newTokens == null) {
          return;
        }
      }

      // Tokens acquired, navigate to the main screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HydrateNavigation(
                settingsController: settingsController,
                camera: camera)),
        (Route<dynamic> route) => false);
    }

    // Check / refresh tokens and navigate after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) => tokenCheck(context));

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopScreenImage(screenImageName: 'home.jpg'),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 15.0, left: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const ScreenTitle(title: 'Hello'),
                      const Text(
                        'Welcome to hydRate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Hero(
                        tag: 'login_btn',
                        child: CustomButton(
                          buttonText: 'Login',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginScreen(settingsController: settingsController, camera: camera)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Hero(
                        tag: 'signup_btn',
                        child: CustomButton(
                          buttonText: 'Sign Up',
                          isOutlined: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignupScreen(settingsController: settingsController, camera: camera)),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}