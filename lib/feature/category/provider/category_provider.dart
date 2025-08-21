import 'dart:convert';

import 'package:cbook_dt/feature/category/model/category_list.dart';
import 'package:cbook_dt/feature/category/model/edit_category_model.dart';
import 'package:cbook_dt/feature/category/model/sub_category_edit_response.dart';
import 'package:cbook_dt/feature/category/sub_category/model/item_sub_category.dart';
import 'package:cbook_dt/feature/category/sub_category/sub_category_list.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  List<ItemCategoryModel> categories = [];
  bool isLoading = false;

  bool isAdding = false;

  List<ItemSubCategory> subcategories = [];

  ///====> category fetch
  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}item-categories'),
        headers: {'Accept': 'application/json',
        "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          categories = ItemCategoryModel.fromJsonList(responseData['data']);
        } else {
          categories = [];
        }
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (error) {
      debugPrint("Error fetching categories: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  ///Create Category   ========>>>
  Future<void> createCategory(String name, String status) async {
    isAdding = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getInt('user_id')?.toString() ?? '0';

      final token = prefs.getString('token');

      final String url =
          '${AppUrl.baseurl}item-categories/store?name=$name&status=$status&user_id=$userId';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json',
        "Authorization": "Bearer $token",
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final newCategory = ItemCategoryModel.fromJson(responseData['data']);
        categories.add(newCategory);
        notifyListeners();

        debugPrint("Category added successfully: ${responseData['message']}");
      } else {
        debugPrint("Failed to add category: ${responseData['message']}");
      }
    } catch (error) {
      debugPrint("Error adding category: $error");
    }

    isAdding = false;
    notifyListeners();
  }

  ////=====> delete category .
  ///
   
   Future<bool> deleteCategory(int categoryId) async {
    
        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


  try {
    final response = await http.post(
      Uri.parse(
          '${AppUrl.baseurl}item-categories/remove/$categoryId'),
      headers: {'Accept': 'application/json',
      
      "Authorization": "Bearer $token",
      },
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();

      debugPrint("Category deleted successfully");
      return true; // ✅ Success
    } else {
      debugPrint("Failed to delete category: ${responseData['message']}");
      return false; // ❌ Failure
    }
  } catch (error) {
    debugPrint("Error deleting category: $error");
    return false; // ❌ Exception failure
  }
}



  
  ////get update catagory
  // Future<EditCategoryModel?> fetchCategoryById(int id) async {

  //       final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //   try {
  //     final response = await http.get(
  //       Uri.parse('${AppUrl.baseurl}/item-categories/edit/$id'),
  //       headers: {'Accept': 'application/json',
        
  //       "Authorization": "Bearer $token",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success'] == true) {
  //         return EditCategoryModel.fromJson(data['data']);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching category: $e");
  //   }
  //   return null;
  // }


  // Fixed fetchCategoryById method for CategoryProvider

Future<EditCategoryModel?> fetchCategoryById(int id) async {
  debugPrint('🔍 Fetching category by ID: $id');
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    // ✅ Fixed: Remove extra slash in URL
    final url = '${AppUrl.baseurl}item-categories/edit/$id';
    debugPrint('🔍 API URL: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      },
    );

    debugPrint('🔍 Response Status: ${response.statusCode}');
    debugPrint('🔍 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      debugPrint('🔍 Parsed Data: $data');
      
      if (data['success'] == true && data['data'] != null) {
        final categoryData = EditCategoryModel.fromJson(data['data']);
        debugPrint('✅ Successfully parsed category: ${categoryData.name}');
        return categoryData;
      } else {
        debugPrint('❌ API returned success=false or null data');
        debugPrint('❌ Full response: $data');
      }
    } else {
      debugPrint('❌ HTTP Error: ${response.statusCode}');
      debugPrint('❌ Error body: ${response.body}');
    }
  } catch (e, stackTrace) {
    debugPrint("💥 Exception fetching category: $e");
    debugPrint("💥 Stack trace: $stackTrace");
  }
  
  return null;
}

////update category data
  Future<bool> updateCategory({
    required int id,
    required String name,
    required String status,
  }) async {
    try {
           
               final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


      final response = await http.post(
        Uri.parse(
            "${AppUrl.baseurl}item-categories/update?id=$id&name=$name&status=$status"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
    return false;
  }

////====>sub category list
  Future<void> fetchSubCategories() async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}item-subcategories'),
        headers: {'Accept': 'application/json',
        "Authorization": "Bearer $token",
        
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          subcategories = ItemSubCategory.fromJsonList(responseData['data']);
        } else {
          subcategories = [];
        }
      } else {
        throw Exception("Failed to load subcategories");
      }
    } catch (error) {
      debugPrint("Error fetching subcategories: $error");
    }

    isLoading = false;
    notifyListeners();
  }

 

  Future<bool> deleteSubCategory(int subcategoryId) async {
  try {
      
          final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final response = await http.post(
      Uri.parse(
          '${AppUrl.baseurl}item-subcategories/remove/$subcategoryId'),
      headers: {'Accept': 'application/json',
      "Authorization": "Bearer $token",
      },
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      subcategories.removeWhere((subcategory) => subcategory.id == subcategoryId);
      notifyListeners();

      debugPrint("Sub Category deleted successfully");
      return true; // ✅ Return success
    } else {
      debugPrint("Failed to delete Sub category: ${responseData['message']}");
      return false; // ❌ Return failure
    }
  } catch (error) {
    debugPrint("Error deleting Sub category: $error");
    return false; // ❌ Return failure on exception
  }
}

//create sub category

  Future<void> createSubCategory(
      String name, String status, int categoryId, BuildContext context) async {
    isAdding = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getInt('user_id')?.toString();

      if (userId == null || userId.isEmpty) {
        debugPrint("Error: User ID is null or not found");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID not found. Please log in.")),
        );
        isAdding = false;
        notifyListeners();
        return;
      }

      debugPrint("User ID: $userId");
      debugPrint("Category ID: $categoryId");
      debugPrint("SubCategory Name: $name");
      debugPrint("Status: $status");

           
      final token = prefs.getString('token');


      final response = await http.post(
        Uri.parse('${AppUrl.baseurl}item-subcategories/store'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "item_category": categoryId.toString(),
          "name": name,
          "status": status,
          "user_id": userId,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final newSubCategory = ItemSubCategory.fromJson(responseData['data']);
          subcategories.add(newSubCategory);
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Subcategory added successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2), // Show Snackbar for 2 seconds
            ),
          );

          await fetchSubCategories(); // Ensure the latest data is fetched

          // *Fix:* Delay Navigator.pop(context) to ensure Snackbar is shown
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          debugPrint("Error: ${responseData['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${responseData['message']}")),
          );
        }
      } else {
        debugPrint("Server Error: ${responseData['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    } catch (error) {
      debugPrint("Error adding subcategory: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }

    isAdding = false;
    notifyListeners();
  }

  SubcategoryEditResponse? _editSubcategory;
  SubcategoryEditResponse? get editSubcategory => _editSubcategory;

  ///sub category details.
  Future<void> fetchSubcategoryDetails(int id) async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final url = Uri.parse(
        '${AppUrl.baseurl}item-subcategories/edit/$id');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _editSubcategory = SubcategoryEditResponse.fromJson(data['data']);
      } else {
        debugPrint('Failed to fetch subcategory: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching subcategory: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateSubCategory({
    required BuildContext context,
    required int id,
    required int itemCategoryId,
    required String name,
    required String status,
  }) async {

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final url = Uri.parse(
        '${AppUrl.baseurl}item-subcategories/update?id=$id&item_category=$itemCategoryId&name=$name&status=$status');

    try {
      final response = await http.post(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          // ✅ Navigate to ItemSubCategoryView
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ItemSubCategoryView()));
          // Optionally show a snackbar or toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw data['message'];
        }
      } else {
        throw "Failed to update subcategory. Status: ${response.statusCode}";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
