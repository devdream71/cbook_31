import 'dart:convert';
import 'package:cbook_dt/feature/item/model/item_category.dart';
import 'package:cbook_dt/feature/item/model/item_sub_category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemCategoryProvider extends ChangeNotifier {

  List<ItemCategory> _categories = [];
  List<SubCategoryModel> subCategories = [];

  bool _isLoading = false;
  bool isSubCategoryLoading = false;

  List<ItemCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  String? selectedSubCategoryId; 

  Future<void> fetchCategories() async {

    _isLoading = true;
    notifyListeners();

    const String url = "https://commercebook.site/api/v1/item-categories";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          _categories = ItemCategory.fromJsonMap(data['data']);
        } else {
          _categories = [];
          debugPrint("Invalid data format");
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      debugPrint("Network Error: $error");
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> fetchSubCategories(int categoryId) async {
    isSubCategoryLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(
          'https://commercebook.site/api/v1/item/get/subcategories/$categoryId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        subCategories = SubCategoryModel.fromJsonList(data);
      } else {
        debugPrint("Error fetching subcategories: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching subcategories: $e");
    }
    isSubCategoryLoading = false;
    notifyListeners();
  }

   void setSelectedSubCategoryId(String id) {
    selectedSubCategoryId = id;
    notifyListeners();
  }
}
  