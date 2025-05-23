import 'dart:io';
import 'package:flutter/material.dart';

// A widget that displays the picture taken by the user.
class CapturedPhotoPreview extends StatelessWidget {
  const CapturedPhotoPreview({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding for the safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Review picture")),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded area to center the image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square aspect ratio
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Button area with padding
            Padding(
              padding: EdgeInsets.only(
                left: 20.0, 
                right: 20.0,
                bottom: 20.0 + bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Retake'),
                    backgroundColor: Colors.redAccent,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pop(context, imagePath);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Use Photo'),
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
