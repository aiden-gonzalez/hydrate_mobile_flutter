import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/utils/images.dart';
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
    // Get device orientation
    final isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    // Get the bottom padding for the safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text("Take a picture")),
      // Using SafeArea to respect system UI elements
      body: SafeArea(
        child: Column(
          children: [
            // Expanded area to center the camera preview
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square UI boundary
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            // Center the preview and crop to fit the square
                            return Center(
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.cover, // This will crop to fill the container
                                      child: SizedBox(
                                        width: 1,
                                        // Adjust for device orientation
                                        height: isVertical
                                                  ? _controller.value.aspectRatio
                                                  : 1 / _controller.value.aspectRatio,
                                        child: CameraPreview(_controller),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Button area with proper padding
            Padding(
              padding: EdgeInsets.only(
                left: 20.0, 
                right: 20.0,
                bottom: 20.0 + bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
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
                        debugPrint('Flash mode set successfully: $_flashEnabled');
                      } catch (e) {
                        debugPrint('Error setting flash mode: $e');
                      }
                    },
                    child: _flashEnabled ? const Icon(Icons.flash_on) : const Icon(Icons.flash_off),
                  ),
                  FloatingActionButton.extended(
                    onPressed: () async {
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

                        // Process the image to make it square and resize it
                        final processedImagePath = await processImageToSquare(image.path);
                
                        // If the picture was taken, display it on a new screen.
                        final imagePath = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CapturedPhotoPreview(
                              // Pass the automatically generated path to
                              // the DisplayPictureScreen widget.
                              imagePath: processedImagePath,
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
                    label: const Text("Capture"),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}
