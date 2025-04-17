import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/screens/take_picture_screen.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FobCreateView extends StatefulWidget {
  const FobCreateView({super.key, required this.camera, required this.initialLocation, required this.initialZoom});

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
    final List<Text> types = [
      Text(fountainLabel, style: Theme.of(context).textTheme.titleMedium),
      Text(bathroomLabel, style: Theme.of(context).textTheme.titleMedium)
    ];

    bool isFountain() {
      return types[_selectedFobType.indexOf(true)].data == fountainLabel;
    }

    final ImagePicker picker = ImagePicker();

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
                  SizedBox(height: 5),
                  // Single select for FoB type
                  ToggleButtons(
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
                          minHeight: 50.0, minWidth: (MediaQuery.of(context).size.width) / 3),
                      isSelected: _selectedFobType,
                      children: types),
                  SizedBox(height: 10),
                  // Map for selecting location
                  Padding(
                    padding: EdgeInsets.all(10.0),
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
                          TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: "dev.fleaflet.flutter_map.example",
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: selectedLocation ?? widget.initialLocation,
                                width: 50,
                                height: 50,
                                alignment: Alignment.topCenter,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 50,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Add picture
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Theme.of(context).highlightColor),
                        child: imagePath == null
                            ? Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final picture = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TakePictureScreen(camera: widget.camera)),
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
                                          child: Text("Tap to take photo...",
                                              style: Theme.of(context).textTheme.headlineSmall))),
                                ),
                                Divider(),
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
                                      child: Text("Tap to select from gallery...",
                                      style: Theme.of(context).textTheme.headlineSmall)
                                    )
                                  )
                                )
                                ],
                            )
                            : Image.file(File(imagePath!),
                            height: 450)),
                  ),
                  // Form for entering fob information
                  Form(
                      key: _formKey,
                      child: Column(spacing: 10, children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                              decoration: InputDecoration(labelText: "Name"),
                              onChanged: (value) {
                                setState(() => name = value);
                              },
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              }),
                        ),
                        if (isFountain())
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CheckboxListTile(
                                title: const Text("Has Bottle Filler"),
                                value: hasBottleFiller,
                                onChanged: (bool? value) {
                                  setState(() => hasBottleFiller = value!);
                                },
                                secondary: const Icon(Icons.water_drop)),
                          ),
                        if (!isFountain())
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              value: gender,
                              decoration: InputDecoration(labelText: 'Gender'),
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                              items: ['Male', 'Female', 'All Gender']
                                  .map((label) => DropdownMenuItem(
                                        value: label,
                                        child: Text(label),
                                      ))
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a gender';
                                }
                                return null;
                              },
                            ),
                          ),
                        if (!isFountain())
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CheckboxListTile(
                                title: Text('Period Products Available'),
                                value: hasPeriodProducts,
                                onChanged: (bool? value) {
                                  setState(() {
                                    hasPeriodProducts = value!;
                                  });
                                },
                                secondary: Icon(Icons.spa)),
                          ),
                        if (!isFountain())
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CheckboxListTile(
                                title: Text('Baby Changer Available'),
                                value: hasBabyChanger,
                                onChanged: (bool? value) {
                                  setState(() {
                                    hasBabyChanger = value!;
                                  });
                                },
                                secondary: Icon(Icons.baby_changing_station)),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (isFountain()) {
                                var response = await createFountain(
                                    "token",
                                    FountainCreationDetails(
                                      name: name,
                                      location: Location(
                                            lat: selectedLocation?.latitude ?? widget.initialLocation.latitude,
                                            lng: selectedLocation?.longitude ?? widget.initialLocation.longitude),
                                      info: FountainInfo(
                                        bottleFiller: hasBottleFiller
                                      )
                                    ));
                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text("Fountain created successfully")));
                                } else {
                                  ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text("Failed to create fountain, try again")));
                                }
                              }
                            }
                          },
                          child: Text('Submit'),
                        )
                      ]))
                ]),
          ))),
    );
  }
}
