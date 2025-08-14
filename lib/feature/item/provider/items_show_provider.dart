import 'dart:convert';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/purchase/model/purchase_item_model.dart';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_item_details.dart';
import 'package:cbook_dt/feature/sales/model/stock_response.dart';
import 'package:cbook_dt/feature/sales/model/stock_response_purchase.dart';
import 'package:cbook_dt/feature/sales_return/model/sales_return_history_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddItemProvider extends ChangeNotifier {
  List<ItemsModel> _items = [];
  bool _isLoading = false;
  StockData? _stockData;
  StockDataPurchase? _purchaseStockData;

  final Map<int, String> _unitNames = {}; // Unit ID -> name
  final Map<int, String> _unitSymbols = {}; // Unit ID -> symbol
  final Map<String, String> _stockQuantities =
      {}; // Item ID -> Quantity (if needed)

  List<ItemModel> itemsCash = [];
  List<PurchaseHistoryModel> purchaseHistory = [];
  List<SalesReturnHistoryModel> saleHistory = [];

  String? _selectedCustomerId;
  String? get selectedCustomerId => _selectedCustomerId;

  bool get isLoading => _isLoading;
  List<ItemsModel> get items => _items;
  StockData? get stockData => _stockData;
  StockDataPurchase? get purchaseStockData => _purchaseStockData;

  Map<int, String> get unitNames => _unitNames;
  Map<int, String> get unitSymbols => _unitSymbols;
  Map<String, String> get stockQuantities => _stockQuantities;

  bool isHistoryLoading = false;

  //filter item base on category and subcategory
  List<ItemsModel> _filteredItems = [];
  List<ItemsModel> get filteredItems => _filteredItems;

  void setSelectedCustomerId(String customerId) {
    _selectedCustomerId = customerId;
    notifyListeners();
  }

  void clearStockData() {
    _stockData = null;
    notifyListeners();
  }

  void clearPurchaseStockData() {
    _purchaseStockData = null;
    notifyListeners();
  }

  void clearPurchaseStockDatasale() {
    _stockData = null;
    notifyListeners();
  }

  void updateItem(int index, ItemModel updatedItem) {
    if (index >= 0 && index < itemsCash.length) {
      itemsCash[index] = updatedItem;
      notifyListeners();
    }
  }

  String getItemName(int id) {
    return _items
        .firstWhere((e) => id == e.id,
            orElse: () => ItemsModel(id: id, name: "Unknown"))
        .name;
  }

  /// NEW helper method to get unit name by unitId string
  String getUnitName(String? unitId) {
    if (unitId == null) return "N/A";
    final id = int.tryParse(unitId);
    if (id == null) return "N/A";
    return _unitNames[id] ?? "Unknown";
  }

  /// NEW helper method to get unit symbol by unitId string
  String getUnitSymbol(String? unitId) {
    if (unitId == null) return "";
    final id = int.tryParse(unitId);
    if (id == null) return "";
    return _unitSymbols[id] ?? "Unknown";
  }

  ////item fetch all

   // Method to calculate total stock value
  Map<String, double> calculateTotals() {
  double totalQtySum = 0.0;
  double averageRateSum = 0.0;

  for (var item in _items) {
    double totalQty = _parseToDouble(item.totalQty);
    double averageRate = _parseToDouble(item.avarageRate);

    totalQtySum += totalQty;
    averageRateSum += averageRate;

    debugPrint("Item: ${item.name}, Qty: $totalQty, Rate: $averageRate");
  }

  debugPrint("Total Qty Sum: $totalQtySum");
  debugPrint("Average Rate Sum: $averageRateSum");

  return {
    'qty': totalQtySum,
    'rate': averageRateSum,
  };
}
  // Helper method to safely parse dynamic values to double
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    return 0.0;
  }

  // Method to get formatted stock value as string
  String getFormattedTotals() {
  final totals = calculateTotals();
  String formattedQty = _formatCurrency(totals['qty'] ?? 0.0);
  String formattedRate = _formatCurrency(totals['rate'] ?? 0.0);

  return "Qty: $formattedQty | $formattedRate";
}

  // Helper method to format currency
  String _formatCurrency(double amount) {
    // Convert to string with 2 decimal places
    String amountStr = amount.toStringAsFixed(2);
    
    // Add commas for thousands separator
    final parts = amountStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';
    
    // Add commas to whole part
    String formatted = '';
    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        formatted += ',';
      }
      formatted += wholePart[i];
    }
    
    return '$formatted.$decimalPart';
  }

  // Update your existing fetchItems method to notify listeners after calculation
  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


      final url = "${AppUrl.baseurl}items";
    try {
      final response = await http.get(Uri.parse(url), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
      debugPrint("API response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true && data["data"] is List) {
          _items = (data["data"] as List)
              .map((item) => ItemsModel.fromJson(item))
              .toList();
          // By default show all
          _filteredItems = List.from(_items);
          
          // Calculate and log total stock value after fetching items
          //double totalStockValue = calculateTotalStockValue();
          //debugPrint("Updated Total Stock Value: $totalStockValue");
        } else {
          debugPrint("Invalid data format");
        }
      } else {
        debugPrint("Failed to fetch items: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception during fetchItems: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


  
  /// unit show.
  Future<void> fetchUnits() async {
     final url = "${AppUrl.baseurl}units";

         final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final response = await http.get(Uri.parse(url), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final unitData = data["data"] as Map<String, dynamic>;

        unitData.forEach((key, value) {
          final unitId = int.tryParse(key);
          if (unitId != null && value is Map) {
            _unitNames[unitId] = value["name"] ?? '';
            _unitSymbols[unitId] = value["symbol"] ?? '';
          }
        });

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Exception fetching units: $e");
    }
  }

  ////delete item. ===== >
  Future<bool> deleteItem(int itemId) async {
    final String deleteUrl =
        "${AppUrl.baseurl}item/remove?id=$itemId";

            final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final response = await http.post(Uri.parse(deleteUrl), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
      debugPrint("Delete response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          await fetchItems();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
    return false;
  }

  /// Filter method
  void filterItems(int? categoryId, int? subCategoryId) {
    _filteredItems = _items.where((item) {
      final matchCategory =
          categoryId == null || item.itemCategoryId == categoryId;
      final matchSubCategory =
          subCategoryId == null || item.itemSubCategoryId == subCategoryId;
      return matchCategory && matchSubCategory;
    }).toList();

    notifyListeners();
  }

  ///==> fetch stock quantity
  Future<void> fetchStockQuantity(String itemId) async {
    // Check if customer ID is available

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

    String baseUrl =
        '${AppUrl.baseurl}sales/stock/item/quantity?item_id=$itemId';
    if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) {
      baseUrl += '&customer_id=$_selectedCustomerId';
    }

    debugPrint("=============>customer id");
    debugPrint(_selectedCustomerId);

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'].isNotEmpty) {
          _stockData = StockData.fromJson(
              data['data'][0]); // ✅ Update _stockData instead of stockData
          debugPrint(
              "Stock Loaded: ${_stockData!.stocks} (${_stockData!.unitStocks}) ${_stockData!.price} ");
        } else {
          _stockData =
              StockData(stocks: 0, unitStocks: "Stock Unavailable", price: 0);
          debugPrint("No stock data available for this item.");
        }
      } else {
        debugPrint("Error fetching stock: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching stock: $e");
    }

    notifyListeners(); // ✅ Notify UI about the update
  }

  ///====> purchase stoke quantity
  Future<void> fetchPurchaseStockQuantity(String itemId) async {

       final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final url = Uri.parse(
        '${AppUrl.baseurl}purchase/stock/item/quantity/$itemId');

    try {
      final response = await http.get(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'].isNotEmpty) {
          _purchaseStockData = StockDataPurchase.fromJson(
              data['data'][0]); // Store purchase stock data
          debugPrint(
              "Purchase Stock Loaded: ${_purchaseStockData!.stocks} (${_purchaseStockData!.unitStocks}) Price: ${_purchaseStockData!.price}");
        } else {
          _purchaseStockData = StockDataPurchase(
              stocks: 0, unitStocks: "No Purchase Stock", price: 0);
          debugPrint("No purchase stock data available for this item.");
        }
      } else {
        debugPrint("Error fetching purchase stock: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching purchase stock: $e");
    }

    notifyListeners(); // Notify UI about the update
  }

////=== purchase history

  Future<void> fetchPurchaseHistory(String itemId, dynamic selctedvalue) async {
    isHistoryLoading = true;
    purchaseHistory = [];
    // _isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final String url =
        //"https://commercebook.site/api/v1/item/purchase/history/$itemId";
        "${AppUrl.baseurl}item/purchase/history?customer_id=$selctedvalue&item_id=$itemId";


    try {
      final response = await http.get(Uri.parse(url, ), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        } );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> data = responseData["data"];
          purchaseHistory =
              data.map((e) => PurchaseHistoryModel.fromJson(e)).toList();
          debugPrint(
              "Fetched Purchase History: ${purchaseHistory.length} items");

          debugPrint(" == >${responseData.toString()}");
        } else {
          purchaseHistory = [];
          debugPrint("No purchase history found.");
        }
      } else {
        debugPrint("Error fetching purchase history: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }

    isHistoryLoading = false;
    notifyListeners();
  }

  ////sales sales/return/history
  Future<void> fetchSaleHistory(int ? itemId, String selectedCustomerID) async {
    isHistoryLoading = true;
    saleHistory = [];
    // _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getInt('user_id')?.toString() ?? '';

    ///customer id should be dynamic
    ///
    ///    final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final String url =
        "${AppUrl.baseurl}item/sales/history?customer_id=$selectedCustomerID&item_id=$itemId";

    try {
      final response = await http.get(Uri.parse(url, ), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> data = responseData["data"];
          saleHistory =
              data.map((e) => SalesReturnHistoryModel.fromJson(e)).toList();
          debugPrint("Fetched sales History: ${saleHistory.length} items");

          debugPrint(" == >${responseData.toString()}");
        } else {
          saleHistory = [];
          debugPrint("No sales history found.");
        }
      } else {
        debugPrint("Error fetching sales history: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }

    isHistoryLoading = false;
    notifyListeners();
  }

  ////update item provider showing below
}
