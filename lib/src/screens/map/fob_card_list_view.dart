import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_detail_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/calc.dart' as calc;

class FobCardListView extends StatelessWidget {
  const FobCardListView({
    super.key,
    required this.fobs,
    required this.fobsCenter,
    required this.camera,
    required this.settingsController,
  });

  final List<Fob> fobs;
  final LatLng fobsCenter;
  final CameraDescription camera;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fobs.length,
        itemBuilder: (context, index) {
          final fob = fobs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FobDetailView(
                    settingsController: settingsController,
                    camera: camera,
                    fobId: fob.id,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          fob.isFountain()
                              ? Icons.water_drop
                              : Icons.bathroom,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fob.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_pin, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          "${calc.distance(fobsCenter, fob.location.toLatLng()).toStringAsFixed(2)} m",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index + 1 == fob.averageRating?.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
