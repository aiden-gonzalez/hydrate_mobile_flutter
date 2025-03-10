import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';

class TokenStore extends Store<AuthSuccessResponse> {
  TokenStore()
      : super(AuthSuccessResponse(
            accessToken: "", refreshToken: "", tokenType: "", expires: 0, username: ""));

  void setTokens(AuthSuccessResponse response) => set(response);
}

TokenStore useTokenStore() => create(() => TokenStore());
