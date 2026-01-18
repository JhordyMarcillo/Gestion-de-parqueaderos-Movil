import 'dart:convert';
import 'dart:async';
import 'dart:io';
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
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');


    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final authResponse = authResponseFromJson(response.body);
        _token = authResponse.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_email', authResponse.email);

        String rolSafe = authResponse.rol ?? "USER";
        await prefs.setString('user_role', rolSafe);

        return true;
      } else {
        return false;
      }

    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    } finally {
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