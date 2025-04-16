import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_create_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_detail_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:latlong2/latlong.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

class OpenMapView extends StatefulWidget {
  const OpenMapView({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  State<OpenMapView> createState() => _OpenMapViewState();
}

class _OpenMapViewState extends State<OpenMapView> {
  final mapController = MapController();
  final LatLng purdue = LatLng(40.429052, -86.913124);

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: "dev.fleaflet.flutter_map.example",
  );

  List<Marker> markers = [];
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initial marker fetch
    fetchMarkers(purdue);
  }

  Future<void> fetchMarkers(LatLng cameraPosition) async {
    List<Marker> fetchedMarkers = [];
    final tokenStore = useTokenStore();
    final tokens = await AuthService.checkOrRefreshToken(tokenStore.state);

    if (tokens == null) {
      debugPrint("Unable to fetch markers: No valid token");
      return;
    }

    final fobs = await getFobsInArea(tokens.accessToken, cameraPosition);
    for (var fob in fobs) {
      fetchedMarkers.add(
        Marker(
          point: fob.location.toLatLng(),
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FobDetailView(
                    settingsController: widget.settingsController,
                    fobId: fob.id
                  )
                )
              );
            },
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red
            )
          )
        )
      );
    }
    
    setState(() {
      markers = fetchedMarkers;
    });
  }

  void onMapEvent(MapEvent event) {
    // If the event is a move end event, we want to fetch markers
    if (event is MapEventMoveEnd) {
      // Cancel any ongoing debounce timer
      debounceTimer?.cancel();

      // Start a new debounce timer
      debounceTimer = Timer(const Duration(milliseconds: 700), () {
        // Fetch markers for the new center
        fetchMarkers(mapController.camera.center);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: purdue,
            initialZoom: 17,
            interactionOptions: const InteractionOptions(
              flags: ~InteractiveFlag.doubleTapZoom
            ),
            onMapEvent: onMapEvent
          ),
          children: [
            openStreetMapTileLayer,
            MarkerLayer(markers: markers)
          ]
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FobCreateView(camera: widget.camera)),
            );
          },
          label: const Text("Contribute"),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up debounce timer
    debounceTimer?.cancel();
    super.dispose();
  }
}
