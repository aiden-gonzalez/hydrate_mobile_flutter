import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_text_field.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/top_screen_image.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    // TODO set up PopScope to prevent going back to this page when signed in?
    // https://api.flutter.dev/flutter/widgets/PopScope-class.html
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const TopScreenImage(screenImageName: 'home.png'),
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
                      ),
                    ),
                    CustomBottomScreen(
                      textButton: 'Login',
                      heroTag: 'login_btn',
                      question: 'Forgot password?',
                      buttonPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _saving = true;
                        });
                        try {
                          await _auth.signInWithEmailAndPassword(
                              email: _email, password: _password);
              
                          if (context.mounted) {
                            setState(() {
                              _saving = false;
                              Navigator.popAndPushNamed(
                                  context, LoginScreen.id);
                            });
                            Navigator.pushNamed(context, WelcomeScreen.id);
                          }
                        } catch (e) {
                          signUpAlert(
                            context: context,
                            onPressed: () {
                              setState(() {
                                _saving = false;
                              });
                              Navigator.popAndPushNamed(
                                  context, LoginScreen.id);
                            },
                            title: 'WRONG PASSWORD OR EMAIL',
                            desc:
                                'Confirm your email and password and try again',
                            btnText: 'Try Now',
                          ).show();
                        }
                      },
                      questionPressed: () {
                        signUpAlert(
                          onPressed: () async {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: _email);
                          },
                          title: 'RESET YOUR PASSWORD',
                          desc:
                              'Click on the button to reset your password',
                          btnText: 'Reset Now',
                          context: context,
                        ).show();
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
