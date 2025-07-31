import 'dart:convert';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PurchaseReturnProvider with ChangeNotifier {

  List<PurchaseReturn> _purchaseReturns = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<PurchaseReturn> get purchaseReturns => _purchaseReturns;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  double _totalReturn = 0;
  double get totalReturn => _totalReturn;

  ///purchase return list show.
  // Future<void> fetchPurchaseReturns() async {
  //   const url = "https://commercebook.site/api/v1/purchase/return";

  //   try {
  //     _isLoading = true;
  //     _errorMessage = '';
  //     notifyListeners();

  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = PurchaseReturnResponse.fromJson(response.body);
  //       _purchaseReturns = data.data;

  //       await _fetchItemNames();
  //     } else {
  //       _errorMessage = "Failed to load data: ${response.statusCode}";
  //       debugPrint("API Error: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     _errorMessage = "Something went wrong: $e";
  //     debugPrint("Exception: $e");
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }


  Future<void> fetchPurchaseReturns() async {
    const url = "https://commercebook.site/api/v1/purchase/return";

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = PurchaseReturnResponse.fromJson(response.body);
        _purchaseReturns = result.data;
        _totalReturn = result.totalReturn;
      } else {
        _errorMessage = "Failed to load data: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///delete purchse return
  Future<void> deletePurchaseReturn(String id, context) async {
    final url =
        "https://commercebook.site/api/v1/purchase/return/remove/?id=$id";

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final response = await http.post(Uri.parse(url)); // POST method

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          _purchaseReturns
              .removeWhere((element) => element.id.toString() == id);
          fetchPurchaseReturns();
          // Optionally: show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Purchase return deleted", style: TextStyle(color: Colors.green),)),
          );
          notifyListeners();
          debugPrint("✅ Purchase Return Deleted Successfully");
        } else {
          _errorMessage = json['message'] ?? 'Failed to delete.';
          debugPrint("⚠️ Delete failed: $_errorMessage");
        }
      } else {
        _errorMessage = "Delete failed: ${response.statusCode}";
        debugPrint("❌ API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Exception: $e";
      debugPrint("❌ Exception: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final Map<int, String> _itemsMap = {};

  String getItemName(int itemId) {
    return _itemsMap[itemId] ?? "Unknown Item";
  }
  

  ///fetch item name.
  Future<void> _fetchItemNames() async {
    // Example API call to fetch item names
    const itemUrl =
        "https://commercebook.site/api/v1/items"; // Update with your item details endpoint
    final response = await http.get(Uri.parse(itemUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Assuming the API response has a 'data' key which contains the list of items
      final List<dynamic> items =
          data['data']; // Accessing 'data' key to get the list of items

      for (var item in items) {
        _itemsMap[item['id']] =
            item['name']; // Assuming 'id' and 'name' are fields
      }
    } else {
      debugPrint("Failed to fetch items: ${response.statusCode}");
    }
  }

}
