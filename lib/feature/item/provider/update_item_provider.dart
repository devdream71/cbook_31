import 'dart:convert';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/update_item_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemUpdateProvider with ChangeNotifier {
  bool isLoading = false;
  UpdateItemModel? item;
  String errorMessage = "";

  // Controllers to hold fetched data
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController mrpPriceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final TextEditingController unitIdController = TextEditingController();
  final TextEditingController unitIdSecondController = TextEditingController();
  final TextEditingController unitQtyController = TextEditingController();

  String selectedDate = "";

  int? selectedCategoryId;
  int? selectedSubCategoryId;
  int? selectedUnitId;
  int? selectedSecondaryUnitId;
  String selectedStatus = "1";

  bool _isLoading2 = false;

  bool get isLoading2 => _isLoading2;

  void setLoading(bool value) {
    _isLoading2 = value;
    notifyListeners();
  }

  Future<void> fetchItemDetails(int id) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners(); // Notify UI to show loading indicator

    final url =
        Uri.parse("https://commercebook.site/api/v1/item/edit/$id"); //old
    //final url = Uri.parse("https://commercebook.site/api/v1/item/show/$id"); //new

    debugPrint("Fetching item details from: $url");

    try {
      final response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final String responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          errorMessage = "Empty response from server.";
          isLoading = false;
          notifyListeners();
          return;
        }

        final data = jsonDecode(responseBody);
        debugPrint("Decoded JSON: $data");

        if (data is Map<String, dynamic> && data.containsKey("data")) {
          item = UpdateItemModel.fromJson(data["data"]);
          debugPrint("Item fetched successfully: ${item?.name}");

          // **Set values to controllers**
          nameController.text = item?.name ?? "";
          stockController.text = item?.openingStock.toString() ?? "0";
          priceController.text = item?.openingPrice?.toString() ?? "0";
          purchasePriceController.text = item?.purchasePrice?.toString() ?? "0";
          salePriceController.text = item?.salePrice?.toString() ?? "0";
          mrpPriceController.text = item?.mrpPrice?.toString() ?? "0";
          imageController.text = item?.image?.toString() ?? "0";

          unitIdController.text = item?.unitId.toString() ?? "";
          unitIdSecondController.text = item?.unit2nd.toString() ?? "";
          unitQtyController.text = item?.unitQTY.toString() ?? "";

          valueController.text =
              item?.openingValue?.toString() ?? "0"; // Handle null value
          selectedDate = item?.openingDate ?? "";

          isLoading = false; // Stop loading
          notifyListeners(); // Notify UI to rebuild with new data
        } else {
          errorMessage = data["message"] ?? "Failed to fetch item.";
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Network error: $e";
    }

    isLoading = false;
    notifyListeners(); // Ensure UI updates
  }

  Future<void> updateItem(int itemId, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse("https://commercebook.site/api/v1/item/update");

    Map<String, dynamic> requestData = {
      "id": itemId,
      "name": nameController.text,
      "item_category_id": selectedCategoryId,
      "item_sub_category_id": selectedSubCategoryId,
      "unit_id": selectedUnitId,
      "unit_qty": 1,
      "secondary_unit_id": selectedSecondaryUnitId,
      "opening_stock": stockController.text,
      "opening_price": priceController.text,
      "mrp_price": mrpPriceController.text,
      "opening_value": valueController.text,
      "opening_date": selectedDate,
      "status": selectedStatus,
    };

    // Add purchase_price_type and purchase_price if purchase price is provided
    if (purchasePriceController.text.isNotEmpty) {
      requestData["purchase_price_type"] = 1;
      requestData["purchase_price"] = purchasePriceController.text;
    }

    // Add sales_price_type and sales_price if sales price is provided
    if (salePriceController.text.isNotEmpty) {
      requestData["sales_price_type"] = 1;
      requestData["sales_price"] = salePriceController.text;
    }

    // Add sales_price_type and sales_price if sales price is provided
    if (mrpPriceController.text.isNotEmpty) {
      requestData["mrp_price_type"] = 1;
      requestData["mrp_price"] = mrpPriceController.text;
    }

    debugPrint("Updating item with data: $requestData");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestData),
      );

      debugPrint("Update Response Status: ${response.statusCode}");
      debugPrint("Update Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          debugPrint("✅ Item updated successfully!");

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Item updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          errorMessage = data["message"] ?? "Failed to update item.";
          debugPrint(errorMessage);
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Network error: $e";
      debugPrint(errorMessage);
    }

    isLoading = false;
    if (context.mounted) {
      notifyListeners();
    }
  }
}
