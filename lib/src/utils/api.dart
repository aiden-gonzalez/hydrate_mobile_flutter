import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/env.dart';
import 'dart:convert';

Future<http.Response> login(String email, String password) {
  AuthRequest request = AuthRequest(email: email, password: password);
  return postRequest("auth", null, request);
}

Future<http.Response> signup(String username, String email, String password) {
  SignupRequest request = SignupRequest(
    username: username,
    authRequest: AuthRequest(
      email: email,
      password: password
    )
  );
  return postRequest("signup", null, request);
}

Future<http.Response> sendPasswordResetEmail(String email) {
  Map<String, String> request = {'email': email};
  return postRequest("password-reset", null, request);
}

Future<http.Response> postRequest(
    String path, String? token, Object? bodyToEncode) {
  String jsonBody = jsonEncode(bodyToEncode);
  Uri uri = Uri.parse("${Environment.backendApiUrl()}/api/$path");
  debugPrint(uri.toString());
  return http.post(uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token ?? ""
      },
      body: jsonBody);
}
