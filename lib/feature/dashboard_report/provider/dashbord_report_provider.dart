import 'dart:convert';
import 'package:cbook_dt/feature/dashboard_report/model/bank_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/customer_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/customer_transaction_count.dart';
import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
import 'package:cbook_dt/feature/dashboard_report/model/supplier_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/total_supplier_count_model.dart';
import 'package:cbook_dt/feature/dashboard_report/model/voucher_summary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 

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

  /// Fetch customer transaction amount
  Future<void> fetchCustomerTransaction() async {
    isLoadingCustomerTransaction = true;
    errorCustomerTransaction = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://commercebook.site/api/v1/dashboard/transection/customer?type=customer');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        customerTransaction = decoded['data'] ?? 0;
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
    isLoadingCustomerCount = true;
    errorCustomerCount = null;
    notifyListeners();

    try {
      var request = http.Request(
        'POST',
        Uri.parse('https://commercebook.site/api/v1/dashboard/customer?type=customer'),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String jsonStr = await response.stream.bytesToString();
        final jsonData = json.decode(jsonStr);
        customerTransactionCountTotal = jsonData['data'] ?? 0;
      } else {
        errorCustomerCount = 'Failed to load data. Status code: ${response.statusCode}';
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

    try {
      final url = Uri.parse(
          'https://commercebook.site/api/v1/dashboard/transection/customer?type=suppliers');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        supplierTransaction =
            SupplierTransactionModel.fromJson(decoded).data;
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
  try {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/dashboard/customer?type=suppliers');
    final response = await http.post(url);

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
  final url = Uri.parse(
      'https://commercebook.site/api/v1/dashboard/transection?type=cash');
  try {
    isLoading = true;
    notifyListeners();

    final response = await http.post(url, headers: {
      'Accept': 'application/json',
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
  isLoading = true;
  error = null;
  notifyListeners();

  final url = Uri.parse('https://commercebook.site/api/v1/dashboard/transection?type=bank');

  try {
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
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

  final url = Uri.parse('https://commercebook.site/api/v1/dashboard/voucher-summary-30-days');

  try {
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
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

    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/dashboard/sales-last-30-days');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          
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
