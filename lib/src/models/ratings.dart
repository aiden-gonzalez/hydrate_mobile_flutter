class BathroomRatingDetails {
  final int cleanliness;
  final int decor;
  final int drying;
  final int privacy;
  final int washing;

  const BathroomRatingDetails({
    required this.cleanliness,
    required this.decor,
    required this.drying,
    required this.privacy,
    required this.washing,
  });

  Map<String, dynamic> toJson() => {
        'cleanliness': cleanliness,
        'decor': decor,
        'drying': drying,
        'privacy': privacy,
        'washing': washing,
      };

  factory BathroomRatingDetails.fromJson(Map<String, dynamic> json) {
    return BathroomRatingDetails(
      cleanliness: json['cleanliness'],
      decor: json['decor'],
      drying: json['drying'],
      privacy: json['privacy'],
      washing: json['washing'],
    );
  }
}

class FountainRatingDetails {
  final int pressure;
  final int taste;
  final int temperature;

  const FountainRatingDetails({
    required this.pressure,
    required this.taste,
    required this.temperature,
  });

  Map<String, dynamic> toJson() => {
        'pressure': pressure,
        'taste': taste,
        'temperature': temperature,
      };

  factory FountainRatingDetails.fromJson(Map<String, dynamic> json) {
    return FountainRatingDetails(
      pressure: json['pressure'],
      taste: json['taste'],
      temperature: json['temperature'],
    );
  }
}

class Rating {
  final String id;
  final String fobId;
  final String userId;
  final dynamic details; // Can be FountainRatingDetails or BathroomRatingDetails
  final int? createdAt;
  final int? updatedAt;

  const Rating({
    required this.id,
    required this.fobId,
    required this.userId,
    required this.details,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fob_id': fobId,
        'user_id': userId,
        'details': details.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Rating.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'];
    final details = detailsJson.containsKey('cleanliness')
        ? BathroomRatingDetails.fromJson(detailsJson)
        : FountainRatingDetails.fromJson(detailsJson);

    return Rating(
      id: json['id'],
      fobId: json['fob_id'],
      userId: json['user_id'],
      details: details,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
