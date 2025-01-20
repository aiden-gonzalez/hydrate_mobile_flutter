import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class OpenMapView extends StatefulWidget {
  const OpenMapView({super.key});

  @override
  State<OpenMapView> createState() => _OpenMapViewState();
}

class _OpenMapViewState extends State<OpenMapView> {

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: "dev.fleaflet.flutter_map.example",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(1.28, 103),
          initialZoom: 11,
          interactionOptions: const InteractionOptions(
            flags: ~InteractiveFlag.doubleTapZoom
          )
        ),
        children: [
          openStreetMapTileLayer,
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(1.286493, 103.860359),
                width: 50,
                height: 50,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    debugPrint("tapped marker");
                  },
                  child: Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.red
                  ),
                )
              )
            ]
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
