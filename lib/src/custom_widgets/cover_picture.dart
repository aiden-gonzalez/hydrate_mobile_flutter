import 'package:flutter/material.dart';

class CoverPicture extends StatelessWidget {
  const CoverPicture({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(imagePath)
    );
  }
}
