import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';

FlutterSecureStorage getConfiguredStorage () {
  return FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    )
  );
}

const String tokenKey = "token";

Future<void> writeTokens(FlutterSecureStorage storage, AuthSuccessResponse tokens) async {
  await storage.write(key: tokenKey, value: jsonEncode(tokens));
}

Future<AuthSuccessResponse?> readTokens(FlutterSecureStorage storage) async {
  final String? tokenString = await storage.read(key: tokenKey);
  return tokenString == null ? null : AuthSuccessResponse.fromJson(jsonDecode(tokenString));
}

Future<void> clearTokens(FlutterSecureStorage storage) async {
  await storage.delete(key: tokenKey);
}

Future<void> writeValue(FlutterSecureStorage storage, String key, String value) async {
  await storage.write(key: key, value: value);
}

Future<String?> getValue(FlutterSecureStorage storage, String key) async {
  return await storage.read(key: key);
}

Future<void> deleteValue(FlutterSecureStorage storage, String key) async {
  await storage.delete(key: key);
}
