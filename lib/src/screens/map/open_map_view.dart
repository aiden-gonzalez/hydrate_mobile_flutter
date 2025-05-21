import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_create_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_detail_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/map/fob_card_list_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/calc.dart' as calc;
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

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: "dev.fleaflet.flutter_map.example",
  );

  LatLng fobsCenter = LatLng(40.429052, -86.913124); // Center of fetched fobs
  List<Fob> fobs = []; // Fobs currently fetched for map
  List<Marker> markers = []; // Markers currently on map
  
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initial marker fetch
    fetchMarkers(fobsCenter, 1000);
  }

  Future<void> fetchMarkers(LatLng cameraPosition, int radius) async {
    List<Marker> fetchedMarkers = [];
    final tokenStore = useTokenStore();
    final tokens = await AuthService.checkOrRefreshToken(tokenStore.state);

    if (tokens == null) {
      debugPrint("Unable to fetch markers: No valid token");
      return;
    }

    final fobsInArea = await getFobsInArea(tokens.accessToken, cameraPosition, radiusInMeters: radius);
    for (var fob in fobsInArea) {
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
                    camera: widget.camera,
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

    // Add a small marker at the center of the map
    fetchedMarkers.add(
      Marker(
        point: cameraPosition,
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: const Icon(
          Icons.location_searching,
          size: 20,
          color: Colors.blueAccent,
        ),
      ),
    );

    setState(() {
      fobsCenter = cameraPosition;
      fobs = fobsInArea; 
      markers = fetchedMarkers;
    });
  }

  List<Fob> getSortedFobsByDistance(LatLng center) {
    fobs.sort((a, b) {
      final distanceA = calc.distance(center, a.location.toLatLng());
      final distanceB = calc.distance(center, b.location.toLatLng());
      return distanceA.compareTo(distanceB);
    });
    return fobs;
  }

  void onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      debounceTimer?.cancel();

      debounceTimer = Timer(const Duration(milliseconds: 500), () {
        fetchMarkers(
          mapController.camera.center,
          getMapRadius(mapController.camera.visibleBounds)
        );
      });
    }
  }

  int getMapRadius(LatLngBounds bounds) {
    final radius = calc.distance(bounds.northEast, bounds.southWest) / 2;
    return radius.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              body: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: fobsCenter,
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
                    MaterialPageRoute(builder: (context) => FobCreateView(
                      camera: widget.camera,
                      initialLocation: mapController.camera.center,
                      initialZoom: mapController.camera.zoom
                    )),
                  ).then((_) => {
                    fetchMarkers(
                      mapController.camera.center,
                      getMapRadius(mapController.camera.visibleBounds)
                    )
                  });
                },
                label: const Text("Contribute"),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
          if (fobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: FobCardListView(
                fobs: fobs,
                fobsCenter: fobsCenter,
                camera: widget.camera,
                settingsController: widget.settingsController,
              ),
            ),
        ],
      )
    );
  }

  @override
  void dispose() {
    // Clean up debounce timer
    debounceTimer?.cancel();
    super.dispose();
  }
}
