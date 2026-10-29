import 'package:camera/camera.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart';
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

    // Default to flash off
    _flashEnabled = false;

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = widget.camera.name == noCameraName
        ? Future.error(CameraException("noCamera", "This device has no camera"))
        : _controller.initialize().then((_) {
      // Explicitly set initial flash mode to match our UI state
      if (mounted) {
        _controller.setFlashMode(FlashMode.off);
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncFlashState() async {
    try {
      // Ensure the controller is initialized
      if (!_controller.value.isInitialized) {
        await _initializeControllerFuture;
      }

      // Get current flash mode from camera
      final currentMode = _controller.value.flashMode;
      debugPrint('Before sync - Camera flash mode: ${currentMode.toString()}');
      debugPrint('Before sync - UI flash state: ${_flashEnabled ? "ON" : "OFF"}');

      // Set the flash mode according to current UI state
      final targetMode = _flashEnabled ? FlashMode.always : FlashMode.off;
      await _controller.setFlashMode(targetMode);

      // Verify the change took effect
      final newMode = _controller.value.flashMode;
      debugPrint('After sync - Camera flash mode: ${newMode.toString()}');
    } catch (e) {
      debugPrint('Error syncing flash mode: $e');
    }
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
                          if (snapshot.hasError) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "Camera unavailable. Check that hydRate has camera permission, "
                                  "or choose a photo from your gallery instead.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else if (snapshot.connectionState == ConnectionState.done) {
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
                      // First check the camera's current flash mode
                      final currentFlashMode = _controller.value.flashMode;
                      debugPrint('Current flash mode: $currentFlashMode');

                      try {
                        // What we want the flash mode to be
                        final newFlashMode = _flashEnabled ? FlashMode.off : FlashMode.always;
                        final newFlashEnabled = !_flashEnabled;

                        // Update the camera first, before changing UI state
                        await _controller.setFlashMode(newFlashMode);

                        // Only update UI state if the camera update was successful
                        setState(() {
                          _flashEnabled = newFlashEnabled;
                        });

                        debugPrint('Flash mode toggled to: ${_flashEnabled ? "ON" : "OFF"}');
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
                        if (processedImagePath == null || !context.mounted) return;
                
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

                        // When we return from the preview screen, sync the flash state
                        await _syncFlashState();
                
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
