import 'dart:convert';
import 'dart:async'; // Necesario para TimeoutException
import 'dart:io';    // Necesario para SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/auth_response.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    // 1. Encendemos el círculo de carga
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
    print("🔵 INTENTANDO CONECTAR A: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5)); // ⏱️ Máximo 5 segundos de espera

      print("🟡 CÓDIGO DE RESPUESTA: ${response.statusCode}");
      print("🟡 CUERPO: ${response.body}");

      if (response.statusCode == 200) {
        // Login Exitoso
        final authResponse = authResponseFromJson(response.body);
        _token = authResponse.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_email', authResponse.email);

        // Guardamos el rol (asegurando que no sea nulo)
        String rolSafe = authResponse.rol ?? "USER";
        await prefs.setString('user_role', rolSafe);

        return true;
      } else {
        // Error del servidor (403, 401, 500, etc.)
        print("🔴 ERROR SERVIDOR: ${response.statusCode}");
        return false;
      }

    } on SocketException {
      print("☠️ ERROR DE RED: No se pudo conectar al servidor. Revisa la IP.");
      return false;
    } on TimeoutException {
      print("⏰ TIMEOUT: El servidor tardó mucho en responder.");
      return false;
    } catch (e) {
      print("☠️ ERROR DESCONOCIDO: $e");
      return false;
    } finally {
      // 3. ESTO SE EJECUTA SIEMPRE, PASE LO QUE PASE
      // Apagamos el círculo de carga
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    notifyListeners();
  }
}