import 'dart:convert';
import 'package:cbook_dt/feature/bill_voucher_settings/model/model_bill_settings.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BillSettingsProvider with ChangeNotifier {
  List<BillSettingModel> _settings = [];
  bool _isLoading = false;

  List<BillSettingModel> get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      //_error = 'No token found. Please login again.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = '${AppUrl.baseurl}app/setting';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'];

        _settings = dataList
            .map((setting) => BillSettingModel.fromJson(setting))
            .toList();
      } else {
        debugPrint('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get setting value by key
  String? getValue(String key) {
    try {
      return _settings.firstWhere((element) => element.data == key).value;
    } catch (_) {
      return null;
    }
  }
}
