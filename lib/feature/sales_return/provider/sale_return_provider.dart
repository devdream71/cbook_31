import 'dart:convert';
import 'package:cbook_dt/feature/sales_return/model/sale_return_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesReturnProvider extends ChangeNotifier {
  List<SalesReturnData> salesReturns = [];
  bool isLoading = false;

  final Map<int, String> _itemIdNameMap = {};
  Map<int, String> get itemIdNameMap => _itemIdNameMap;

   double totalReturn = 0.0;

  ///items get.
  Future<void> fetchItems() async {
    try {
      final response =
          await http.get(Uri.parse('https://commercebook.site/api/v1/items'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data']; // ✅ Fix here

        for (var item in data) {
          _itemIdNameMap[item['id']] = item['name'];
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  String getItemName(int id) {
    return _itemIdNameMap[id] ?? 'Unknown Item';
  }

  ///sales return list.
  // Future<void> fetchSalesReturn() async {
  //   isLoading = true;
  //   notifyListeners();

  //   const String url = "https://commercebook.site/api/v1/sales/return";

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = SalesReturnResponse.fromJson(response.body);
  //       salesReturns = data.data;

  //       fetchItems();
  //       debugPrint(salesReturns.toString());
  //     } else {
  //       throw Exception("Failed to load sales return data");
  //     }
  //   } catch (error) {
  //     debugPrint("Error fetching sales return: $error");
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }


  Future<void> fetchSalesReturn() async {
    isLoading = true;
    notifyListeners();

    const String url = "https://commercebook.site/api/v1/sales/return";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = SalesReturnResponse.fromJson(response.body);
        salesReturns = data.salesReturns;
        totalReturn = data.totalReturn;
      } else {
        throw Exception("Failed to load sales return data");
      }
    } catch (error) {
      debugPrint("Error fetching sales return: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///sales return delele.
  Future<void> deleteSalesReturn(int? id, BuildContext context) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/sales/return/remove/?id=$id');

    try {
      final response = await http.post(url); // ⬅ POST method as per API

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Optionally show a SnackBar or Toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Text(responseData['message'] ?? 'Deleted')),
          );

          // Refresh the list
          await fetchSalesReturn();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to delete');
        }
      } else {
        throw Exception("Failed to delete sales return");
      }
    } catch (e) {
      debugPrint("Error deleting sales return: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting sales return: $e")),
      );
    }
  }
}
