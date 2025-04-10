class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {
    'latitude': lat,
    'longitude': lng,
  };

  factory Location.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'latitude': double latitude,
        'longitude': double longitude
      } =>
        Location(lat: latitude, lng: longitude),
      _ => throw const FormatException('Failed to decode JSON Location!')
    };
  }

  @override
  String toString() {
    return 'Location(lat: $lat, lng: $lng)';
  }
}
