import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:hydrate_mobile_flutter/src/models/auth.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';

// Store for backend access tokens
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

// Store for FOBs
class FobStore extends Store<Fob> {
  static final Fob emptyFob = Fountain(
      id: "",
      createdAt: 0,
      updatedAt: 0,
      name: "",
      location: Location(lat: 0, lng: 0),
      userId: "",
      info: FountainInfo(bottleFiller: false));

  FobStore()
      : super(emptyFob);

  void setFob(Fob fob) => set(fob);
  void clearFob() => set(emptyFob);
}
