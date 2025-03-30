import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_alert_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_text_field.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/top_screen_image.dart';
import 'package:hydrate_mobile_flutter/src/screens/nav_bar_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart' as api;
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email = "";
  late String password = "";
  bool failure = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const TopScreenImage(screenImageName: 'home.jpg'),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ScreenTitle(title: 'Login'),
                    CustomTextField(
                      textField: TextField(
                          onChanged: (value) {
                            email = value;
                          },
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          decoration: InputDecoration.collapsed(hintText: "Email")),
                    ),
                    CustomTextField(
                        textField: TextField(
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      decoration: InputDecoration.collapsed(hintText: "Password"),
                    )),
                    CustomButton(
                        buttonText: 'Login',
                        onPressed: () async {
                          if (email.isEmpty || password.isEmpty) {
                            toast.showToast(context, "Please fill in all fields.");
                            return;
                          }
                          await AuthService.login(context, email, password);
                          // Welcome screen binding will handle navigation
                        }),
                    CustomAlertButton(
                        buttonText: "Forgot password?",
                        alertTitle: "Reset password?",
                        alertDescription: "Confirm to send password reset email",
                        dialogResponseHandler: (choice) async {
                          if (choice == "Ok") {
                            try {
                              await api.sendPasswordResetEmail(email);
                              toast.showToast(context, "Password reset email sent successfully.");
                            } catch (e) {
                              debugPrint("Error sending password reset email: $e");
                              toast.showToast(context, "Failed to send password reset email.");
                            }
                          }
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
