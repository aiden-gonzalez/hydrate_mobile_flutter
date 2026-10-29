import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/osm_map_layers.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/screens/take_picture_screen.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/images.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FobCreateView extends StatefulWidget {
  const FobCreateView(
      {super.key, required this.camera, required this.initialLocation, required this.initialZoom});

  final CameraDescription camera;
  final LatLng initialLocation;
  final double initialZoom;

  @override
  State<FobCreateView> createState() => _FobCreateViewState();
}

class _FobCreateViewState extends State<FobCreateView> {
  final List<bool> _selectedFobType = [true, false];

  // Create a global key that uniquely identifies the Form widget and allows validation of the form
  final _formKey = GlobalKey<FormState>();

  final String fountainLabel = "Fountain";
  final String bathroomLabel = "Bathroom";

  // String fields
  String name = "";
  String gender = "Male";

  // Checkboxes
  bool hasBottleFiller = false;
  bool hasPeriodProducts = false;
  bool hasBabyChanger = false;

  // Image path
  String? imagePath;

  // Location for the new FoB
  LatLng? selectedLocation; // Initialize to provided location

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Contribute')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                buildFobTypeToggle(),
                const SizedBox(height: 10),
                buildMap(),
                const SizedBox(height: 10),
                buildImagePicker(),
                const SizedBox(height: 10),
                buildFobForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFobTypeToggle() {
    final List<Text> types = [
      Text(fountainLabel, style: Theme.of(context).textTheme.titleMedium),
      Text(bathroomLabel, style: Theme.of(context).textTheme.titleMedium),
    ];

    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          for (int i = 0; i < _selectedFobType.length; i++) {
            _selectedFobType[i] = i == index;
          }
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      constraints: BoxConstraints(
        minHeight: 50.0,
        minWidth: (MediaQuery.of(context).size.width) / 3,
      ),
      isSelected: _selectedFobType,
      children: types,
    );
  }

  Widget buildMap() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).highlightColor,
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: widget.initialLocation,
            initialZoom: widget.initialZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() {
                  selectedLocation = position.center;
                });
              }
            },
          ),
          children: [
            osmTileLayer(),
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocation ?? widget.initialLocation,
                  width: 50,
                  height: 50,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            osmAttribution(),
          ],
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    final ImagePicker picker = ImagePicker();

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
                      debugPrint(picture);
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
                      if (pickedImage == null) return;
                      // Process the image to make it square
                      final processedImagePath = await processImageToSquare(pickedImage.path);
                      if (processedImagePath == null) {
                        if (context.mounted) toast.showToast(context, "Couldn't read that image, please try another.");
                        return;
                      }
                      setState(() {
                        imagePath = processedImagePath;
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

  Widget buildFobForm() {
    final isFountain = _selectedFobType[0];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
              onChanged: (value) => setState(() => name = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          if (isFountain)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CheckboxListTile(
                title: const Text("Has Bottle Filler"),
                value: hasBottleFiller,
                onChanged: (bool? value) => setState(() => hasBottleFiller = value!),
                secondary: const Icon(Icons.water_drop),
              ),
            ),
          if (!isFountain) ...buildBathroomFields(),
          ElevatedButton(
            onPressed: submitFob,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  List<Widget> buildBathroomFields() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButtonFormField<String>(
          value: gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          onChanged: (value) => setState(() => gender = value!),
          items: ['Male', 'Female', 'All Gender']
              .map((label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a gender';
            }
            return null;
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CheckboxListTile(
          title: const Text('Period Products Available'),
          value: hasPeriodProducts,
          onChanged: (bool? value) => setState(() => hasPeriodProducts = value!),
          secondary: const Icon(Icons.spa),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CheckboxListTile(
          title: const Text('Baby Changer Available'),
          value: hasBabyChanger,
          onChanged: (bool? value) => setState(() => hasBabyChanger = value!),
          secondary: const Icon(Icons.baby_changing_station),
        ),
      ),
    ];
  }

  Future<void> submitFob() async {
    if (_formKey.currentState!.validate()) {
      final isFountain = _selectedFobType[0];

      // First create the Fob
      final fobCreationResponse = await createFob(
        useTokenStore().state.accessToken,
        FobCreationDetails(
          type: isFountain ? FobType.fountain : FobType.bathroom,
          name: name,
          location: Location(
            lat: selectedLocation?.latitude ?? widget.initialLocation.latitude,
            lng: selectedLocation?.longitude ?? widget.initialLocation.longitude,
          ),
          info: isFountain
              ? FountainInfo(bottleFiller: hasBottleFiller)
              : BathroomInfo.from(
                  gender: gender,
                  sanitaryProducts: hasPeriodProducts,
                  babyChanger: hasBabyChanger,
                ),
        ),
      );

      if (fobCreationResponse.statusCode != 201) {
        toast.showToast(context, "Failed to create fob: ${fobCreationResponse.body}");
        return;
      }

      // Upload the fob picture
      if (imagePath != null) {
        try {
          await pictureUploadFlow(
            useTokenStore().state.accessToken,
            jsonDecode(fobCreationResponse.body)['id'] as String,
            File(imagePath!),
          );
        } catch (error) {
          toast.showToast(context, "Failed to create due to picture upload failure: $error");
          // Delete the fob
          try {
            await deleteFob(
              useTokenStore().state.accessToken,
              jsonDecode(fobCreationResponse.body)['id'] as String,
            );
          } catch (deleteError) {
            toast.showToast(context, "Failed to delete fob after picture upload failure: $deleteError");
          }
          return;
        }
      }

      // Everything went well, show a success message and pop
      toast.showToast(context, "Fob created successfully");
      Navigator.pop(context, true);
    }
  }
}
