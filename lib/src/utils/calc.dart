import 'dart:math';
import 'package:latlong2/latlong.dart';

double distance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371000; // Earth's radius in meters

  final double deltaLat = point2.latitudeInRad - point1.latitudeInRad;
  final double deltaLon = point2.longitudeInRad - point1.longitudeInRad;

  final double a = pow(sin(deltaLat / 2), 2) + (cos(point1.latitudeInRad) * cos(point2.latitudeInRad)) * pow(sin(deltaLon / 2), 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}