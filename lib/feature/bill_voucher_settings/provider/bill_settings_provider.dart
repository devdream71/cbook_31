import 'dart:convert';
import 'package:cbook_dt/feature/bill_voucher_settings/model/model_bill_settings.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BillSettingsProvider with ChangeNotifier {

    TextEditingController salesCode = TextEditingController();
    TextEditingController salesBill = TextEditingController();

    TextEditingController salesReturnCode = TextEditingController();
    TextEditingController salesReturnBill = TextEditingController();

    TextEditingController purchaseCode = TextEditingController();
    TextEditingController purchaseBill = TextEditingController();

    TextEditingController purchaseReturnCode = TextEditingController();
    TextEditingController purchaseReturBill = TextEditingController();

    TextEditingController receivedCode = TextEditingController();
    TextEditingController receivedBill = TextEditingController();

    TextEditingController paymentCode = TextEditingController();
    TextEditingController paymentBill = TextEditingController();

    TextEditingController expenseCode = TextEditingController();
    TextEditingController expenseBill = TextEditingController();

    TextEditingController incomeCode = TextEditingController();
    TextEditingController incomeBill = TextEditingController();

    TextEditingController contraCode = TextEditingController();
    TextEditingController contraBill = TextEditingController();



  List<BillSettingModel> _settings = [];
  bool _isLoading = false;
  String? _error;
  
  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  List<BillSettingModel> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _error = 'No token found. Please login again.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = '${AppUrl.baseurl}app/setting';
    debugPrint('Fetching settings from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint('Settings API Response Status: ${response.statusCode}');
      debugPrint('Settings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];

          _settings = dataList
              .map((setting) => BillSettingModel.fromJson(setting))
              .toList();

          debugPrint('Loaded ${_settings.length} settings');
          
          // Debug print some key settings
          debugPrint('purchases_code: ${getValue("purchases_code")}');
          debugPrint('purchase_bill_no: ${getValue("purchase_bill_no")}');
          debugPrint('with_nick_name: ${getValue("with_nick_name")}');

          debugPrint('purchases_code: ${getValue("purchases_return_code")}');
          debugPrint('purchase_bill_no: ${getValue("purchase_return_bill_no")}');
          
           

        } else {
          _error = 'Invalid response format';
          debugPrint('Settings API returned invalid format');
        }
      } else {
        _error = 'Failed to load settings: ${response.statusCode}';
        debugPrint('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Error fetching settings: $e';
      debugPrint('Error fetching settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get setting value by key
  String? getValue(String key) {
    try {
      final setting = _settings.firstWhere((element) => element.data == key);
      debugPrint('Getting value for $key: ${setting.value}');
      return setting.value;
    } catch (e) {
      debugPrint('Setting not found for key: $key');
      return null;
    }
  }

  // Check if settings are loaded
  bool get hasSettings => _settings.isNotEmpty;
 




 // Update settings API method
  Future<bool> updateSettings(bool withNickName) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _error = 'No token found. Please login again.';
      _isUpdating = false;
      notifyListeners();
      return false;
    }

    final url = '${AppUrl.baseurl}general/setup/update';
    debugPrint('Updating settings to: $url');

    // Prepare request body
    final requestBody = {
      "types": [
        {
          "data": "sales_code",
          "value": salesCode.text.trim()
        },
        {
          "data": "sales_return_code",
          "value": salesReturnCode.text.trim()
        },
        {
          "data": "purchases_code",
          "value": purchaseCode.text.trim()
        },
        {
          "data": "purchases_return_code",
          "value": purchaseReturnCode.text.trim()
        },
        {
          "data": "received_code",
          "value": receivedCode.text.trim()
        },
        {
          "data": "payment_code",
          "value": paymentCode.text.trim()
        },
        {
          "data": "expense_code",
          "value": expenseCode.text.trim()
        },
        {
          "data": "income_code",
          "value": incomeCode.text.trim()
        },
        {
          "data": "contra_code",
          "value": contraCode.text.trim()
        },
        {
          "data": "sales_bill_no",
          "value": salesBill.text.trim()
        },
        {
          "data": "sales_return_bill_no",
          "value": salesReturnBill.text.trim()
        },
        {
          "data": "purchase_bill_no",
          "value": purchaseBill.text.trim()
        },
        {
          "data": "purchase_return_bill_no",
          "value": purchaseReturBill.text.trim()
        },
        {
          "data": "received_bill_no",
          "value": receivedBill.text.trim()
        },
        {
          "data": "payment_bill_no",
          "value": paymentBill.text.trim()
        },
        {
          "data": "expense_bill_no",
          "value": expenseBill.text.trim()
        },
        {
          "data": "income_bill_no",
          "value": incomeBill.text.trim()
        },
        {
          "data": "contra_bill_no",
          "value": contraBill.text.trim()
        },
        {
          "data": "with_nick_name",
          "value": withNickName ? "1" : "0"
        }
      ]
    };

    debugPrint('Update Settings Request Body: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      debugPrint('Update Settings API Response Status: ${response.statusCode}');
      debugPrint('Update Settings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          debugPrint(' Settings updated successfully');
          // Optionally refresh the settings after successful update
          await fetchSettings();
          _isUpdating = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Update failed: ${jsonData['message'] ?? 'Unknown error'}';
          debugPrint(' Settings update failed: ${jsonData['message']}');
        }
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized: Please login again';
        debugPrint(' 401 Unauthorized - Token may be expired');
      } else if (response.statusCode == 500) {
        _error = 'Server Error: Please try again later';
        debugPrint(' 500 Server Error - Internal server error');
      } else {
        _error = 'Failed to update settings: ${response.statusCode}';
        debugPrint(' Failed to update settings: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint(' Error updating settings: $e');
    }

    _isUpdating = false;
    notifyListeners();
    return false;
  }

  // Populate controllers with existing settings
  void populateControllers() {
    salesCode.text = getValue("sales_code") ?? "";
    salesBill.text = getValue("sales_bill_no") ?? "";
    
    salesReturnCode.text = getValue("sales_return_code") ?? "";
    salesReturnBill.text = getValue("sales_return_bill_no") ?? "";
    
    purchaseCode.text = getValue("purchases_code") ?? "";
    purchaseBill.text = getValue("purchase_bill_no") ?? "";
    
    purchaseReturnCode.text = getValue("purchases_return_code") ?? "";
    purchaseReturBill.text = getValue("purchase_return_bill_no") ?? "";
    
    receivedCode.text = getValue("received_code") ?? "";
    receivedBill.text = getValue("received_bill_no") ?? "";
    
    paymentCode.text = getValue("payment_code") ?? "";
    paymentBill.text = getValue("payment_bill_no") ?? "";
    
    expenseCode.text = getValue("expense_code") ?? "";
    expenseBill.text = getValue("expense_bill_no") ?? "";
    
    incomeCode.text = getValue("income_code") ?? "";
    incomeBill.text = getValue("income_bill_no") ?? "";
    
    contraCode.text = getValue("contra_code") ?? "";
    contraBill.text = getValue("contra_bill_no") ?? "";
    
    debugPrint('Controllers populated with existing settings');
  }

  // Get with nick name status
  bool getWithNickNameStatus() {
    final value = getValue("with_nick_name");
    return value == "1";
  }



}


 