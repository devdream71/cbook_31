import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/item_deatils_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ItemProvider with ChangeNotifier {
  Map<String, String> _priceValues = {};

  Map<String, String> get priceValues => _priceValues;


   ItemDetailsModel? item;
  bool isLoading = false;

  Future<void> fetchItemById(int id) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse("https://commercebook.site/api/v1/item/edit/$id");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        item = ItemDetailsModel.fromJson(jsonData['data']);
      }
    } catch (e) {
      debugPrint("Item fetch error: $e");
    }

    isLoading = false;
    notifyListeners();
  }



  void setPriceValues(Map<String, String> prices) {
    _priceValues = prices;
    notifyListeners();
  }

  Map<String, String> _categoryPriceValues = {};

  Map<String, String> get categoryPriceValues => _categoryPriceValues;

  void setCategoryPriceValues(Map<String, String> prices) {
    _categoryPriceValues = prices;
    notifyListeners();
  }

  // NEW: Store list of qty/price
  List<Map<String, String>> _qtyPriceList = [];
  List<Map<String, String>> get qtyPriceList => _qtyPriceList;

  // Add or update Qty and Price at a specific index
  void updateQtyPrice(int index, {required String qty, required String price}) {
    if (index < _qtyPriceList.length) {
      _qtyPriceList[index] = {'qty': qty, 'price': price};
    } else {
      _qtyPriceList.add({'qty': qty, 'price': price});
    }
    notifyListeners();
  }

  // Remove row
  void removeQtyPrice(int index) {
    if (index < _qtyPriceList.length) {
      _qtyPriceList.removeAt(index);
      notifyListeners();
    }
  }

  // Print all rows (You asked for this)
  void printAllQtyPrice() {
    for (int i = 0; i < _qtyPriceList.length; i++) {
      print(
          'Row $i: Qty = ${_qtyPriceList[i]['qty']}, Price = ${_qtyPriceList[i]['price']}');
    }

    print(jsonEncode(_qtyPriceList));
  }

  ////=======No need demo
  void removeQtyPrice2(int index) {
    if (index < _qtyPriceList.length) {
      _qtyPriceList.removeAt(index);
      notifyListeners();
    }
  }


  ////image path for server side.

  Future<File> getImageFileFromAsset(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDir = Directory.systemTemp;
  final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
  return await tempFile.writeAsBytes(byteData.buffer.asUint8List());
}

////item save. api call ===== >

Future<void> saveItem(
  BuildContext context, {
  required String name,
  required String openingDate,
  required String status,
  required double price,
  required double value,
  required int stock,
  required int unitId,
  required int secondaryUnitId,
  required String unitQty,
  required int? selectedCategoryId,
  required int? selectedSubCategoryId,
  File? imageFile,
  String? salePrice,
  String? purchaePrice,
  String? mrpPrice,
  String? wholesalessPrice,
  String? dealersPrice,
  String? retailersPrice,
  String? brokersPrice,
  String? ecommercesPrice,
  String? selectedSalePriceOption,
  String? selectedPurchasePriceOption,
  String? selectedMrpPriceOption,
}) async {
  const String url = "https://commercebook.site/api/v1/item/store";

  debugPrint('Selected Category ID: $selectedCategoryId');
  debugPrint('Selected Subcategory ID: $selectedSubCategoryId');

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('user_id')?.toString() ?? '1';

    var request = http.MultipartRequest("POST", Uri.parse(url));

    String formattedDate;
    try {
      formattedDate = DateFormat("yyyy-MM-dd").format(
        DateFormat("dd-MM-yyyy").parse(openingDate),
      );
    } catch (e) {
      formattedDate = DateTime.now().toIso8601String().split("T")[0];
    }

    request.fields["name"] = name;
    request.fields["opening_date"] = formattedDate;
    request.fields["status"] = status;
    request.fields["opening_stock"] = stock.toString();
    request.fields["opening_price"] = price.toString();
    request.fields["value"] = value.toString();
    request.fields["user_id"] = userId;
    request.fields["unit_qty"] = unitQty;
    request.fields["unit_id"] = unitId.toString();
    request.fields["secondary_unit_id"] = secondaryUnitId.toString();

    if (selectedCategoryId != null) {
      request.fields["categories_id"] = selectedCategoryId.toString();
    }

    if (selectedSubCategoryId != null) {
      request.fields["sub_categories_id"] = selectedSubCategoryId.toString();
    }

    if (salePrice != null && salePrice.isNotEmpty) {
      request.fields["sales_price"] = salePrice;
      request.fields["sales_price_type"] = "1";
    }

    if (purchaePrice != null && purchaePrice.isNotEmpty) {
      request.fields["purchase_price"] = purchaePrice;
      request.fields["purchase_price_type"] = "1";
    }

    if (mrpPrice != null && mrpPrice.isNotEmpty) {
      request.fields["mrps_price"] = mrpPrice;
    }

    if (wholesalessPrice != null && wholesalessPrice.isNotEmpty) {
      request.fields["wholesaless_price"] = wholesalessPrice;
    }

    if (dealersPrice != null && dealersPrice.isNotEmpty) {
      request.fields["dealers_price"] = dealersPrice;
    }

    if (retailersPrice != null && retailersPrice.isNotEmpty) {
      request.fields["retailers_price"] = retailersPrice;
    }

    if (brokersPrice != null && brokersPrice.isNotEmpty) {
      request.fields["brokers_price"] = brokersPrice;
    }

    if (ecommercesPrice != null && ecommercesPrice.isNotEmpty) {
      request.fields["ecommerces_price"] = ecommercesPrice;
    }

    File? finalImageFile = imageFile;

    if (finalImageFile == null) {
      debugPrint("No image file provided. Using default asset image.");
      finalImageFile = await getImageFileFromAsset('assets/image/image_color.png');
    }

    if (finalImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        finalImageFile.path,
        filename: path.basename(finalImageFile.path),
      ));
    }

    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Print Postman-style request URL
    final debugUri = Uri.parse(url).replace(queryParameters: {
      "user_id": userId,
      "name": name,
      "unit_id": unitId.toString(),
      "unit_qty": unitQty,
      "secondary_unit_id": secondaryUnitId.toString(),
      "opening_stock": stock.toString(),
      "opening_price": price.toString(),
      "value": value.toString(),
      "opening_date": formattedDate,
      "status": status,
      "image": finalImageFile.path,
    });
    debugPrint("🔗 Sending URL (Postman style): $debugUri");

    debugPrint("📝 Request Fields:");
    request.fields.forEach((key, value) {
      debugPrint("  $key: $value");
    });

    if (request.files.isNotEmpty) {
      for (var file in request.files) {
        debugPrint("📎 File: ${file.field}, name: ${file.filename}");
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint("📨 Raw Response: ${response.body}");

    if (response.body.startsWith('<!DOCTYPE html>')) {
      debugPrint("❌ HTML error page received instead of JSON.");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server returned an HTML error page."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final responseData = json.decode(response.body);
    final message = responseData['message']?.toString() ?? "No message";

    if (response.statusCode == 200) {
      debugPrint("✅ Success: $message");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      debugPrint("❌ API Error (${response.statusCode}): $message");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $message"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error, stackTrace) {
    debugPrint("❌ Exception occurred:");
    debugPrint("Error: $error");
    debugPrint("StackTrace: $stackTrace");

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to save item")),
    );
  }
}






}
