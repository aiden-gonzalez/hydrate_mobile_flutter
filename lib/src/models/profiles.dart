import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';

class Profile {
  final String fullName;
  final String pictureLink;

  const Profile({required this.fullName, required this.pictureLink});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'] as String,
      pictureLink: json['picture_link'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'picture_link': pictureLink,
  };
}

class UserContributions {
  final List<Fob> fobs;
  final List<Rating> ratings;
  final List<Picture> pictures;

  const UserContributions({
    required this.fobs,
    required this.ratings,
    required this.pictures
  });

  List<Fob> get fountains => fobs.where((fob) => fob.isFountain()).toList();
  List<Fob> get bathrooms => fobs.where((fob) => fob.isBathroom()).toList();

  factory UserContributions.fromJson(Map<String, dynamic> json) {
    return UserContributions(
      fobs: (json['fobs'] as List)
          .map((fob) => Fob.fromJson(fob))
          .toList(),
      ratings: (json['ratings'] as List)
          .map((rating) => Rating.fromJson(rating))
          .toList(),
      pictures: (json['pictures'] as List)
          .map((picture) => Picture.fromJson(picture))
          .toList()
    );
  }

  Map<String, dynamic> toJson() => {
    'fobs': fobs,
    'ratings': ratings,
    'pictures': pictures
  };
}
