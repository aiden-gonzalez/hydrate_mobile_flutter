class AuthRequest {
  final String email;
  final String password;

  const AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'user_credentials': {'email': email, 'password': password}
  };
}

class SignupRequest {
  final String username;
  final AuthRequest authRequest;

  const SignupRequest({required this.username, required this.authRequest});
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'user_credentials': authRequest.toJson()['user_credentials']
  };
}

class AuthSuccessResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expires;
  final String username;

  const AuthSuccessResponse(
      {required this.accessToken,
      required this.refreshToken,
      required this.tokenType,
      required this.expires,
      required this.username});

  factory AuthSuccessResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'accessToken': String accessToken,
        'refreshToken': String refreshToken,
        'tokenType': String tokenType,
        'expires': int expires,
        'username': String username
      } =>
        AuthSuccessResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expires: expires,
            username: username),
      _ => throw const FormatException('Failed to decode JSON AuthSuccessResponse!')
    };
  }
}
