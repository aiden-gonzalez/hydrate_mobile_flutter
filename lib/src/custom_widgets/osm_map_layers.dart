import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

// OpenStreetMap tile layer. The tile usage policy requires a real user agent
// identifying the app: https://operations.osmfoundation.org/policies/tiles/
TileLayer osmTileLayer() => TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
  userAgentPackageName: appPackageName,
);

// Attribution is also required by the tile usage policy
Widget osmAttribution() => RichAttributionWidget(
  alignment: AttributionAlignment.bottomLeft,
  attributions: [
    TextSourceAttribution(
      'OpenStreetMap contributors',
      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
    ),
  ],
);
