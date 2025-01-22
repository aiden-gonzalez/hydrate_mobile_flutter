import 'dart:io';
import 'package:flutter/material.dart';

// A widget that displays the picture taken by the user.
class DisplayPicture extends StatelessWidget {
  const DisplayPicture({super.key, required this.imagePath});
  
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.file(File(imagePath));
  }
}
