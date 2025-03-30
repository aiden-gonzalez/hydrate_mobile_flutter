import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart' as api;
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;

class AuthService {
  static Future<AuthSuccessResponse> getStoredTokens(BuildContext context) async {
    return useTokenStore().select(context, (state) => state);
  }

  static Future<AuthSuccessResponse?> login(BuildContext context, String email, String password) async {
    try {
      final response = await api.login(email, password);
      if (response.statusCode == 200) {
        final tokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
        useTokenStore().setTokens(tokens);
        return tokens;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Error logging in: $e");
      toast.showToast(context, e.toString());
      return null;
    }
  }

  static Future<AuthSuccessResponse?> signup(String username, String email, String password) async {
    try {
      final response = await api.signup(username, email, password);
      if (response.statusCode == 200) {
        final tokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
        useTokenStore().setTokens(tokens);
        return tokens;
      } else {
        throw Exception("Failed to signup");
      }
    } catch (e) {
      debugPrint("Error signing up: $e");
      return null;
    }
  }

  static Future<AuthSuccessResponse?> refreshToken(String refreshToken, String accessToken) async {
    try {
      final response = await api.refreshToken(refreshToken, accessToken);
      if (response.statusCode == 200) {
        final newTokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
        useTokenStore().setTokens(newTokens);
        return newTokens;
      } else {
        throw Exception("Failed to refresh token");
      }
    } catch (e) {
      debugPrint("Error refreshing token: $e");
      return null;
    }
  }
}
