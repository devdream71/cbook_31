import 'dart:convert';
 
import 'package:cbook_dt/feature/authentication/model/login_model.dart';
import 'package:cbook_dt/utils/url.dart';
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
        '${AppUrl.baseurl}login?email=$email&password=$password');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      _loginResponse = LoginResponse.fromJson(responseData);

      // ✅ Save token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _loginResponse!.data.token);
      await prefs.setInt('user_id', _loginResponse!.data.id);
      await prefs.setInt('company_id', _loginResponse!.data.companyId);
      // await prefs.setInt('company_name', _loginResponse!.data.companyName);
      await prefs.setString('company_name', _loginResponse!.data.companyName ?? '');


      // ✅ Save cookie from header
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        await prefs.setString('cookie', rawCookie);
      }

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



  ///remove token. 
  // Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token');
  //   _isLoggedIn = false;
  //   notifyListeners();
  // }


  Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Clear everything (token, user_id, cookie, etc.)
  await prefs.clear();

  // Reset local states
  _isLoggedIn = false;
  _loginResponse = null;

  notifyListeners();
}
}
