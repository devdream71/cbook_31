import 'dart:convert';
import 'package:cbook_dt/feature/dashboard_report/model/bank_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/company_model.dart';
import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
import 'package:cbook_dt/feature/dashboard_report/model/supplier_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/total_supplier_count_model.dart';
import 'package:cbook_dt/feature/dashboard_report/model/voucher_summary.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardReportProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // Customer transaction amount
  dynamic customerTransaction;
  bool isLoadingCustomerTransaction = false;
  String? errorCustomerTransaction;

  // Customer count
  int? customerTransactionCountTotal;
  bool isLoadingCustomerCount = false;
  String? errorCustomerCount;


   bool _isSwitchingCompany = false;
  String? _switchCompanyError;

  bool get isSwitchingCompany => _isSwitchingCompany;
  String? get switchCompanyError => _switchCompanyError;

  
  ///switch company.
  // Future<bool> switchCompany(int companyId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final userId = prefs.getInt('user_id');

  //   if (token == null || userId == null) {
  //     _switchCompanyError = "Token or User ID not found";
  //     notifyListeners();
  //     return false;
  //   }

  //   _isSwitchingCompany = true;
  //   _switchCompanyError = null;
  //   notifyListeners();

  //   try {
  //     final url = Uri.parse('https://commercebook.site/api/v1/company/switch?user_id=$userId&company_id=$companyId');
      
  //     print("🔄 Switching to company ID: $companyId"); // Debug print
      
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     print("🔄 Switch API Response: ${response.body}"); // Debug print

  //     if (response.statusCode == 200) {
  //       final decoded = json.decode(response.body);
        
  //       if (decoded['success'] == true) {
  //         // Save new company ID to SharedPreferences
  //         await prefs.setInt('company_id', companyId);
          
  //         print("✅ Company switched successfully to ID: $companyId"); // Debug print
          
  //         _isSwitchingCompany = false;
  //         notifyListeners();
  //         return true;
  //       } else {
  //         _switchCompanyError = decoded['message'] ?? 'Failed to switch company';
  //         _isSwitchingCompany = false;
  //         notifyListeners();
  //         return false;
  //       }
  //     } else {
  //       _switchCompanyError = "Server error: ${response.statusCode}";
  //       _isSwitchingCompany = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _switchCompanyError = e.toString();
  //     _isSwitchingCompany = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }




///switch company.
  Future<bool> switchCompany(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      _switchCompanyError = "Token or User ID not found";
      notifyListeners();
      return false;
    }

    _isSwitchingCompany = true;
    _switchCompanyError = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://commercebook.site/api/v1/company/switch?user_id=$userId&company_id=$companyId');
      
      print("🔄 Switching to company ID: $companyId");
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔄 Switch API Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded['success'] == true) {
          // Save new company ID to SharedPreferences
          await prefs.setInt('company_id', companyId);
          
          // Find the selected company and save its details
          final selectedCompany = _companyList.firstWhere(
            (company) => company.companyId == companyId,
            orElse: () => _companyList.first,
          );
          
          // Save company name
          await prefs.setString('company_name', selectedCompany.companyName);
          
          // Save company logo
          if (selectedCompany.logo != null && selectedCompany.logo!.isNotEmpty) {
            await prefs.setString('company_logo', selectedCompany.logo!);
          } else {
            await prefs.remove('company_logo');
          }
          
          print("✅ Company switched successfully to ID: $companyId");
          print("✅ Company logo updated: ${selectedCompany.logo}");
          
          _isSwitchingCompany = false;
          notifyListeners();
          return true;
        } else {
          _switchCompanyError = decoded['message'] ?? 'Failed to switch company';
          _isSwitchingCompany = false;
          notifyListeners();
          return false;
        }
      } else {
        _switchCompanyError = "Server error: ${response.statusCode}";
        _isSwitchingCompany = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _switchCompanyError = e.toString();
      _isSwitchingCompany = false;
      notifyListeners();
      return false;
    }
  }

  
   // Company List
  List<CompanyModel> _companyList = [];
  bool _isLoadingCompanyList = false;
  String? _errorCompanyList;

  List<CompanyModel> get companyList => _companyList;
  bool get isLoadingCompanyList => _isLoadingCompanyList;
  String? get errorCompanyList => _errorCompanyList;

  Future<void> fetchCompanyList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      _errorCompanyList = "Token or User ID not found";
      notifyListeners();
      return;
    }

    _isLoadingCompanyList = true;
    _errorCompanyList = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://commercebook.site/api/v1/company/list?user_id=$userId');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded['success'] == true && decoded['data'] != null) {
          _companyList = (decoded['data'] as List)
              .map((company) => CompanyModel.fromJson(company))
              .toList();
        } else {
          _errorCompanyList = decoded['message'] ?? 'Failed to load companies';
        }
      } else {
        _errorCompanyList = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      _errorCompanyList = e.toString();
    } finally {
      _isLoadingCompanyList = false;
      notifyListeners();
    }
  }
 
  Future<void> fetchCustomerTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    isLoadingCustomerTransaction = true;
    errorCustomerTransaction = null;
    notifyListeners();

    try {
      final url = Uri.parse(
          '${AppUrl.baseurl}dashboard/transection/customer?type=customer');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Parse and format
        double rawData = (decoded['data'] ?? 0).toDouble();
        customerTransaction =
            double.parse(rawData.abs().toStringAsFixed(2)); // 393.55
      } else {
        errorCustomerTransaction = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorCustomerTransaction = e.toString();
    } finally {
      isLoadingCustomerTransaction = false;
      notifyListeners();
    }
  }

  /// Fetch customer count
  Future<void> fetchCustomerCountTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    isLoadingCustomerCount = true;
    errorCustomerCount = null;
    notifyListeners();

    try {
      var request = http.Request(
        'POST',
        Uri.parse(
          '${AppUrl.baseurl}dashboard/customer?type=customer',
        ),
      );

      // Add headers here
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String jsonStr = await response.stream.bytesToString();
        final jsonData = json.decode(jsonStr);
        customerTransactionCountTotal = jsonData['data'] ?? 0;
      } else {
        errorCustomerCount =
            'Failed to load data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      errorCustomerCount = 'Error occurred: $e';
    } finally {
      isLoadingCustomerCount = false;
      notifyListeners();
    }
  }

  dynamic supplierTransaction;

  ///supplier
  Future<void> fetchSupplierTransaction() async {
    _setLoading(true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
          '${AppUrl.baseurl}dashboard/transection/customer?type=suppliers');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        supplierTransaction = SupplierTransactionModel.fromJson(decoded).data;
      } else {
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  ///total supplier count.
  int? totalSupplierCount;

  Future<void> fetchTotalSupplierCount() async {
    _setLoading(true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
          '${AppUrl.baseurl}dashboard/customer?type=suppliers');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        totalSupplierCount = TotalSupplierCountModel.fromJson(decoded).data;
      } else {
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  dynamic cashInHand;

  ///cash in hand
  Future<void> fetchCashInHandTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
        '${AppUrl.baseurl}dashboard/transection?type=cash');
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        cashInHand = jsonData['data'];
        error = null;
      } else {
        error = 'Failed to fetch cash in hand data';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  BankBalanceModel? bankBalanceModel;

  dynamic bankBalance;

  ///bank
  Future<void> fetchBankBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse(
        '${AppUrl.baseurl}dashboard/transection?type=bank');

    try {
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        bankBalance = decoded['data'] ?? 0;
      } else {
        error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  VoucherSummary? voucherSummary;

  ///voucher summary 30 days
  Future<void> fetchVoucherSummary() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
        '${AppUrl.baseurl}dashboard/voucher-summary-30-days');

    try {
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        voucherSummary = VoucherSummary.fromJson(decoded['data']);
      } else {
        error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<SalesReportModel> _salesList = [];
  List<SalesReportModel> get salesList => _salesList;

  ///sales last 30 days
  Future<void> fetchSalesLast30Days() async {
    isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    notifyListeners();

    final url = Uri.parse(
        '${AppUrl.baseurl}dashboard/sales-last-30-days');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      final extractedData = json.decode(response.body);

      if (extractedData['success'] == true) {
        final List<SalesReportModel> loadedSales = [];
        for (var item in extractedData['data']) {
          loadedSales.add(SalesReportModel.fromJson(item));
        }
        _salesList = loadedSales;
      } else {
        _salesList = [];
      }
    } catch (e) {
      debugPrint('Sales fetch error: $e');
      _salesList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  double maxSalesValue() {
    if (salesList.isEmpty) return 100;
    return salesList.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
  }
}
