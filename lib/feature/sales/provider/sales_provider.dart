import 'dart:convert';
import 'package:cbook_dt/feature/sales/model/sales_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SalesProvider with ChangeNotifier {


  List<SaleItem> _sales = [];
  List<SaleItem> _filteredSales = [];

  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  Map<int, String> _itemsMap = {};
  Map<int, String> _unitsMap = {}; 

  List<SaleItem> get sales => _filteredSales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDeleting => _isDeleting;

  SalesSummary? _summary;
  SalesSummary? get summary => _summary;

  /// Fetch sales from API
  Future<void> fetchSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://commercebook.site/api/v1/sales/'),
      );

      debugPrint("API called. Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        SalesResponse salesResponse = SalesResponse.fromJson(data);
        _sales = salesResponse.data;
        _filteredSales = _sales; // Initialize with all sales

        _sales = salesResponse.data;
        _summary = salesResponse.summary;

        debugPrint("Success: ${jsonEncode(data)}");
      } else if (response.statusCode == 404) {
        _errorMessage = "Error 404: Sales data not found";
      } else if (response.statusCode == 500) {
        _errorMessage =
            "Error 500: Internal Server Error. Please try again later.";
      } else {
        _errorMessage = "Unexpected Error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Exception occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filter sales by customer name or "cash"
  void filterSales(String query) {
    if (query.isEmpty) {
      _filteredSales = _sales;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredSales = _sales.where((sale) {
        final customer = sale.customerName == "N/A" ? "Cash" : sale.customerName;
        return customer.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// Optional: Reset filter (could be used on clear button)
  void resetFilter() {
    _filteredSales = _sales;
    notifyListeners();
  }
  

  ///Delete sale data 
  Future<void> deleteSale(int purchaseId) async {
    _isDeleting = true; // ✅ Show loader
    notifyListeners();

    final url = Uri.parse(
        'https://commercebook.site/api/v1/sales/remove?id=$purchaseId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          debugPrint("✅ Sale deleted: $purchaseId");

          // ✅ Remove item from local list for instant UI update
          _sales.removeWhere(
              (sale) => sale.purchaseDetails.first.purchaseId == purchaseId);
          notifyListeners();

          // ✅ Fetch updated list
          await fetchSales();
          notifyListeners();
        } else {
          debugPrint("❌ Failed to delete sale: ${data['message']}");
        }
      } else {
        debugPrint("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error deleting sale: $e");
    }

    _isDeleting = false; // ✅ Hide loader
    notifyListeners();
  }

  
  ///item fetchItem 
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

  String getItemName(int itemId) {
    return _itemsMap[itemId] ?? "Unknown Item";
  }
  

  /// Get unit symbol by ID
  String getUnitSymbol(int unitId) {
    return _unitsMap[unitId] ?? "";
  }


  Future<void> fetchPurchasesAndItems() async {
    await fetchSales();
    await fetchItems(); // Fetch items along with purchases
    await fetchUnits();
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

 
}
