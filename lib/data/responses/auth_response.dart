import 'package:ismgl/data/models/user_model.dart';

class AuthResponse {
  final String    token;
  final String    refreshToken;
  final int       expiresIn;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token:        json['token']         ?? '',
    refreshToken: json['refresh_token'] ?? '',
    expiresIn:    json['expires_in']    ?? 86400,
    user:         UserModel.fromJson(json['user'] ?? {}),
  );
}