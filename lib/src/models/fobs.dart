import 'package:hydrate_mobile_flutter/src/models/misc.dart';

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

class Fountain extends Fob {
  final FountainInfo info;

  const Fountain(
      {required this.info,
      required super.id,
      required super.createdAt,
      required super.updatedAt,
      required super.name,
      required super.location,
      super.averageRating,
      required super.userId});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> fob = super.toJson();
    fob['info'] = info.toJson();
    return fob;
  }

  factory Fountain.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'info': Map<String, dynamic> fountainInfo,
        'id': String id,
        'name': String name,
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt,
        'location': Map<String, dynamic> location,
        'average_rating': double? averageRating // Optional property
      } =>
        Fountain(
            info: FountainInfo.fromJson(fountainInfo),
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            averageRating: averageRating,
            location: Location.fromJson(location)),
      {
        'info': Map<String, dynamic> fountainInfo,
        'id': String id,
        'name': String name,
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt,
        'location': Map<String, dynamic> location
      } =>
        Fountain(
            info: FountainInfo.fromJson(fountainInfo),
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            averageRating: null, // Default to null if missing
            location: Location.fromJson(location)),
      _ => throw const FormatException('Failed to decode JSON Fountain!')
    };
  }

  static Fountain empty() {
    return Fountain(
        id: "",
        createdAt: 0,
        updatedAt: 0,
        name: "",
        location: Location(lat: 0, lng: 0),
        userId: "",
        averageRating: 0,
        info: FountainInfo(bottleFiller: false));
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

class Bathroom extends Fob {
  final BathroomInfo info;

  const Bathroom(
      {required this.info,
      required super.id,
      required super.createdAt,
      required super.updatedAt,
      required super.name,
      required super.location,
      super.averageRating,
      required super.userId});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> fob = super.toJson();
    fob['info'] = info.toJson();
    return fob;
  }

  factory Bathroom.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'info': Map<String, dynamic> bathroomInfo,
        'id': String id,
        'name': String name,
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt,
        'location': Map<String, dynamic> location,
        'average_rating': double? averageRating // Optional property
      } =>
        Bathroom(
            info: BathroomInfo.fromJson(bathroomInfo),
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            averageRating: averageRating,
            location: Location.fromJson(location)),
      {
        'info': Map<String, dynamic> bathroomInfo,
        'id': String id,
        'name': String name,
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt,
        'location': Map<String, dynamic> location
      } =>
        Bathroom(
            info: BathroomInfo.fromJson(bathroomInfo),
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            averageRating: null, // Default to null if missing
            location: Location.fromJson(location)),
      _ => throw const FormatException('Failed to decode JSON Bathroom!')
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
  final double? averageRating;

  const Fob(
      {required this.id,
      required this.name,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      this.averageRating,
      required this.location});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user_id': userId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'average_rating': averageRating,
        'location': location.toJson()
      };
  
  bool isFountain() => this is Fountain;
  bool isBathroom() => this is Bathroom;
}
