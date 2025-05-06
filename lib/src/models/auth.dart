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

class RefreshRequest {
  final String refreshToken;
  final String expiredToken;

  const RefreshRequest({required this.refreshToken, required this.expiredToken});

  Map<String, dynamic> toJson() => {
    'refresh_token': refreshToken,
    'expired_token': expiredToken
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

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
    'expires': expires,
    'username': username
  };

  factory AuthSuccessResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'access_token': String accessToken,
        'refresh_token': String refreshToken,
        'token_type': String tokenType,
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

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now > expires;
  }

  bool get isEmpty {
    return accessToken.isEmpty && refreshToken.isEmpty && tokenType.isEmpty && expires == 0 && username.isEmpty;
  }

  static AuthSuccessResponse empty() {
    return AuthSuccessResponse(
      accessToken: "",
      refreshToken: "",
      tokenType: "",
      expires: 0,
      username: "");
  }
}

class HashedPassword {
  final String hashPass;
  final String hashSalt;

  const HashedPassword({required this.hashPass, required this.hashSalt});

  factory HashedPassword.fromJson(Map<String, dynamic> json) {
    return HashedPassword(
      hashPass: json['hash_pass'] as String,
      hashSalt: json['hash_salt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'hash_pass': hashPass,
    'hash_salt': hashSalt,
  };
}

class Profile {
  final String fullName;
  final String pictureLink;

  const Profile({required this.fullName, required this.pictureLink});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'] as String,
      pictureLink: json['picture_link'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'picture_link': pictureLink,
  };
}

class User {
  final String id;
  final String username;
  final String email;
  final HashedPassword hashedPassword;
  final Profile profile;
  final int createdAt;
  final int updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.hashedPassword,
    required this.profile,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      hashedPassword: HashedPassword.fromJson(json['hashed_password'] as Map<String, dynamic>),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'hashed_password': hashedPassword.toJson(),
    'profile': profile.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
