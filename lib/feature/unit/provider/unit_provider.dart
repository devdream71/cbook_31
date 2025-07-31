import 'dart:convert';
import 'package:cbook_dt/feature/unit/model/unit_add_model.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
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

    try {
      final response = await http.get(
        Uri.parse('https://commercebook.site/api/v1/units'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> unitData = responseData['data'];

        units = unitData.values
            .map((unit) => UnitResponseModel.fromJson(unit))
            .toList();
      } else {
        throw Exception("Failed to load units");
      }
    } catch (error) {
      debugPrint("Error fetching units: $error");
    }

    isLoading = false;
    notifyListeners();
  }
  


  ///unit create.
  Future<void> addUnit(String name, String symbol, String ? status) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('user_id')?.toString() ?? '';

    final String url =
        'https://commercebook.site/api/v1/unit/store?user_id=$userId&name=$name&symbol=$symbol&status=$status';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        UnitResponseModel newUnit =
            UnitResponseModel.fromJson(responseData['data']);

        units.add(newUnit); // ✅ Add to the same list UI is using
        notifyListeners();

        debugPrint("Unit added successfully: ${responseData['message']}");

        // ✅ Refresh the unit list from API to ensure latest data
        await fetchUnits();

        //Navigator.push(context, MaterialPageRoute(builder: (context)=>UnitListView()));
      } else {
        debugPrint("Failed to add unit: ${responseData['message']}");
      }
    } catch (error) {
      debugPrint("Error adding unit: $error");
    }
  }
  

  ///unit delete.
  Future<bool> deleteUnit(int unitId, BuildContext context) async {
  final String url = 'https://commercebook.site/api/v1/unit/remove/$unitId';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      units.removeWhere((unit) => unit.id == unitId); // ✅ Remove from list
      notifyListeners(); // ✅ Update UI

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unit deleted successfully!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      await fetchUnits(); // Optional: Refresh list
      debugPrint("Unit deleted successfully: ${responseData['message']}");
      return true; // ✅ return success
    } else {
      debugPrint("Failed to delete unit: ${responseData['message']}");
      return false;
    }
  } catch (error) {
    debugPrint("Error deleting unit: $error");
    return false; // ✅ return failure
  }
}

  

  ///unit update.
  Future<void> updateUnit(int unitId, String name, String ? symbol,
      dynamic status, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('user_id')?.toString() ?? '';

    final String url =
        'https://commercebook.site/api/v1/unit/update?id=$unitId&user_id=$userId&name=$name&symbol=$symbol&status=$status';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        int index = units.indexWhere((unit) => unit.id == unitId);
        if (index != -1) {
          units[index] = UnitResponseModel.fromJson(responseData['data']);

          // Delay notifyListeners() to avoid modifying the state during build
          Future.delayed(Duration.zero, () {
            notifyListeners();
          });
        }

        // Instead of navigating, refresh the unit list in the same page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unit updated successfully",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint("Failed to update unit: ${responseData['message']}");
      }
    } catch (error) {
      debugPrint("Error updating unit: $error");
    }
  }
}
