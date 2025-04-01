import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';

class TokenStore extends Store<AuthSuccessResponse> {
  static final AuthSuccessResponse emptyResponse = AuthSuccessResponse(
      accessToken: "",
      refreshToken: "",
      tokenType: "",
      expires: 0,
      username: "");

  TokenStore()
      : super(emptyResponse);

  void setTokens(AuthSuccessResponse response) => set(response);
  void clearTokens() => set(emptyResponse);
}

TokenStore useTokenStore() => create(() => TokenStore());
