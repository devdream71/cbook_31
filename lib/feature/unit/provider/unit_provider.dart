 import 'dart:convert';
import 'package:cbook_dt/feature/unit/model/unit_add_model.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UnitDTProvider extends ChangeNotifier {
  List<UnitResponseModel> units = [];
  bool isLoading = false;

  List<UnitAddResponseModel> units2 = [];

  ///unit list show.
  Future<void> fetchUnits() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}units'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('📋 Fetch Units Response: ${response.statusCode}');
      debugPrint('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> unitData = responseData['data'];

        units = unitData.values
            .map((unit) => UnitResponseModel.fromJson(unit))
            .toList();
            
        debugPrint('📋 Total units loaded: ${units.length}');
        for (var unit in units) {
          debugPrint('📋 Unit: ID=${unit.id}, Name=${unit.name}, Status=${unit.status}');
        }
      } else {
        throw Exception("Failed to load units");
      }
    } catch (error) {
      debugPrint("❌ Error fetching units: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  ///unit create - Always status 1
  Future<bool> addUnit(String name, String symbol) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('user_id')?.toString() ?? '';
    final token = prefs.getString('token');

    // ✅ Always pass status as "1"
    final String url =
        '${AppUrl.baseurl}unit/store?user_id=$userId&name=$name&symbol=$symbol&status=1';

    debugPrint('🚀 Add Unit URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('📤 Add Response: ${response.statusCode}');
      debugPrint('📤 Add Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        UnitResponseModel newUnit = UnitResponseModel.fromJson(responseData['data']);
        units.add(newUnit);
        notifyListeners();

        debugPrint("✅ Unit added successfully: ${responseData['message']}");
        return true;
      } else {
        debugPrint("❌ Failed to add unit: ${responseData['message']}");
        return false;
      }
    } catch (error) {
      debugPrint("💥 Error adding unit: $error");
      return false;
    }
  }

  ///unit delete.
  Future<bool> deleteUnit(int unitId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String url = '${AppUrl.baseurl}unit/remove/$unitId';

    debugPrint('🗑️ Delete Unit URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('🗑️ Delete Response: ${response.statusCode}');
      debugPrint('🗑️ Delete Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        units.removeWhere((unit) => unit.id == unitId);
        notifyListeners();

        debugPrint("✅ Unit deleted successfully: ${responseData['message']}");
        return true;
      } else {
        debugPrint("❌ Failed to delete unit: ${responseData['message']}");
        return false;
      }
    } catch (error) {
      debugPrint("💥 Error deleting unit: $error");
      return false;
    }
  }

  ///unit update - Always status 1
  Future<bool> updateUnit(int unitId, String name, String symbol) async {
    debugPrint('🔄 Starting unit update...');
    debugPrint('🔄 Unit ID: $unitId');
    debugPrint('🔄 Name: $name');
    debugPrint('🔄 Symbol: $symbol');
    debugPrint('🔄 Status: 1 (hardcoded)');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('user_id')?.toString() ?? '';
    final token = prefs.getString('token');

    // ✅ Always pass status as "1"
    final String url =
        '${AppUrl.baseurl}unit/update?id=$unitId&user_id=$userId&name=$name&symbol=$symbol&status=1';

    debugPrint('🔄 API URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('🔄 Response Status: ${response.statusCode}');
      debugPrint('🔄 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update the local list
        int index = units.indexWhere((unit) => unit.id == unitId);
        if (index != -1) {
          UnitResponseModel updatedUnit = UnitResponseModel.fromJson(responseData['data']);
          units[index] = updatedUnit;
          
          debugPrint('✅ Local list updated successfully');
          debugPrint('✅ Updated unit: ID=${updatedUnit.id}, Name=${updatedUnit.name}, Status=${updatedUnit.status}');
          
          notifyListeners();
        } else {
          debugPrint('⚠️ Unit not found in local list');
          return false;
        }

        debugPrint("✅ Unit update successful: ${responseData['message']}");
        return true;
      } else {
        debugPrint("❌ Failed to update unit: ${responseData['message']}");
        debugPrint("❌ Response data: $responseData");
        return false;
      }
    } catch (error) {
      debugPrint("💥 Error updating unit: $error");
      return false;
    }
  }

  // Separate method for refreshing data
  Future<void> refreshUnits() async {
    await fetchUnits();
  }

  // Additional helper methods
  bool unitExists(int unitId) {
    return units.any((unit) => unit.id == unitId);
  }

  UnitResponseModel? getUnitById(int unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId);
    } catch (e) {
      return null;
    }
  }

  // Method to manually sync with server if needed
  Future<bool> syncWithServer() async {
    try {
      await fetchUnits();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Debug method to check specific unit in backend
  Future<void> debugCheckUnit(int unitId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}unit/$unitId'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('🔍 Debug Unit Check: ${response.statusCode}');
      debugPrint('🔍 Debug Response: ${response.body}');
    } catch (e) {
      debugPrint('🔍 Debug Check Error: $e');
    }
  }
}



