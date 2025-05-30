import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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

  LatLng fobsCenter = LatLng(40.429052, -86.913124); // Default center until we get user location
  List<Fob> fobs = []; // Fobs currently fetched for map
  List<Marker> markers = []; // Markers currently on map
  
  Timer? debounceTimer;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Get user location and initialize map
    _getCurrentLocation();
  }

  // Request permission and get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        fetchMarkersForCamera(mapController.camera);
        return;
      }
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoadingLocation = false;
          });
          // Initialize with default location
          fetchMarkersForCamera(mapController.camera);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        // Initialize with default location
        fetchMarkersForCamera(mapController.camera);
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        fobsCenter = userLocation;
        _isLoadingLocation = false;
      });
      
      // Move map to user location and fetch markers
      mapController.move(userLocation, mapController.camera.zoom);
      fetchMarkersForCamera(mapController.camera);
      
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
      // Initialize with default location on error
      fetchMarkersForCamera(mapController.camera);
    }
  }

  // Navigate to user location
  void _navigateToUserLocation() {
    _getCurrentLocation();
  }

  Future<void> fetchMarkersForCamera(MapCamera camera) async {
    return fetchMarkers(
      camera.center,
      getMapRadius(camera.visibleBounds)
    );
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
        fetchMarkersForCamera(mapController.camera);
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
              floatingActionButton: Stack(
                children: [
                  // Left side column with reset rotation and location buttons
                  Positioned(
                    left: 30.0,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Reset rotation button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: FloatingActionButton(
                            heroTag: "resetRotationBtn",
                            onPressed: () {
                              // Reset map rotation to north up (0 degrees)
                              mapController.rotate(0);
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.explore, color: Colors.blue),
                          ),
                        ),
                        // Location button
                        FloatingActionButton(
                          heroTag: "locationBtn",
                          onPressed: _navigateToUserLocation,
                          backgroundColor: Colors.white,
                          child: _isLoadingLocation 
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.my_location, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contribute button - right side (bottom right corner)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: FloatingActionButton.extended(
                      heroTag: "contributeBtn",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FobCreateView(
                            camera: widget.camera,
                            initialLocation: mapController.camera.center,
                            initialZoom: mapController.camera.zoom
                          )),
                        ).then((success) => {
                          if (success != null && success) {
                            fetchMarkersForCamera(mapController.camera)
                          }
                        });
                      },
                      label: const Text("Contribute"),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
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
