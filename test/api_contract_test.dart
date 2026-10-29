// Runs the app's real API client against a running backend, to catch mismatched paths or JSON
// shapes between the two repos. Skipped unless an API URL is given:
//
//   flutter test test/api_contract_test.dart --dart-define=BACKEND_API_URL=http://localhost:3000
//
// Use a local / test backend (it creates and then deletes a throwaway account), with rate
// limiting disabled (RATE_LIMIT_DISABLED=true) if you run it repeatedly.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/models/profiles.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:latlong2/latlong.dart';

const apiUrl = String.fromEnvironment('BACKEND_API_URL');

void main() {
  // Note: no TestWidgetsFlutterBinding here, since that blocks real HTTP requests
  final suffix = Random().nextInt(1 << 32).toRadixString(36);
  final username = 'contract_$suffix';
  final email = 'Contract_$suffix@Example.com'; // Mixed case on purpose
  const password = 'contract-test-password';
  // Random spot so repeated runs don't collide on the unique location constraint
  final location = Location(lat: 10 + Random().nextDouble(), lng: 10 + Random().nextDouble());

  late String token;
  late String fobId;

  test('full API flow used by the app', () async {
    // Sign up and log in (login with different email case)
    expect((await signup(username, email, password)).statusCode, 200);
    final loginResponse = await login(email.toLowerCase(), password);
    expect(loginResponse.statusCode, 200);
    final tokens = AuthSuccessResponse.fromJson(jsonDecode(loginResponse.body));
    expect(tokens.username, username);
    token = tokens.accessToken;
    expect((await checkToken(token)).statusCode, 200);

    // Add a fountain and find it on the map
    final created = await createFob(token, FobCreationDetails(
        type: FobType.fountain, name: 'Contract fountain', location: location,
        info: const FountainInfo(bottleFiller: true)));
    expect(created.statusCode, 201, reason: created.body);
    fobId = Fob.fromJson(jsonDecode(created.body)).id;

    final nearby = await getFobsInArea(token, LatLng(location.lat, location.lng), radiusInMeters: 1000000);
    expect(nearby.map((fob) => fob.id), contains(fobId));

    // Rate it and load the details screen data
    final rating = await createRating(token, fobId,
        const FountainRatingDetails(pressure: 4, taste: 5, temperature: 3));
    expect(rating.statusCode, 201, reason: rating.body);

    final details = await getFobWithDetails(token, fobId);
    expect(details.user?.username, username);
    expect(details.user?.email, isNull, reason: 'other users must not see emails');
    expect(details.ratingsWithDetails.single.rating.details, isA<FountainRatingDetails>());

    // Profile contributions
    final contributions = await getOwnUserContributions(token);
    expect(contributions.statusCode, 200, reason: contributions.body);
    expect(UserContributions.fromJson(jsonDecode(contributions.body)).fountains.single.id, fobId);

    // Reporting and password reset requests
    expect((await reportContent(token, ReportContentType.fob, fobId, ReportReason.inaccurate)).statusCode, 201);
    expect((await reportContent(token, ReportContentType.user, username, ReportReason.other, details: 'test')).statusCode, 201);
    expect((await sendPasswordResetEmail(email)).statusCode, 200);
    expect((await resetPassword('NOTACODE', 'newpassword1', 'newpassword1')).statusCode, 400);

    // Clean up: delete the fob, then the account
    expect((await deleteFob(token, fobId)).statusCode, 200);
    expect((await deleteAccount(token, 'wrong password')).statusCode, 401);
    expect((await deleteAccount(token, password)).statusCode, 200);
    expect((await checkToken(token)).statusCode, 401);
  }, skip: apiUrl.isEmpty ? 'Set --dart-define=BACKEND_API_URL to run against a backend' : false);
}
