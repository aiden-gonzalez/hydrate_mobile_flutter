import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';

// Store for backend access tokens
class TokenStore extends Store<AuthSuccessResponse> {
  static final AuthSuccessResponse emptyResponse = AuthSuccessResponse.empty();

  TokenStore() : super(emptyResponse);

  void setTokens(AuthSuccessResponse response) => set(response);
  void clearTokens() => set(emptyResponse);
}

TokenStore useTokenStore() => create(() => TokenStore());

// Store for FOBs
class FobStore extends Store<Fob> {
  static final Fob emptyFob = Fountain.empty();

  FobStore() : super(emptyFob);

  void setFob(Fob fob) => set(fob);
  void clearFob() => set(emptyFob);
}
