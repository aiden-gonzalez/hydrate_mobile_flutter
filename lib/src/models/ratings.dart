import 'package:hydrate_mobile_flutter/src/models/auth.dart';

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

  double get average {
    if (details is BathroomRatingDetails) {
      final bathroomDetails = details as BathroomRatingDetails;
      return (bathroomDetails.cleanliness +
              bathroomDetails.decor +
              bathroomDetails.drying +
              bathroomDetails.privacy +
              bathroomDetails.washing) /
          5.0;
    } else if (details is FountainRatingDetails) {
      final fountainDetails = details as FountainRatingDetails;
      return (fountainDetails.pressure +
              fountainDetails.taste +
              fountainDetails.temperature) /
          3.0;
    }
    return 0.0; // Default case, should not happen
  }

  bool get isFountainRating => details is FountainRatingDetails;
  bool get isBathroomRating => details is BathroomRatingDetails;

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

class RatingWithDetails {
  final Rating rating;
  final User user;

  const RatingWithDetails({
    required this.rating,
    required this.user,
  });

  factory RatingWithDetails.fromJson(Map<String, dynamic> json) {
    return RatingWithDetails(
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'rating': rating.toJson(),
    'user': user.toJson(),
  };
}
