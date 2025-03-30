import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_text_field.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String username = "";
  late String email = "";
  late String password = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Expanded(
                flex: 1,
                child: Center(
                  child: ScreenTitle(title: 'Signup'),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(
                      textField: TextField(
                        onChanged: (value) {
                          username = value;
                        },
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        decoration: InputDecoration.collapsed(hintText: "Username"),
                      ),
                    ),
                    CustomTextField(
                      textField: TextField(
                        onChanged: (value) {
                          email = value;
                        },
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        decoration: InputDecoration.collapsed(hintText: "Email"),
                      ),
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
                      ),
                    ),
                    CustomButton(
                      buttonText: 'Signup',
                      onPressed: () async {
                        if (username.isEmpty || email.isEmpty || password.isEmpty) {
                          toast.showToast(context, "Please fill in all fields.");
                          return;
                        }
                        await AuthService.signup(context, username, email, password);
                        // Welcome screen binding will handle navigation
                      },
                    ),
                    CustomButton(
                      buttonText: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
