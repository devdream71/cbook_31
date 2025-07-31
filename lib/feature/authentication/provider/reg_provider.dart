import 'dart:convert';
 import 'package:cbook_dt/feature/authentication/model/register_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  static const String baseUrl = "https://commercebook.site/api/v1/register";

  bool _isLoading = false;
  String? _errorMessage;
  RegisterResponse? _registerResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegisterResponse? get registerResponse => _registerResponse;

  Future<RegisterResponse?> registerUser({
    required String name,
    required String email,
    required String phone,
    required int countryId,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "country_id": countryId,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      debugPrint("API Response: ${response.body}");

      final jsonData = jsonDecode(response.body);
      _registerResponse = RegisterResponse.fromJson(jsonData);
      
      return _registerResponse;
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}




