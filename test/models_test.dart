import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';

// JSON shaped like the backend's GET /api/fobs/{id}/details response
Map<String, dynamic> fobJson({double latitude = 40.4237, num longitude = -86.9212}) => {
  'id': 'fount_123',
  'user_id': 'user_123',
  'name': 'Library fountain',
  'location': {'latitude': latitude, 'longitude': longitude},
  'info': {'bottle_filler': true},
  'created_at': 1,
  'updated_at': 2,
  'average_rating': 4.5,
};

Map<String, dynamic> publicUserJson() => {
  'id': 'user_456',
  'username': 'rater',
  'profile': {'full_name': '', 'picture_link': 'https://example.com/pic.jpg'},
  'created_at': 1,
  'updated_at': 2,
};

void main() {
  group('User', () {
    test('parses users without an email (other users are returned without one)', () {
      final user = User.fromJson(publicUserJson());
      expect(user.username, 'rater');
      expect(user.email, isNull);
      expect(user.toJson().containsKey('email'), isFalse);
    });

    test('keeps the email when present', () {
      final user = User.fromJson({...publicUserJson(), 'email': 'me@example.com'});
      expect(user.email, 'me@example.com');
    });
  });

  group('FobWithDetails', () {
    Map<String, dynamic> detailsJson({Map<String, dynamic>? user}) => {
      'fob': fobJson(),
      if (user != null) 'user': user,
      'pictures': [],
      'ratingsWithDetails': [
        {
          'rating': {
            'id': 'fountrate_1',
            'fob_id': 'fount_123',
            'user_id': 'user_456',
            'details': {'pressure': 3, 'taste': 4, 'temperature': 5},
            'created_at': 1,
            'updated_at': 2,
          },
          'user': publicUserJson(),
        }
      ],
    };

    test('parses details with a creator', () {
      final details = FobWithDetails.fromJson(detailsJson(user: publicUserJson()));
      expect(details.user?.username, 'rater');
      expect(details.ratingsWithDetails.single.user.email, isNull);
    });

    test('parses details when the creator deleted their account', () {
      final details = FobWithDetails.fromJson(detailsJson());
      expect(details.user, isNull);
      expect(details.fob.name, 'Library fountain');
    });
  });

  group('Location', () {
    test('accepts whole number coordinates', () {
      final location = Location.fromJson({'latitude': 40, 'longitude': -86});
      expect(location.lat, 40.0);
      expect(location.lng, -86.0);
    });

    test('parses a fob with an integer coordinate', () {
      final fob = Fob.fromJson(fobJson(longitude: -87));
      expect(fob.location.lng, -87.0);
    });
  });
}
