import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydrate_mobile_flutter/src/fob_create/fob_create_view.dart';
import 'package:hydrate_mobile_flutter/src/fob_detail/fob_detail_view.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_controller.dart';
import 'package:latlong2/latlong.dart';

class OpenMapView extends StatefulWidget {
  const OpenMapView({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<OpenMapView> createState() => _OpenMapViewState();
}

class _OpenMapViewState extends State<OpenMapView> {

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: "dev.fleaflet.flutter_map.example",
  );
  
  final LatLng purdue = LatLng(40.429052, -86.913124);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: purdue,
          initialZoom: 17,
          interactionOptions: const InteractionOptions(
            flags: ~InteractiveFlag.doubleTapZoom
          )
        ),
        children: [
          openStreetMapTileLayer,
          MarkerLayer(
            markers: [
              Marker(
                point: purdue,
                width: 50,
                height: 50,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FobDetailView(settingsController: widget.settingsController, fobId: "fountain_id_here")),
                    );
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FobCreateView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
