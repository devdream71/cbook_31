import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/account_type/model/account_create_response_model.dart';
import 'package:cbook_dt/feature/account/ui/account_type/model/account_type_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountTypeProvider with ChangeNotifier {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountGroupController = TextEditingController();
  final TextEditingController openBlanceController = TextEditingController();

  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();
  final TextEditingController bankLocationController = TextEditingController();

 void resetForm() {
  accountNameController.clear();
  accountGroupController.clear();
  openBlanceController.clear();
  accountHolderNameController.clear();
  accountNoController.clear();
  routingNumberController.clear();
  bankLocationController.clear();
  
   
  
  notifyListeners();
}

  // Date
  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  
 

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _error = 'No token found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse("${AppUrl.baseurl}account/list");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          _accounts = (jsonBody['data'] as List)
              .map((item) => Account.fromJson(item))
              .toList();
        } else {
          _accounts = [];
        }
      } else {
        _error = 'Failed: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }






  ///delete acc type
  String errorMessage = '';

  Future<bool> deleteAccountById(int id) async {
    final url =
        Uri.parse("${AppUrl.baseurl}account/remove/?id=$id");

            final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final response = await http.post(url,
      headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        }
      ); // ✅ POST method

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return true;
        } else {
          errorMessage = jsonData['message'] ?? 'Delete failed';
          return false;
        }
      } else {
        errorMessage = 'Failed with status code: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error occurred: $e';
      return false;
    }
  }



  Future<AccountCreateResponseModel> createAccount({
    required String userId,
    required String accountName,
    required String accountType,
    String? accountGroup,
    required String openingBalance,
    required String date,
    String? status,
    String? accountHolderName,
    String? accountNo,
    String? routingNumber,
    String? bankLocation,
  }) async {
    final queryParameters = {
      'user_id': userId,
      'account_name': accountName,
      'account_type': accountType,
      'account_group': accountGroup,
      'opening_balance': openingBalance,
      'date': date,
      'status': status,
      // optional bank details
      if (accountType.toLowerCase() == 'bank') ...{
        'account_holder_name': accountHolderName ?? '',
        'account_no': accountNo ?? '',
        'routing_number': routingNumber ?? '',
        'bank_location': bankLocation ?? '',
      }
    };

    final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

    final uri = Uri.https(
      'commercebook.site',
      '/api/v1/account/store',
      queryParameters,
       
    );

    debugPrint('uri $uri');

    debugPrint('====Stopppppp=======');


    try {
      final response = await http.post(uri, 
       
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      
       );
      final jsonData = json.decode(response.body);
      debugPrint("✅ Sent URL: $uri");
      debugPrint("📥 Response: $jsonData");

      return AccountCreateResponseModel.fromJson(jsonData);
    } catch (e) {
      debugPrint("❌ Error: $e");
      return AccountCreateResponseModel(
        success: false,
        message: 'Exception: $e',
      );
    }
  }

  String formattedDateEdit = "";
  String selectedAccountType = "cash";
  String selectedStatus = "1";

  ///acount edit
  /// ✅ Fetch Account by ID for Edit
  Future<void> fetchAccountById(int id) async {

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final url =
          Uri.parse('${AppUrl.baseurl}account/edit/$id');
      final response = await http.get(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];

        accountNameController.text = data['account_name'] ?? '';
        accountGroupController.text = data['account_group'] ?? '';
        openBlanceController.text = data['opening_balance'] ?? '';
        selectedAccountType = data['account_type'] ?? 'cash';
        formattedDateEdit = _convertToIso(data['date'] ?? '');
        selectedStatus = (data['status'] == 1) ? "1" : "0";

        notifyListeners();
      } else {
        debugPrint("❌ Failed to fetch account. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching account by ID: $e");
    }
  }

  /// Helper to convert dd-mm-yyyy → yyyy-mm-dd
  String _convertToIso(String date) {
    try {
      final parts = date.split('-');
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    } catch (_) {
      return '2025-07-14';
    }
  }

  ///update acoount
  Future<bool> updateAccount({
    required int id,
    required String userId, // who is updating
  }) async {
    try {

          final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');



      final uri =
          Uri.parse("${AppUrl.baseurl}account/update?id=$id"
              "&user_id=$userId"
              "&account_name=${accountNameController.text.trim()}"
              "&account_type=$selectedAccountType"
              "&account_group=${accountGroupController.text.trim()}"
              "&opening_balance=${openBlanceController.text.trim()}"
              "&date=$formattedDate"
              "&status=$selectedStatus");

      debugPrint('🔄 Sending Update Request: ${uri.toString()}');

      final response = await http.post(uri, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        }); // 🔄 API is GET type here

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint("✅ Update Success: ${jsonData['message']}");
        return jsonData['success'] == true;
      } else {
        debugPrint("❌ Update failed [${response.statusCode}]");
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception during update: $e');
      return false;
    }
  }
}
