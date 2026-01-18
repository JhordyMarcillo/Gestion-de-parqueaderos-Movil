import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/parking_model.dart';

class ParkingProvider extends ChangeNotifier {
  List<Espacio> _espacios = [];
  List<Espacio> get espacios => _espacios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarEspacios({bool checkBackground = false}) async {

    if (!checkBackground){
      _isLoading = false;
      notifyListeners();
    }

    final url = Uri.parse('${ApiConstants.baseUrl}api/parqueaderos/todos/1');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _espacios = espacioListFromJson(response.body);

      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstadoEspacio(int id, String nuevoEstado) async {
    final url = Uri.parse('${ApiConstants.baseUrl}api/parqueaderos/$id/estado?estado=$nuevoEstado');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("Estado actualizado a $nuevoEstado");
        await cargarEspacios();
        return true;
      } else {
        print("Error al actualizar: ${response.body}");
        return false;
      }
    } catch (e) {
      print("☠Error de conexión: $e");
      return false;
    }
  }
}