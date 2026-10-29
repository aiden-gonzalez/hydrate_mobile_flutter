import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart' as api;
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/toast.dart' as toast;
import 'package:hydrate_mobile_flutter/src/utils/storage.dart';

class AuthService {
  static Future<AuthSuccessResponse?> checkOrRefreshToken(AuthSuccessResponse tokens) async {
    // If no tokens, return null
    if (tokens.isEmpty) {
      return null;
    }

    // If tokens are expired, try to refresh
    if (tokens.isExpired) {
      final newTokens = await refreshToken(tokens.refreshToken, tokens.accessToken);
      return newTokens;
    }

    // Otherwise return valid existing tokens
    return tokens;
  }

  static Future<AuthSuccessResponse?> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await api.login(email, password);
      if (response.statusCode == 200) {
        final tokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
        useTokenStore().setTokens(tokens);
        await writeTokens(getConfiguredStorage(), tokens);
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

  static Future<AuthSuccessResponse?> signup(
      BuildContext context, String username, String email, String password) async {
    try {
      final response = await api.signup(username, email, password);
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      final authResponse = await api.login(email, password);
      if (authResponse.statusCode != 200) {
        throw Exception(authResponse.body);
      }
      final tokens = AuthSuccessResponse.fromJson(jsonDecode(authResponse.body));
      useTokenStore().setTokens(tokens);
      await writeTokens(getConfiguredStorage(), tokens);
      return tokens;
    } catch (e) {
      debugPrint("Error signing up: $e");
      toast.showToast(context, e.toString());
      return null;
    }
  }

  static Future<AuthSuccessResponse?> refreshToken(String refreshToken, String accessToken) async {
    try {
      final response = await api.refreshToken(refreshToken, accessToken);
      if (response.statusCode == 200) {
        final newTokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
        useTokenStore().setTokens(newTokens);
        await writeTokens(getConfiguredStorage(), newTokens);
        return newTokens;
      } else {
        throw Exception("Failed to refresh token");
      }
    } catch (e) {
      debugPrint("Error refreshing token: $e");
      return null;
    }
  }

  // Exchange an emailed reset code for a new password. Signs the user in on success.
  static Future<AuthSuccessResponse?> resetPassword(
      BuildContext context, String code, String newPassword, String confirmPassword) async {
    try {
      final response = await api.resetPassword(code, newPassword, confirmPassword);
      if (response.statusCode != 200) {
        final body = response.body.isEmpty ? null : jsonDecode(response.body);
        throw Exception(body is Map && body['message'] != null ? body['message'] : "Password reset failed");
      }
      final tokens = AuthSuccessResponse.fromJson(jsonDecode(response.body));
      useTokenStore().setTokens(tokens);
      await writeTokens(getConfiguredStorage(), tokens);
      return tokens;
    } catch (e) {
      debugPrint("Error resetting password: $e");
      if (context.mounted) toast.showToast(context, e.toString().replaceFirst("Exception: ", ""));
      return null;
    }
  }

  // Permanently delete the signed in user's account, then sign out. Returns whether it worked.
  static Future<bool> deleteAccount(BuildContext context, String password) async {
    try {
      final tokens = await checkOrRefreshToken(useTokenStore().state);
      if (tokens == null) {
        throw Exception("You need to be signed in to delete your account.");
      }
      final response = await api.deleteAccount(tokens.accessToken, password);
      if (response.statusCode == 401) {
        throw Exception("Incorrect password.");
      } else if (response.statusCode != 200) {
        throw Exception("Couldn't delete your account, please try again.");
      }
      await logout();
      return true;
    } catch (e) {
      debugPrint("Error deleting account: $e");
      if (context.mounted) toast.showToast(context, e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  static Future<void> logout() async {
    useTokenStore().clearTokens();
    await clearTokens(getConfiguredStorage());
  }
}
