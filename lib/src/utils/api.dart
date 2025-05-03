import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/utils/env.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

// AUTH ENDPOINTS

Future<http.Response> login(String email, String password) {
  AuthRequest request = AuthRequest(email: email, password: password);
  return apiRequest(HttpMethod.post, "auth", body: request);
}

Future<http.Response> signup(String username, String email, String password) {
  SignupRequest request =
      SignupRequest(username: username, authRequest: AuthRequest(email: email, password: password));
  return apiRequest(HttpMethod.post, "signup", body: request);
}

Future<http.Response> refreshToken(String refreshToken, String expiredToken) {
  RefreshRequest request = RefreshRequest(refreshToken: refreshToken, expiredToken: expiredToken);
  return apiRequest(HttpMethod.post, "auth/refresh", body: request);
}

// TODO implement this endpoint in the backend
Future<http.Response> sendPasswordResetEmail(String email) {
  Map<String, String> request = {'email': email};
  return apiRequest(HttpMethod.post, "password-reset", body: request);
}

// FOB ENDPOINTS
Future<http.Response> createFob(String token, FobCreationDetails fobCreationDetails) {
  Map<String, dynamic> request = fobCreationDetails.toJson();
  return apiRequest(HttpMethod.post, "fobs", body: request, token: token);
}

Future<List<Fob>> getFobsInArea(String token, LatLng location, {int radiusInMeters = 1000}) async {
  final params = {
    'latitude': location.latitude.toString(),
    'longitude': location.longitude.toString(),
    'radius': radiusInMeters.toString()
  };

  final fobsJson = await apiRequest(HttpMethod.get, "fobs", params: params, token: token);

  final decodedFobs = 
    (jsonDecode(fobsJson.body) as List)
    .map((f) => Fob.fromJson(f))
    .toList();

  return decodedFobs;
}

Future<FobWithDetails> getFobWithDetails(String token, String fobId) async {
  final fobDetailsJson = await apiRequest(HttpMethod.get, "fobs/$fobId/details", token: token);

  final decodedFobWithDetails = jsonDecode(fobDetailsJson.body) as Map<String, dynamic>;

  return FobWithDetails.fromJson(decodedFobWithDetails);
}

enum HttpMethod { get, post }

Future<http.Response> apiRequest(HttpMethod method, String path,
    {Map<String, String>? params, Object? body, String? token}) {
  // Set up URI with path and params
  Uri uri = Uri.parse("${Environment.backendApiUrl()}/api/$path").replace(queryParameters: params ?? {});
  debugPrint(uri.toString());

  // JSON encode body
  String jsonBody = jsonEncode(body);

  return switch (method) {
    HttpMethod.get => http.get(uri, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token ?? ""
      }),
    HttpMethod.post => http.post(uri,
        headers: <String, String>{'Content-Type': 'application/json', 'Authorization': token ?? ""},
        body: jsonBody)
  };
}
