import 'dart:convert';
import 'package:cbook_dt/feature/authentication/presentation/forgot_password/model/forget_password_response_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordProvider with ChangeNotifier {
  bool isLoading = false;
  ForgotPasswordResponse? responseModel;

  Future<bool> sendForgotPasswordRequest(String email) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse("${AppUrl.baseurl}forgot/password?email=$email");

    try {
      final request = http.Request('POST', url);
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        responseModel = ForgotPasswordResponse.fromJson(jsonDecode(responseBody));
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }



  ///update password 
  Future<bool> updatePassword({
  required int userId,
  required String email,
  required String password,
  required String confirmed,
}) async {
  final url = Uri.parse(
    '${AppUrl.baseurl}forgot/password/update'
    '?user_id=$userId&email=$email&password=$password&confirmed=$confirmed',
  );

  try {
    print("Sending password update request: $url");

    final request = http.Request('POST', url);
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      print("Password update success: $responseBody");
      return true;
    } else {
      print("Password update failed [${streamedResponse.statusCode}]: $responseBody");
      return false;
    }
  } catch (e) {
    print("Error updating password: $e");
    return false;
  }
}

    

}
