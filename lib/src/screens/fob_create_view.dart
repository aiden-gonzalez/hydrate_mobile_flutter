import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FobCreateView extends StatefulWidget {
  const FobCreateView({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<FobCreateView> createState() => _FobCreateViewState();
}

class _FobCreateViewState extends State<FobCreateView> {
  final List<bool> _selectedType = [true, false];

  @override
  Widget build(BuildContext context) {
    final List<Widget> types = [
      Text("Fountain", style: Theme.of(context).textTheme.titleMedium),
      Text("Bathroom", style: Theme.of(context).textTheme.titleMedium)
    ];

    return Scaffold(
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
                        for (int i = 0; i < _selectedType.length; i++) {
                          _selectedType[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    // selectedBorderColor: Colors.red[700],
                    // selectedColor: Colors.white,
                    // fillColor: Colors.red[200],
                    // color: Colors.red[400],
                    constraints: BoxConstraints(
                        minHeight: 50.0,
                        minWidth: (MediaQuery.of(context).size.width) / 3),
                    isSelected: _selectedType,
                    children: types),
                // Add picture
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).highlightColor),
                    child: InkWell(
                      onTap: () {
                        debugPrint("Tapped inkwell");
                      },
                      child: SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: Center(
                              child: Text("Tap to take photo...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall))),
                    ),
                  ),
                )
              ]),
        )));
  }
}
