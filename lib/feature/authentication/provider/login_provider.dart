import 'dart:convert';
 
import 'package:cbook_dt/feature/authentication/model/login_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  LoginProvider() {
    checkLoginStatus(); 
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.containsKey('token'); 
    notifyListeners();
  }

  Future<void> loginUser(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://commercebook.site/api/v1/login?email=$email&password=$password');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _loginResponse = LoginResponse.fromJson(responseData);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _loginResponse!.data.token);
        await prefs.setInt('user_id', _loginResponse!.data.id);

        _isLoggedIn = true;
        notifyListeners();
      } else {
        debugPrint('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isLoggedIn = false;
    notifyListeners();
  }
}
