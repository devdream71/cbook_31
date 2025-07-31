import 'dart:convert';
import 'package:cbook_dt/feature/purchase/model/purchase_create_model.dart';
import 'package:cbook_dt/feature/transaction/model/purchase_tr_list_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PurchaseProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PurchaseSummary? get summary => _purchaseData?.summary;


  // Future<void> fetchPurchases() async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   final url = Uri.parse('https://commercebook.site/api/v1/purchase/');
  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       _purchaseData = PurchaseViewModel.fromJson(data); 
  //        _filteredData = _purchaseData;
  //         notifyListeners();
  //       debugPrint(data);
  //       debugPrint(_purchaseData.toString());
  //     } 
  //       else if (response.statusCode==404){
  //         _errorMessage = "Error 404: Data Not found";

  //       } else if (response.statusCode == 500){
  //         _errorMessage = "Error 500: Inteernal Server Error.";
  //       }  
      
  //     else {
  //       //throw Exception('Failed to load purchases');
  //       _errorMessage = "Unexpected Error ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     _errorMessage = "Exception occurred $e";
  //     debugPrint('Error fetching purchases: $e');
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  // }


   Future<void> fetchPurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/purchase/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _purchaseData = PurchaseViewModel.fromJson(data);
        notifyListeners();
      } else if (response.statusCode == 404) {
        _errorMessage = "Error 404: Data Not found";
      } else if (response.statusCode == 500) {
        _errorMessage = "Error 500: Internal Server Error.";
      } else {
        _errorMessage = "Unexpected Error ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Exception occurred $e";
    }

    _isLoading = false;
    notifyListeners();
  }


    /// ✅ Delete purchase method (NEW)
  // Future<void> deletePurchase( int purchaseId) async {
  //   final url = Uri.parse(
  //       'https://commercebook.site/api/v1/purchase/remove?id=$purchaseId');

  //   try {
  //     final response = await http.post(url);
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['success'] == true) {
          
  //         await fetchPurchases(); // refresh list
  //       } else {
           
  //       }
  //     } else {
  //       throw Exception('Failed to delete purchase');
  //     }
  //   } catch (error) {
      
  //   }

  //     notifyListeners();
  // }


  Future<void> deletePurchase(int purchaseId) async {
  final url = Uri.parse(
      'https://commercebook.site/api/v1/purchase/remove?id=$purchaseId');

  try {
    final response = await http.post(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success'] == true) {
        // ✅ Remove the deleted item locally if _purchaseData is stored
        _purchaseData?.data?.removeWhere(
          (item) => item.purchaseDetails?.first.purchaseId == purchaseId,
        );

        notifyListeners(); // ✅ This updates the UI

        // Optionally refresh from API (optional but slower)
        // await fetchPurchases();
      } else {
        // Handle API response indicating failure
        debugPrint('Failed to delete: ${data['message']}');
      }
    } else {
      throw Exception('Failed to delete purchase');
    }
  } catch (error) {
    debugPrint('Delete error: $error');
  }
}


  List<PurchaseItemModel> _purchaseItems = [];
  List<PurchaseItemModel> get purchaseItems => _purchaseItems;

  void setPurchaseItems(List<PurchaseItemModel> items) {
    _purchaseItems = items;
    notifyListeners();
  }

  /// Method to calculate subtotal from purchase items
  double calculateSubTotal() {
    double subtotal = 0.0;
    for (var item in _purchaseItems) {
      subtotal += (double.tryParse(item.price.toString()) ?? 0.0) *
          (int.tryParse(item.qty.toString()) ?? 0);
    }
    return subtotal;
  }

  /// Store purchase API call
  // Future<bool> storePurchase() async {
  //   _isLoading = true;
  //   notifyListeners(); // Notify UI about loading state

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();

  //     // Check if bill_number exists, if not, set an initial value
  //     if (!prefs.containsKey("bill_number")) {
  //       await prefs.setInt("bill_number", 521444); // Set default bill number
  //     }

  //     // Get the last bill number and increment it
  //     int lastBillNumber = prefs.getInt("bill_number") ?? 521444;
  //     int newBillNumber = lastBillNumber + 1;

  //     // Save the updated bill number
  //     await prefs.setInt("bill_number", newBillNumber);

  //     // Calculate total amount
  //     double totalAmount = calculateSubTotal();

  //     final url =
  //         "https://commercebook.site/api/v1/purchase/store?user_id=${prefs.getString("id")}&customer_id=0&bill_number=$newBillNumber&purchase_date=${DateTime.now().toIso8601String()}&details_notes=notes&gross_total=$totalAmount&discount=5";

  //     debugPrint("API URL: $url");

  //     // Prepare request body
  //     final requestBody = {
  //       "purchase_items": _purchaseItems.map((item) => item.toJson()).toList()
  //     };
  //     debugPrint("Request Body: $requestBody");

  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode(requestBody),
  //     );

  //     debugPrint("API Response: ${response.body}"); // Debugging

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       if (data["success"] == true) {
  //         debugPrint("✅ Purchase successful: ${data["data"]}");
  //         _isLoading = false;
  //         notifyListeners();
  //         return true;
  //       } else {
  //         debugPrint("❌ Error: ${data["message"]}");
  //         _isLoading = false;
  //         notifyListeners();
  //         return false;
  //       }
  //     } else {
  //       debugPrint("❌ Error: ${response.statusCode} - ${response.reasonPhrase}");
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error fetching purchase: $e");
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }



   PurchaseViewModel? _purchaseData;
   PurchaseViewModel? _filteredData;
  //bool _isLoading = false;
  String? _errorMessage;

   Map<int, String> _itemsMap = {};

   Map<int, String> _unitsMap = {}; // Store unit symbols

  // PurchaseViewModel? get purchaseData => _purchaseData;
   PurchaseViewModel? get purchaseData => _filteredData ?? _purchaseData;
  //bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
    

    ///filter data 
    void filterPurchases(String query) {
    if (_purchaseData == null || _purchaseData!.data == null) return;

    if (query.isEmpty) {
      _filteredData = _purchaseData;
    } else {
      final lowercaseQuery = query.toLowerCase();
      _filteredData = PurchaseViewModel(
        data: _purchaseData!.data!.where((purchase) {
          final supplier = purchase.supplier ?? 'Cash';
          return supplier.toLowerCase().contains(lowercaseQuery) ||
              (supplier == 'N/A' && 'cash'.contains(lowercaseQuery));
        }).toList(),
      );
    }
    notifyListeners();
  }

   void resetFilter() {
  _filteredData = _purchaseData;
  notifyListeners();
}



   Future<void> fetchItems() async {
    final url = Uri.parse('https://commercebook.site/api/v1/items');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> itemsList = data['data'];

        _itemsMap = {for (var item in itemsList) item['id']: item['name']};
        notifyListeners();
      } else {
        _errorMessage = "Error fetching items: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Exception fetching items: $e";
    }
  }

  /// Fetch unit symbols
  Future<void> fetchUnits() async {
    final url = Uri.parse('https://commercebook.site/api/v1/units');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          _unitsMap = {
            for (var key in data["data"].keys)
              int.parse(key): data["data"][key]["symbol"]
          };
        }
      }
    } catch (e) {
      _errorMessage = "Error fetching units: $e";
    }
    notifyListeners();
  }

  String getItemName(int itemId) {
    return _itemsMap[itemId] ?? "Unknown Item";
  }

   /// Get unit symbol by ID
  String getUnitSymbol(int unitId) {
    return _unitsMap[unitId] ?? "";
  }


  Future<void> fetchPurchasesAndItems() async {
    await fetchPurchases();
    await fetchItems(); // Fetch items along with purchases
     await fetchUnits();
  }



  
  



}


