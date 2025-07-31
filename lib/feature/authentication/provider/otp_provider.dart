import 'dart:convert';
import 'package:cbook_dt/feature/authentication/model/otp_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Provider for API Call
class VerificationProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  VerificationResponse? response;

  Future<void> verifyOtp(int userId, String code) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse(
        'https://commercebook.site/api/v1/verification/code?user_id=$userId&code=$code');
    try {
      final response = await http.post(url);
      final data = json.decode(response.body);
      debugPrint("Decoded response data: $data");
      if (response.statusCode == 200 && data['success']) {
        this.response = VerificationResponse.fromJson(data);

        debugPrint("✅ ✅ Verification Successful: ${this.response!.message}");
      } else {
        errorMessage = data['message'] ?? 'Verification failed';
        debugPrint("❌📛Error: $errorMessage");
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      debugPrint("⚠️ ❌📛Exception: $errorMessage");
    }
    isLoading = false;
    notifyListeners();
  }
}
