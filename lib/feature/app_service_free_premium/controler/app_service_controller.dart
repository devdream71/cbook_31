import 'dart:convert';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppServiceProvider with ChangeNotifier {
  String? _appService;
  bool _isLoading = false;

  String? get appService => _appService;
  bool get isLoading => _isLoading;

  Future<void> fetchAppService() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${AppUrl.baseurl}app/service"),
      );

      debugPrint("=== APP SERVICE API DEBUG ===");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Parsed Data: $data");
        
        _appService = data['data']['app_service'];
        debugPrint("App Service Value: '$_appService'");
        debugPrint("Is Free Check: ${_appService?.toLowerCase() == 'free'}");
        debugPrint("isFree getter result: $isFree");
      } else {
        debugPrint("API Error - Status: ${response.statusCode}");
        _appService = null;
      }
    } catch (e) {
      debugPrint("Exception in fetchAppService: $e");
      _appService = null;
    }

    _isLoading = false;
    debugPrint("Loading finished. Final _appService: '$_appService'");
    debugPrint("Final isFree: $isFree");
    debugPrint("=== END APP SERVICE DEBUG ===");
    notifyListeners();
  }

  // ✅ More robust isFree getter with debugging
  bool get isFree {
    debugPrint("isFree called - _appService: '$_appService'");
    
    if (_appService == null) {
      debugPrint("_appService is null, returning false");
      return false;
    }
    
    final trimmedService = _appService!.trim().toLowerCase();
    debugPrint("Trimmed service: '$trimmedService'");
    
    final result = trimmedService == "free";
    debugPrint("isFree result: $result");
    
    return result;
  }
}