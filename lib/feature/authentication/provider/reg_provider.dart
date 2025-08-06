import 'dart:convert';
import 'package:cbook_dt/feature/authentication/model/country_response_model.dart';
import 'package:cbook_dt/feature/authentication/model/register_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  ///reg url
  static const String baseUrl = "https://commercebook.site/api/v1/register";

  ///coutry url
  static const String countryUrl =
      "https://commercebook.site/api/v1/country/list";

  bool _isLoading = false;
  String? _errorMessage;
  RegisterResponse? _registerResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegisterResponse? get registerResponse => _registerResponse;

  // Future<RegisterResponse?> registerUser({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required int countryId,
  //   required String password,
  //   required String confirmPassword,
  // }) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "company_name": name,
  //         "email": email,
  //         "phone": phone,
  //         "country_id": 1,
  //         "password": password,
  //         "confirm_password": confirmPassword,
  //       }),
  //     );

  //     debugPrint("API Response: ${response.body}");

  //     final jsonData = jsonDecode(response.body);
  //     _registerResponse = RegisterResponse.fromJson(jsonData);

  //     return _registerResponse;
  //   } catch (e) {
  //     _errorMessage = "An error occurred: $e";
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  //   return null;
  // }

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
          "company_name": name,
          "email": email,
          "phone": phone,
          "country_id": countryId,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      debugPrint("API Response: ${response.body}");
      final jsonData = jsonDecode(response.body);

      // Check if registration was successful
      if (response.statusCode == 200 && jsonData["success"] == true) {
        _registerResponse = RegisterResponse.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return _registerResponse;
      } else {
        // Handle validation errors
        if (jsonData.containsKey('data')) {
          final errors = jsonData['data'] as Map<String, dynamic>;
          _errorMessage = errors.entries
              .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
              .join('\n');
        } else {
          _errorMessage = jsonData["message"] ?? "Something went wrong";
        }
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  ///country fetch.
  List<Country> _countries = [];
  List<Country> get countries => _countries;

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(countryUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        CountryResponse countryResponse = CountryResponse.fromJson(data);
        _countries = countryResponse.data;
        notifyListeners();
      } else {
        _errorMessage = "Failed to fetch countries";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      notifyListeners();
    }
  }
}
