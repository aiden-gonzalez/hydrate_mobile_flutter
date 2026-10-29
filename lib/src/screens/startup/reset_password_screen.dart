import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_button.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/custom_text_field.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/screen_title.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;

// Shown after a reset code has been emailed. On success the user is signed in, and the
// welcome screen's token listener takes care of navigation (same as logging in).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String code = "";
  String newPassword = "";
  String confirmPassword = "";
  bool submitting = false;

  Future<void> submit() async {
    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      toast.showToast(context, "Please fill in all fields.");
      return;
    }
    if (newPassword != confirmPassword) {
      toast.showToast(context, "Passwords don't match.");
      return;
    }
    if (newPassword.length < 8) {
      toast.showToast(context, "Password must be at least 8 characters.");
      return;
    }

    setState(() => submitting = true);
    final tokens = await AuthService.resetPassword(context, code, newPassword, confirmPassword);
    if (!mounted) return;
    if (tokens == null) {
      setState(() => submitting = false);
    } else {
      toast.showToast(context, "Password updated!");
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ScreenTitle(title: 'Reset password'),
                const SizedBox(height: 16),
                Text(
                  "If an account exists for ${widget.email}, we've emailed it a code. "
                  "It expires in 15 minutes.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  textField: TextField(
                    onChanged: (value) => code = value,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration.collapsed(hintText: "Code"),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  textField: TextField(
                    obscureText: true,
                    onChanged: (value) => newPassword = value,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration.collapsed(hintText: "New password"),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  textField: TextField(
                    obscureText: true,
                    onChanged: (value) => confirmPassword = value,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration.collapsed(hintText: "Confirm new password"),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  buttonText: submitting ? 'Saving...' : 'Set new password',
                  onPressed: submitting ? () {} : submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
