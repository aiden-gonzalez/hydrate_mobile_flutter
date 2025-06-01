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
  final List<Fob> fountains;
  final List<Fob> bathrooms;
  final List<Rating> fountainRatings;
  final List<Rating> bathroomRatings;
  final List<Picture> pictures;

  const UserContributions({
    required this.bathrooms,
    required this.fountains,
    required this.fountainRatings,
    required this.bathroomRatings,
    required this.pictures
  });

  List<Rating> getSortedRatings() {
    final ratings = [...fountainRatings, ...bathroomRatings];
    ratings.sort((a, b) => (a.createdAt ?? 0) > (b.createdAt ?? 0) ? -1 : 1);
    return ratings;
  }

  factory UserContributions.fromJson(Map<String, dynamic> json) {
    return UserContributions(
      fountains: (json['fountains'] as List)
          .map((fountain) => Fob.fromJson(fountain))
          .toList(),
      bathrooms: (json['bathrooms'] as List)
          .map((bathroom) => Fob.fromJson(bathroom))
          .toList(),
      fountainRatings: (json['fountain_ratings'] as List)
          .map((rating) => Rating.fromJson(rating))
          .toList(),
      bathroomRatings: (json['bathroom_ratings'] as List)
          .map((rating) => Rating.fromJson(rating))
          .toList(),
      pictures: json['pictures'] as List<Picture>
    );
  }

  Map<String, dynamic> toJson() => {
    'fountains': fountains,
    'bathrooms': bathrooms,
    'fountain_ratings': fountainRatings,
    'bathroom_ratings': bathroomRatings,
    'pictures': pictures
  };
}
