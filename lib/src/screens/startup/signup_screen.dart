import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_text_field.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;
import 'package:url_launcher/url_launcher.dart';

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
  bool acceptedTerms = false;

  TextSpan link(String text, String url) {
    return TextSpan(
      text: text,
      style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
    );
  }

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
                    // Google Play's user generated content policy requires users to agree to
                    // terms that forbid objectionable content before they can contribute
                    CheckboxListTile(
                      value: acceptedTerms,
                      onChanged: (value) => setState(() => acceptedTerms = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text.rich(TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: "I agree to the "),
                          link("Terms of Use", constants.termsOfUseUrl),
                          const TextSpan(text: " and "),
                          link("Privacy Policy", constants.privacyPolicyUrl),
                          const TextSpan(text: ". No offensive or inappropriate content."),
                        ],
                      )),
                    ),
                    CustomButton(
                      buttonText: 'Signup',
                      onPressed: () async {
                        if (username.isEmpty || email.isEmpty || password.isEmpty) {
                          toast.showToast(context, "Please fill in all fields.");
                          return;
                        }
                        if (password.length < 8) {
                          toast.showToast(context, "Password must be at least 8 characters.");
                          return;
                        }
                        if (!acceptedTerms) {
                          toast.showToast(context, "Please agree to the Terms of Use to continue.");
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
