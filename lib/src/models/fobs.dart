import 'package:hydrate_mobile_flutter/src/models/misc.dart';

class FountainInfo {
  final String name;
  final Location location;
  final bool bottleFiller;

  const FountainInfo({
    required this.name,
    required this.location,
    required this.bottleFiller
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location.toJson(),
    'bottle_filler': bottleFiller
  };

  factory FountainInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'name': String name,
        'location': Map<String, dynamic> location,
        'bottle_filler': bool bottleFiller
      } =>
        FountainInfo(name: name, location: Location.fromJson(location), bottleFiller: bottleFiller),
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
      required super.userId});

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
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt,
      } =>
        Fountain(
            info: FountainInfo.fromJson(fountainInfo),
            id: id,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt),
      _ => throw const FormatException('Failed to decode JSON Fountain!')
    };
  }
}

class BathroomInfo {
  final String name;
  final Location location;
  final String gender;
  final bool sanitaryProducts;
  final bool babyChanger;

  const BathroomInfo({
    required this.name,
    required this.location,
    required this.gender,
    required this.sanitaryProducts,
    required this.babyChanger
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location.toJson(),
    'gender': gender,
    'sanitary_products': sanitaryProducts,
    'baby_changer': babyChanger
  };

  factory BathroomInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'name': String name,
        'location': Map<String, dynamic> location,
        'gender': String gender,
        'sanitary_products': bool sanitaryProducts,
        'baby_changer': bool babyChanger
      } =>
        BathroomInfo(name: name, location: Location.fromJson(location), gender: gender, sanitaryProducts: sanitaryProducts, babyChanger: babyChanger),
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
        'user_id': String userId,
        'created_at': int createdAt,
        'updated_at': int updatedAt
      } =>
        Bathroom(
            info: BathroomInfo.fromJson(bathroomInfo),
            id: id,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt),
      _ => throw const FormatException('Failed to decode JSON Bathroom!')
    };
  }
}

abstract class Fob {
  final String id;
  final String userId;
  final int createdAt;
  final int updatedAt;

  const Fob(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt
  };
}
