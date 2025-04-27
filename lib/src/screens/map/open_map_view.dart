import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_create_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_detail_view.dart';
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
        fetchMarkers(mapController.camera.center, getMapRadius(mapController.camera.visibleBounds));
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
                    MaterialPageRoute(builder: (context) => FobCreateView(camera: widget.camera, initialLocation: mapController.camera.center, initialZoom: mapController.camera.zoom)),
                  );
                },
                label: const Text("Contribute"),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
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
                            settingsController: widget.settingsController,
                            fobId: fob.id
                          )
                        )
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
                                  index + 1 == fob.averageRating.round()
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
