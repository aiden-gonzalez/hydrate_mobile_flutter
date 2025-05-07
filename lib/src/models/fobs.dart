import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;

enum FobType {
  fountain,
  bathroom,
}

class FobCreationDetails {
  final FobType type;
  final String name;
  final Location location;
  final dynamic info; // Can be FountainInfo or BathroomInfo

  const FobCreationDetails({
    required this.type,
    required this.name,
    required this.location,
    required this.info});

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'name': name,
    'location': location.toJson(),
    'info': info.toJson()
  };
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

class Fob {
  final String id;
  final String name;
  final String userId;
  final int createdAt;
  final int updatedAt;
  final Location location;
  final dynamic info; // Can be FountainInfo or BathroomInfo
  final num? averageRating;

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

  factory Fob.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final info = json.containsKey('info')
        ? (id.startsWith(constants.fountainIdPrefix)
            ? FountainInfo.fromJson(json['info'] as Map<String, dynamic>)
            : id.startsWith(constants.bathroomIdPrefix)
                ? BathroomInfo.fromJson(json['info'] as Map<String, dynamic>)
                : null)
        : null;

    if (info == null) {
      throw const FormatException('Failed to decode JSON Fob!');
    }

    return Fob(
      id: id,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      info: info,
      averageRating: json['average_rating'] as num?,
      location: Location.fromJson(json['location'] as Map<String, dynamic>)
    );
  }

  static Fob empty() {
    return Fob(
      id: '',
      name: '',
      userId: '',
      createdAt: 0,
      updatedAt: 0,
      info: FountainInfo(bottleFiller: false),
      averageRating: null,
      location: Location(lat: 0, lng: 0)
    );
  }
}

class FobWithDetails {
  final Fob fob;
  final User user;
  final List<Picture> pictures;
  final List<RatingWithDetails> ratingsWithDetails;

  const FobWithDetails({
    required this.fob,
    required this.user,
    required this.pictures,
    required this.ratingsWithDetails
  });

  Map<String, dynamic> toJson() => {
        'fob': fob.toJson(),
        'user': user.toJson(),
        'pictures': pictures.map((picture) => picture.toJson()).toList(),
        'ratingsWithDetails': ratingsWithDetails.map((rwd) => rwd.toJson()).toList()
      };

  factory FobWithDetails.fromJson(Map<String, dynamic> json) {
    return FobWithDetails(
      fob: Fob.fromJson(json['fob']),
      user: User.fromJson(json['user']),
      pictures: (json['pictures'] as List<dynamic>)
          .map((picture) => Picture.fromJson(picture as Map<String, dynamic>))
          .toList(),
      ratingsWithDetails: (json['ratingsWithDetails'] as List<dynamic>)
          .map((rwd) => RatingWithDetails.fromJson(rwd as Map<String, dynamic>))
          .toList()
    );
  }
}
