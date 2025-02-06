import 'dart:io';
import 'package:flutter/material.dart';

// A widget that displays the picture taken by the user.
class CapturedPhotoPreview extends StatelessWidget {
  const CapturedPhotoPreview({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review picture")),
      body: Image.file(File(imagePath)),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Retake button
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context, null);
            },
            heroTag: null,
            icon: const Icon(Icons.restart_alt),
            label: const Text("Retake")
          ),
          SizedBox(
            height: 10,
          ),
          // Accept button
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context, imagePath);
            },
            heroTag: null,
            icon: const Icon(Icons.check),
            label: const Text("Accept")
          )
        ]
      )
    );
  }
}
