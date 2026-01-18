import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/parking_model.dart';

class ParkingProvider extends ChangeNotifier {
  List<Espacio> _espacios = [];
  List<Espacio> get espacios => _espacios;

  bool _isLoading = false; // Empezamos en false para ver si el botón funciona
  bool get isLoading => _isLoading;

  // Método simplificado: Solo carga datos, no abre sockets
  Future<void> cargarEspacios({bool checkBackground = false}) async {

    if (!checkBackground){
      _isLoading = false;
      notifyListeners();
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.parkingEndpoint}/todos/1');

    try {
      // 2. Obtener Token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      print("2. Token recuperado: ${token != null ? 'SI (termina en ...${token.substring(token.length - 10)})' : 'NO'}");

      if (token == null) {
        print("ERROR CRÍTICO: No hay token. Haz login de nuevo.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 3. Petición HTTP
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // 4. Convertir JSON a Lista
        _espacios = espacioListFromJson(response.body);

      }
    } catch (e) {
      print("ERROR DE CONEXIÓN O PARSEO: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}