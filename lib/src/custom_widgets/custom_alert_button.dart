import 'package:flutter/material.dart';

class CustomAlertButton extends StatelessWidget {
  const CustomAlertButton(
      {super.key,
      required this.buttonText,
      required this.alertTitle,
      required this.alertDescription,
      required this.dialogResponseHandler});

  final String buttonText;
  final String alertTitle;
  final String alertDescription;
  final Function dialogResponseHandler;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(alertTitle),
            content: Text(alertDescription),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, "Cancel"),
                child: const Text("Cancel")
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "Ok"),
                child: const Text("Ok")
              )
            ]
          )
        ).then((choice) {
          dialogResponseHandler(choice);
        })},
      child: Text(buttonText)
    );
  }
}
