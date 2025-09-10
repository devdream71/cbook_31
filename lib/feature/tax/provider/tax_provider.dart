import 'dart:convert';
import 'package:cbook_dt/feature/tax/model/tax_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaxProvider with ChangeNotifier {
  List<TaxModel> _taxList = [];
  bool _isLoading = false;

  String errorMessage = '';

  List<TaxModel> get taxList => _taxList;
  bool get isLoading => _isLoading;

  ///tax show list ====>
  Future<void> fetchTaxes() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${AppUrl.baseurl}tax');

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> taxesJson = data['data'];

        _taxList = taxesJson.map((json) => TaxModel.fromJson(json)).toList();
      } else {
        debugPrint("Failed to load tax data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching tax data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  ///tax create ===>
  Future<void> createTax({
    required int userId,
    required String name,
    required dynamic percent,
    required int status,
  }) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
        '${AppUrl.baseurl}tax/store?user_id=$userId&name=$name&percent=$percent&status=$status');

    try {
      final response = await http.post(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newTax = TaxModel.fromJson(data['data']);
        //_taxList.add(newTax);
        fetchTaxes();
        notifyListeners();

        debugPrint("Tax created successfully: ${data['message']}");
      } else {
        debugPrint("Failed to create tax: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error during tax creation: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  ///tax delete ====>
  //tax delete - CLEAN VERSION (NO UI LOADING STATE)
  Future<bool> deleteTax(int? id) async {
    debugPrint(' Provider: Starting delete for tax ID: $id');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${AppUrl.baseurl}tax/remove?id=$id');
    debugPrint(' Provider: Delete URL: $url');

    try {
      final response = await http.post(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      debugPrint(' Provider: Response Status: ${response.statusCode}');
      debugPrint(' Provider: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        //  Remove from local list immediately on success
        _taxList.removeWhere((tax) => tax.id == id);
        notifyListeners();

        debugPrint(
            " Provider: Tax deleted successfully and removed from local list");
        return true;
      } else {
        debugPrint(" Provider: HTTP Error: ${response.statusCode}");
        debugPrint(" Provider: Error body: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint(" Provider: Exception deleting tax: $e");
      return false;
    }
  }

  ///get tex by id
  Future<TaxModel?> getTaxById(int id) async {
    final url = Uri.parse('${AppUrl.baseurl}tax/edit/$id');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaxModel(
          id: id,
          userId: 0, // userId is not returned in response
          name: data['data']['name'],
          percent: data['data']['percent'],
          status: data['data']['status'],
        );
      }
    } catch (e) {
      debugPrint("Error fetching tax details: $e");
    }
    return null;
  }

  ///tax update===>

  ///tax update - FIXED VERSION
  Future<bool> updateTax({
    required int taxId,
    required String name,
    required String percent,
    required String status,
  }) async {
    _isLoading = true;
    errorMessage = '';
    notifyListeners();

    debugPrint(' Starting tax update...');
    debugPrint(' Tax ID: $taxId');
    debugPrint(' Name: $name');
    debugPrint(' Percent: $percent');
    debugPrint(' Status: $status');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    //  Fixed URL construction
    final String url =
        '${AppUrl.baseurl}tax/update?id=$taxId&name=$name&percent=$percent&status=$status';
    debugPrint(' API URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint(" Status Code: ${response.statusCode}");
      debugPrint(" Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          debugPrint(' Tax update successful');

          // Update local list
          final index = _taxList.indexWhere((tax) => tax.id == taxId);
          if (index != -1) {
            _taxList[index] = TaxModel(
              id: taxId,
              userId: _taxList[index].userId,
              name: name,
              percent: double.parse(percent),
              status: int.parse(status),
            );
            debugPrint(' Local list updated');
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          errorMessage = data['message'] ?? 'Failed to update tax.';
          debugPrint(' API returned success=false: $errorMessage');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        errorMessage = 'HTTP Error: ${response.statusCode}';
        debugPrint(' $errorMessage');
        debugPrint(' Response: ${response.body}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
      debugPrint(' $errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
