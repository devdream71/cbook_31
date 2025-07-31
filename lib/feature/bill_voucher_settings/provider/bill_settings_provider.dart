import 'dart:convert';
import 'package:cbook_dt/feature/bill_voucher_settings/model/model_bill_settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 

class BillSettingsProvider with ChangeNotifier {
  List<BillSettingModel> _settings = [];
  bool _isLoading = false;

  List<BillSettingModel> get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/app/setting';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'];

        _settings = dataList
            .map((setting) => BillSettingModel.fromJson(setting))
            .toList();
      } else {
        print('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching settings: $e');
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
