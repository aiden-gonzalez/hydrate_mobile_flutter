import 'package:latlong2/latlong.dart';

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

  LatLng toLatLng() {
    return LatLng(lat, lng);
  }

  @override
  String toString() {
    return 'Location(lat: $lat, lng: $lng)';
  }
}

class Picture {
  final String id; // Unique ID of picture
  final String fobId; // Fountain or bathroom ID picture is for
  final String url; // Url for picture
  final String userId; // ID of user that created the picture
  final int? createdAt; // Created timestamp. Unix epoch milliseconds
  final int? updatedAt; // Updated timestamp. Unix epoch milliseconds

  Picture({
    required this.id,
    required this.fobId,
    required this.url,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Add a factory constructor to parse from JSON
  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'] as String,
      fobId: json['fob_id'] as String,
      url: json['url'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
    );
  }

  // Add a method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fob_id': fobId,
      'url': url,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PictureSignedUrl {
  final String pictureId; // ID of the picture
  final String signedUrl; // Signed URL to upload the picture
  final int? expires; // Expiration time of the signed URL in Unix epoch milliseconds

  PictureSignedUrl({
    required this.pictureId,
    required this.signedUrl,
    required this.expires
  });

  // Add a factory constructor to parse from JSON
  factory PictureSignedUrl.fromJson(Map<String, dynamic> json) {
    return PictureSignedUrl(
      pictureId: json['picture_id'] as String,
      signedUrl: json['signed_url'] as String,
      expires: json['expires'] as int?
    );
  }

  // Add a method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'picture_id': pictureId,
      'signed_url': signedUrl,
      'expires': expires
    };
  }
}
