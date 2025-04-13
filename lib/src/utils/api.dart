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
Future<List<Fob>> getFobsInArea(String token, LatLng location,
    {double radiusInMeters = 1000}) async {
  final params = {
    'latitude': location.latitude.toString(),
    'longitude': location.longitude.toString(),
    'radius': radiusInMeters.toString()
  };

  // Wait for both calls to complete
  final fobRequests = await Future.wait([
    apiRequest(HttpMethod.get, "fountains", params: params, token: token),
    apiRequest(HttpMethod.get, "bathrooms", params: params, token: token)
  ]);

  final fountains = jsonDecode(fobRequests[0].body) as List<Fountain>;
  final bathrooms = jsonDecode(fobRequests[1].body) as List<Bathroom>;

  return [...fountains, ...bathrooms];
}

enum HttpMethod { get, post }

Future<http.Response> apiRequest(HttpMethod method, String path,
    {Map<String, String>? params, Object? body, String? token}) {
  Uri uri = Uri.parse("${Environment.backendApiUrl()}/api/$path");
  uri.queryParameters.addAll(params ?? {});
  debugPrint(uri.toString());
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
