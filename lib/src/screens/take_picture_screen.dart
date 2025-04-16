import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/display_picure.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _flashEnabled;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // Default to flash off
    _flashEnabled = false;
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next steps.
    return Scaffold(
        appBar: AppBar(title: const Text("Take a picture")),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              debugPrint("Camera initialized");
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              debugPrint("Camera not initialized");
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flash toggle button
              FloatingActionButton(
                onPressed: () async {
                  debugPrint('Current flashEnabled state: $_flashEnabled');
                  try {
                    if (_flashEnabled) {
                      await _controller.setFlashMode(FlashMode.off);
                      setState(() {
                        _flashEnabled = false;
                      });
                    } else {
                      await _controller.setFlashMode(FlashMode.always);
                      setState(() {
                        _flashEnabled = true;
                      });
                    }
                    debugPrint('Flash mode set successfully. Current state: $_flashEnabled');
                  } catch (e) {
                    debugPrint('Error setting flash mode: $e');
                  }
                },
                child: _flashEnabled ? const Icon(Icons.flash_on) : const Icon(Icons.flash_off)
              ),
              // Take picture button
              FloatingActionButton.extended(
                // Provide an onPressed callback.
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Indicate photo capturing...
                    ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Taking photo...')));

                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;
            
                    // Attempt to take a picture and then get the location
                    // where the image file is saved.
                    final image = await _controller.takePicture();
            
                    if (!context.mounted) return;
            
                    // If the picture was taken, display it on a new screen.
                    final imagePath = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CapturedPhotoPreview(
                          // Pass the automatically generated path to
                          // the DisplayPictureScreen widget.
                          imagePath: image.path,
                        ),
                      ),
                    );
            
                    // If imagePath isn't null (picture was accepted), pop it up the stack
                    if (imagePath != null && context.mounted) {
                      Navigator.pop(context, imagePath);
                    }
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    debugPrint(e.toString());
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture"))],
          ),
        ));
  }
}
