import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/auth_response.dart';

class AuthService {

  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return authResponseFromJson(response.body);
      } else {
        // Manejar errores como 401 (Unauthorized) o 400
        final errorJson = jsonDecode(response.body);
        throw Exception(errorJson['message'] ?? 'Credenciales incorrectas');
      }
    } catch (e) {
      // Error de conexión (servidor apagado, IP incorrecta)
      throw Exception('Error de conexión: $e');
    }
  }
}