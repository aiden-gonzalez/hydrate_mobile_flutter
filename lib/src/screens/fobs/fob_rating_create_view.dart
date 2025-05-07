import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/screens/take_picture_screen.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;
import 'package:image_picker/image_picker.dart';

class FobRatingCreateView extends StatefulWidget {
  const FobRatingCreateView({super.key, required this.camera, required this.fobId});

  final CameraDescription camera;
  final String fobId;

  @override
  State<FobRatingCreateView> createState() => _FobRatingCreateViewState();
}

class _FobRatingCreateViewState extends State<FobRatingCreateView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  String? imagePath;

  // Fountain rating fields
  int pressure = 3;
  int taste = 3;
  int temperature = 3;

  // Bathroom rating fields
  int cleanliness = 3;
  int decor = 3;
  int drying = 3;
  int privacy = 3;
  int washing = 3;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Rating')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                buildImagePicker(),
                const SizedBox(height: 10),
                buildRatingForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).highlightColor,
        ),
        child: imagePath == null
            ? Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final picture = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakePictureScreen(camera: widget.camera),
                        ),
                      );
                      setState(() {
                        imagePath = picture;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Center(
                        child: Text(
                          "Tap to take photo...",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () async {
                      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        imagePath = pickedImage?.path;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Center(
                        child: Text(
                          "Tap to select from gallery...",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Image.file(File(imagePath!), height: 450),
      ),
    );
  }

  Widget buildRatingForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.fobId.startsWith(constants.fountainIdPrefix)) ...[
            buildSlider("Pressure", pressure, (value) => setState(() => pressure = value)),
            buildSlider("Taste", taste, (value) => setState(() => taste = value)),
            buildSlider("Temperature", temperature, (value) => setState(() => temperature = value)),
          ] else ...[
            buildSlider("Cleanliness", cleanliness, (value) => setState(() => cleanliness = value)),
            buildSlider("Decor", decor, (value) => setState(() => decor = value)),
            buildSlider("Drying", drying, (value) => setState(() => drying = value)),
            buildSlider("Privacy", privacy, (value) => setState(() => privacy = value)),
            buildSlider("Washing", washing, (value) => setState(() => washing = value)),
          ],
          ElevatedButton(
            onPressed: submitRating,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget buildSlider(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: value.toString(),
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ],
      ),
    );
  }

  Future<void> submitRating() async {
    if (_formKey.currentState!.validate()) {
      final ratingDetails = widget.fobId.startsWith(constants.fountainIdPrefix)
          ? FountainRatingDetails(
              pressure: pressure,
              taste: taste,
              temperature: temperature,
            )
          : BathroomRatingDetails(
              cleanliness: cleanliness,
              decor: decor,
              drying: drying,
              privacy: privacy,
              washing: washing,
            );

      final response = await createRating(
        useTokenStore().state.accessToken,
        widget.fobId,
        ratingDetails,
      );

      if (response.statusCode == 201) {
        toast.showToast(context, "Rating submitted successfully");
        Navigator.pop(context);
      } else {
        toast.showToast(context, "Failed to submit rating: ${response.body}");
      }
    }
  }
}
