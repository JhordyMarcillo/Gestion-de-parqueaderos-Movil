import 'dart:convert';

AuthResponse authResponseFromJson(String str) => AuthResponse.fromJson(json.decode(str));

class AuthResponse {
  String token;
  String type;
  int id;
  String email;
  String? rol;

  AuthResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.email,
    this.rol,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json["token"],
    type: json["type"],
    id: json["id"],
    email: json["email"],
    rol: json["rol"] ?? "USER",
  );
}