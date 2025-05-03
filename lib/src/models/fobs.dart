import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/models/pictures.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;

class FountainCreationDetails {
  final String name;
  final Location location;
  final FountainInfo info;

  const FountainCreationDetails({required this.name, required this.location, required this.info});

  Map<String, dynamic> toJson() =>
      {'name': name, 'location': location.toJson(), 'info': info.toJson()};
}

class FountainInfo {
  final bool bottleFiller;

  const FountainInfo({required this.bottleFiller});

  Map<String, dynamic> toJson() => {'bottle_filler': bottleFiller};

  factory FountainInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'bottle_filler': bool bottleFiller} => FountainInfo(bottleFiller: bottleFiller),
      _ => throw const FormatException('Failed to decode JSON FountainInfo!')
    };
  }
}

class BathroomInfo {
  final String gender;
  final bool sanitaryProducts;
  final bool babyChanger;

  const BathroomInfo(
      {required this.gender, required this.sanitaryProducts, required this.babyChanger});

  Map<String, dynamic> toJson() =>
      {'gender': gender, 'sanitary_products': sanitaryProducts, 'baby_changer': babyChanger};

  factory BathroomInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'gender': String gender,
        'sanitary_products': bool sanitaryProducts,
        'baby_changer': bool babyChanger
      } =>
        BathroomInfo(gender: gender, sanitaryProducts: sanitaryProducts, babyChanger: babyChanger),
      _ => throw const FormatException('Failed to decode JSON BathroomInfo!')
    };
  }
}

abstract class Fob {
  final String id;
  final String name;
  final String userId;
  final int createdAt;
  final int updatedAt;
  final Location location;
  final dynamic info; // Can be FountainInfo or BathroomInfo
  final double? averageRating;

  const Fob(
      {required this.id,
      required this.name,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.info,
      this.averageRating,
      required this.location});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user_id': userId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'average_rating': averageRating,
        'location': location.toJson(),
        'info': info.toJson()
      };
  
  bool isFountain() => id.startsWith(constants.fountainIdPrefix);
  bool isBathroom() => id.startsWith(constants.bathroomIdPrefix);
}

class FobWithDetails {
  final Fob fob;
  final List<Rating> ratings;
  final List<Picture> pictures;

  const FobWithDetails({
    required this.fob,
    required this.ratings,
    required this.pictures,
  });

  Map<String, dynamic> toJson() => {
        'fob': fob.toJson(),
        'ratings': ratings.map((rating) => rating.toJson()).toList(),
        'pictures': pictures.map((picture) => picture.toJson()).toList(),
      };

  factory FobWithDetails.fromJson(Map<String, dynamic> json) {
    return FobWithDetails(
      fob: Fob.fromJson(json['fob']),
      ratings: (json['ratings'] as List<dynamic>)
          .map((rating) => Rating.fromJson(rating as Map<String, dynamic>))
          .toList(),
      pictures: (json['pictures'] as List<dynamic>)
          .map((picture) => Picture.fromJson(picture as Map<String, dynamic>))
          .toList(),
    );
  }
}
