import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart';
import 'package:hydrate_mobile_flutter/src/utils/env.dart';

enum HttpMethod { get, post, put, delete }

// AUTH ENDPOINTS

Future<http.Response> login(String email, String password) {
  AuthRequest request = AuthRequest(email: email.trim(), password: password);
  return apiRequest(HttpMethod.post, "auth", body: request);
}

Future<http.Response> signup(String username, String email, String password) {
  SignupRequest request =
      SignupRequest(username: username.trim(), authRequest: AuthRequest(email: email.trim(), password: password));
  return apiRequest(HttpMethod.post, "signup", body: request);
}

Future<http.Response> refreshToken(String refreshToken, String expiredToken) {
  RefreshRequest request = RefreshRequest(refreshToken: refreshToken, expiredToken: expiredToken);
  return apiRequest(HttpMethod.post, "auth/refresh", body: request);
}

Future<http.Response> checkToken(String token) {
  return apiRequest(HttpMethod.get, "auth", token: token);
}

Future<http.Response> sendPasswordResetEmail(String email) {
  Map<String, String> request = {'email': email.trim()};
  return apiRequest(HttpMethod.post, "auth/password-reset/request", body: request);
}

// Returns auth tokens (AuthSuccessResponse) on success
Future<http.Response> resetPassword(String code, String newPassword, String confirmPassword) {
  Map<String, String> request = {
    'token': code,
    'new_password': newPassword,
    'confirm_password': confirmPassword
  };
  return apiRequest(HttpMethod.post, "auth/password-reset/reset", body: request);
}

// Permanently deletes the authenticated user's account
Future<http.Response> deleteAccount(String token, String password) {
  Map<String, String> request = {'password': password};
  return apiRequest(HttpMethod.delete, "me", body: request, token: token);
}

// REPORT ENDPOINTS

enum ReportContentType { fob, picture, user }

enum ReportReason {
  spam("Spam"),
  inappropriate("Inappropriate"),
  offensive("Offensive or abusive"),
  inaccurate("Inaccurate or doesn't exist"),
  other("Other");

  const ReportReason(this.label);
  final String label;
}

// contentId is the fob ID, picture ID, or username of the user being reported
Future<http.Response> reportContent(String token, ReportContentType contentType, String contentId,
    ReportReason reason, {String? details}) {
  Map<String, String> request = {
    'content_type': contentType.name,
    'content_id': contentId,
    'reason': reason.name,
    if (details != null && details.isNotEmpty) 'details': details
  };
  return apiRequest(HttpMethod.post, "reports", body: request, token: token);
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
    // The backend rejects searches wider than this
    'radius': radiusInMeters.clamp(1, maxFobSearchRadiusMeters).toString()
  };

  final fobsJson = await apiRequest(HttpMethod.get, "fobs", params: params, token: token);
  if (fobsJson.statusCode != 200) {
    return Future.error("Failed to get fobs (${fobsJson.statusCode}): ${fobsJson.body}");
  }

  final decodedFobs = (jsonDecode(fobsJson.body) as List).map((f) => Fob.fromJson(f)).toList();

  return decodedFobs;
}

Future<FobWithDetails> getFobWithDetails(String token, String fobId) async {
  final fobDetailsJson = await apiRequest(HttpMethod.get, "fobs/$fobId/details", token: token);

  final decodedFobWithDetails = jsonDecode(fobDetailsJson.body) as Map<String, dynamic>;

  return FobWithDetails.fromJson(decodedFobWithDetails);
}

Future<http.Response> deleteFob(String token, String fobId) {
  return apiRequest(HttpMethod.delete, "fobs/$fobId", token: token);
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
    HttpMethod.delete => http.delete(uri, headers: headers, body: body == null ? null : jsonBody)
  };
}
