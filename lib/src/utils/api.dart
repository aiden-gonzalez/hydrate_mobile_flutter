import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/utils/env.dart';

enum HttpMethod { get, post, put, delete }

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

Future<http.Response> checkToken(String token) {
  return apiRequest(HttpMethod.get, "auth", token: token);
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

  final decodedFobs = (jsonDecode(fobsJson.body) as List).map((f) => Fob.fromJson(f)).toList();

  return decodedFobs;
}

Future<FobWithDetails> getFobWithDetails(String token, String fobId) async {
  final fobDetailsJson = await apiRequest(HttpMethod.get, "fobs/$fobId/details", token: token);

  final decodedFobWithDetails = jsonDecode(fobDetailsJson.body) as Map<String, dynamic>;

  return FobWithDetails.fromJson(decodedFobWithDetails);
}

// RATING ENDPOINTS

Future<http.Response> createRating(String token, String fobId, dynamic ratingDetails) {
  Map<String, dynamic> request = ratingDetails.toJson();

  return apiRequest(HttpMethod.post, "fobs/$fobId/ratings", body: request, token: token);
}

// PICTURE ENDPOINTS

Future<void> pictureUploadFlow(String token, String fobId, File imageFile) async {
  // First request a temporary upload URL from the backend
  final uploadUrlResponse = await getUploadUrl(token, fobId);

  if (uploadUrlResponse.statusCode != 200) {
    return Future.error("Failed to get upload URL: ${uploadUrlResponse.body}");
  }

  final signedPictureUrl =
      PictureSignedUrl.fromJson(jsonDecode(uploadUrlResponse.body) as Map<String, dynamic>);

  // Now upload the image using that URL
  final uploadResponse = await uploadPicture(signedPictureUrl.signedUrl, imageFile);

  if (uploadResponse.statusCode != 200) {
    // Try to tell the server to delete the picture
    await deletePicture(token, signedPictureUrl.pictureId);
    return Future.error("Failed to upload image: ${await uploadResponse.stream.bytesToString()}");
  }

  // Finally, tell the server the picture was successfully uploaded
  final updateResponse = await updatePictureStatus(token, signedPictureUrl.pictureId, false);

  if (updateResponse.statusCode != 200) {
    return Future.error("Failed to update picture status: ${updateResponse.body}");
  }
}

Future<http.Response> getUploadUrl(String token, String fobId) {
  return apiRequest(HttpMethod.get, "fobs/$fobId/pictures/upload", token: token);
}

Future<http.Response> updatePictureStatus(String token, String pictureId, bool pending) {
  Map<String, dynamic> request = {'pending': pending};

  return apiRequest(HttpMethod.put, "pictures/$pictureId", body: request, token: token);
}

Future<http.Response> deletePicture(String token, String pictureId) {
  return apiRequest(HttpMethod.delete, "pictures/$pictureId", token: token);
}

// PROFILE ENDPOINTS

Future<http.Response> getOwnUserContributions(String token) async {
  return await apiRequest(HttpMethod.get, "me/contributions", token: token);
}

Future<http.Response> getUserContributions(String token, String username) async {
  return await apiRequest(HttpMethod.get, "profiles/$username/contributions", token: token);
}

// API UTILS

Future<http.StreamedResponse> uploadPicture(String uploadUrl, File imageFile) async {
  var request = http.Request('PUT', Uri.parse(uploadUrl));
  request.headers.addAll({'Content-Type': 'application/octet-stream'});
  request.bodyBytes = await imageFile.readAsBytes();

  return await request.send();
}

Future<http.Response> apiRequest(HttpMethod method, String path,
    {Map<String, String>? params, Object? body, String? token}) {
  // Set up URI with path and params
  Uri uri = Uri.parse("${Environment.backendApiUrl()}/api/$path");
  if (params != null) {
    uri = uri.replace(queryParameters: params);
  }
  debugPrint(uri.toString());

  // JSON encode body
  String jsonBody = jsonEncode(body);

  // Set up headers
  Map<String, String> headers = {'Content-Type': 'application/json'};
  if (token != null) {
    headers['Authorization'] = token;
  }

  return switch (method) {
    HttpMethod.get => http.get(uri, headers: headers),
    HttpMethod.post => http.post(uri, headers: headers, body: jsonBody),
    HttpMethod.put => http.put(uri, headers: headers, body: jsonBody),
    HttpMethod.delete => http.delete(uri, headers: headers)
  };
}
