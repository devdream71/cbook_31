import 'dart:convert';
import 'package:cbook_dt/feature/authentication/currency/model/currency_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CurrencyProvider with ChangeNotifier {
  CurrencyModel? _currencyModel;
  bool _isLoading = false;

  CurrencyModel? get currencyModel => _currencyModel;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrency() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final companyId = prefs.getInt('company_id');

    if (token == null || companyId == null) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Token or Company ID not found in SharedPreferences");
    }

    final url = Uri.parse("https://commercebook.site/api/v1/currency?company_id=$companyId");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          _currencyModel = CurrencyModel.fromJson(jsonResponse['data']);
        } else {
          _currencyModel = CurrencyModel(currency: "");
        }
      } else {
        throw Exception("Failed to load currency: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching currency: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
