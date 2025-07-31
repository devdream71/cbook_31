import 'dart:convert';

import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class UnitProvider extends ChangeNotifier {
  List<Unit> _units = [];
  bool _isLoading = false;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;

  Future<void> fetchUnits() async {
    _isLoading = true;
    notifyListeners();

    const String apiUrl = 'https://commercebook.site/api/v1/units';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        UnitResponse unitResponse = UnitResponse.fromJson(jsonResponse);
        _units = unitResponse.units;
      } else {
        throw Exception('Failed to load units');
      }
    } catch (error) {
      debugPrint('Error fetching units: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
