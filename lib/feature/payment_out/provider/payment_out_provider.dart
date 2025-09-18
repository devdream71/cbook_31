import 'dart:convert';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
import 'package:cbook_dt/feature/payment_out/model/create_payment_out_model.dart';
import 'package:cbook_dt/feature/payment_out/model/payment_out_list_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentVoucherProvider with ChangeNotifier {
  List<PaymentVoucherModel> _vouchers = [];
  bool isLoading = false;

  List<PaymentVoucherModel> get vouchers => _vouchers;

  ///bill person
  List<BillPersonModel> _billPersons = [];
  List<BillPersonModel> get billPersons => _billPersons;
  List<String> get billPersonNames => _billPersons.map((e) => e.name).toList();

  double _totalPayment = 0.0;
  double get totalPayment => _totalPayment;

  /////show payment voucher
  ///
  


  Future<void> fetchPaymentVouchers({DateTime? startDate, DateTime? endDate}) async {
  isLoading = true;
  notifyListeners();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    final url = Uri.parse('${AppUrl.baseurl}payment-vouchers');
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    debugPrint('=== Payment Vouchers API Debug ===');
    debugPrint('URL: $url');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Raw Response: ${response.body}');
    debugPrint('==================================');

    if (response.statusCode == 200) {
      final extractedData = json.decode(response.body);

      if (extractedData['success'] == true && extractedData['data'] != null) {
        final List<dynamic> rawData = List.from(extractedData['data']);
        
        debugPrint('Raw data length: ${rawData.length}');
        debugPrint('Raw data: $rawData');

        // Handle total payment (last item in array)
        double totalAllPayment = 0.0;
        if (rawData.isNotEmpty) {
          final lastItem = rawData.last;
          debugPrint('Last item: $lastItem');
          
          if (lastItem is Map<String, dynamic> && lastItem.containsKey('total_payment')) {
            final paymentValue = lastItem['total_payment'];
            debugPrint('Total payment value: $paymentValue');
            
            if (paymentValue is String) {
              final paymentString = paymentValue.replaceAll(',', '');
              totalAllPayment = double.tryParse(paymentString) ?? 0.0;
            } else if (paymentValue is num) {
              totalAllPayment = paymentValue.toDouble();
            }
            
            // Remove the total_payment object from the list
            rawData.removeLast();
            debugPrint('After removing total payment, data length: ${rawData.length}');
          }
        }

        // Convert remaining items to PaymentVoucherModel
        List<PaymentVoucherModel> allVouchers = [];
        
        for (var item in rawData) {
          try {
            debugPrint('Processing item: $item');
            final voucher = PaymentVoucherModel.fromJson(item);
            allVouchers.add(voucher);
            debugPrint('Successfully created voucher: ${voucher.voucherNumber}');
          } catch (e) {
            debugPrint('Error creating voucher from item: $e');
            debugPrint('Problematic item: $item');
          }
        }
        
        debugPrint('Total vouchers created: ${allVouchers.length}');

        // Filter based on dates if provided
        if (startDate != null && endDate != null) {
          debugPrint('Filtering by date range: $startDate to $endDate');
          
          _vouchers = allVouchers.where((voucher) {
            try {
              if (voucher.voucherDate == null || voucher.voucherDate!.isEmpty) {
                debugPrint('Voucher has null/empty date: ${voucher.voucherNumber}');
                return false;
              }
              
              final date = DateTime.parse(voucher.voucherDate!);
              final isInRange = date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  date.isBefore(endDate.add(const Duration(days: 1)));
              
              debugPrint('Voucher ${voucher.voucherNumber} date $date in range: $isInRange');
              return isInRange;
            } catch (e) {
              debugPrint('Date parsing error for voucher ${voucher.voucherNumber}: $e');
              return false;
            }
          }).toList();
        } else {
          _vouchers = allVouchers;
        }

        debugPrint('Final filtered vouchers count: ${_vouchers.length}');

        // Calculate total payment of filtered vouchers
        _totalPayment = _vouchers.fold(0.0, (sum, voucher) {
          debugPrint('Adding voucher ${voucher.voucherNumber} amount: ${voucher.totalAmount}');
          return sum + voucher.totalAmount;
        });

        debugPrint('Calculated total payment: $_totalPayment');
        
      } else {
        debugPrint('API response success: false or data is null');
        debugPrint('Success: ${extractedData['success']}');
        debugPrint('Data: ${extractedData['data']}');
        _vouchers = [];
        _totalPayment = 0.0;
      }
    } else {
      debugPrint('HTTP Error: ${response.statusCode}');
      debugPrint('Error Response: ${response.body}');
      _vouchers = [];
      _totalPayment = 0.0;
    }
  } catch (e, stackTrace) {
    debugPrint('Exception in fetchPaymentVouchers: $e');
    debugPrint('Stack trace: $stackTrace');
    _vouchers = [];
    _totalPayment = 0.0;
  } finally {
    isLoading = false;
    debugPrint('Final state - Vouchers: ${_vouchers.length}, Total: $_totalPayment, Loading: $isLoading');
    notifyListeners();
  }
}

  
  //bill person api call.
  Future<void> fetchBillPersons() async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final url = Uri.parse('${AppUrl.baseurl}bill/person/list');

    try {
      final response = await http.get(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
      debugPrint('Bill Person API Response: ${response.body}');

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final List<dynamic> data = extractedData['data'];

        _billPersons =
            data.map((item) => BillPersonModel.fromJson(item)).toList();
      } else {
        _billPersons = [];
      }
    } catch (e) {
      debugPrint('Bill Person API Error: $e');
      _billPersons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Clear/reset bill person list
  void clearBillPersons() {
    _billPersons = [];
    notifyListeners();
  }

  ///delete payment voucher
  Future<bool> deletePaymentVoucher(String id) async {
   
       final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    final url = Uri.parse(
        '${AppUrl.baseurl}payment-vouchers/removes?id=$id');
    try {
      final response = await http.post(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
      debugPrint('DELETE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          await fetchPaymentVouchers(); // ✅ Refresh the list after deletion
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      return false;
    }
  }

  ///store paymet voucher
  Future<bool> storePaymentVoucher(PaymentVoucherRequest request) async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/payment-vouchers/store',
        request.toQueryParameters(),
      );

      final bodyJson = json.encode(request.toJson());

      // Print the full request URL with query parameters
      debugPrint('--- Payment Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('-----------------------------------');

      debugPrint('-------stop----------');

        

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: bodyJson,
      );

      debugPrint('Store Payment Voucher API status: ${response.statusCode}');
      debugPrint('Store Payment Voucher API response: ${response.body}');

      // ✅ Pretty-print voucher_items
      for (var item in request.voucherItems) {
        debugPrint(
            'Voucher Item → sales_id: ${item.salesId}, amount: ${item.amount}');
      }

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      debugPrint('Exception during storePaymentVoucher: $error');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }



  

  ///payment get by id for update.
  Future<Map<String, dynamic>?> fetchReceiveVoucherById(String id) async {

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

    final url =
        Uri.parse('${AppUrl.baseurl}payment-vouchers/edit/$id');

    try {
      final response = await http.get(url, headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
      debugPrint('Edit Voucher Response: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true && result['data'] != null) {
          return result['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Edit Voucher Fetch Error: $e");
      return null;
    }
  }

  //payment out update code here.. below

  ///update payment voucher
  Future<bool> updatePaymentVoucher(
      String voucherId, PaymentVoucherRequest request) async {
    // Future<bool> updatePaymentVoucher(String voucherId, update.PaymentVoucherRequestUpdate request) async {
    isLoading = true;
    notifyListeners();

        final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');


    try {
      // Create query parameters for the URL
      final queryParams = {
        'id': voucherId,
        'user_id': request.userId.toString(),
        'voucher_person': request.voucherPerson.toString(),
        'voucher_number': request.voucherNumber,
        'voucher_date': request.voucherDate,
        'voucher_time': request.voucherTime,
        'payment_form': request.paymentForm, // Note: API uses 'payment_form'
        'account_id': request.accountId.toString(),
        'payment_to': request.paymentTo.toString(),
        'percent': request.percent,
        'total_amount': request.totalAmount.toString(),
        'discount': request.discount.toString(),
        'notes': request.notes,
      };

      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/payment-vouchers/update',
        queryParams,
        
      );

      // Create body with voucher_items
      final bodyData = {
        'voucher_items': request.voucherItems
            .map((item) => {
                  'sales_id': item.salesId,
                  'amount': item.amount,
                })
            .toList(),
      };

      final bodyJson = json.encode(bodyData);

      debugPrint('--- Update Payment Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------------');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
        },
        body: bodyJson,
      );

      debugPrint('Update Payment Voucher API Status: ${response.statusCode}');
      debugPrint('Update Payment Voucher API Response: ${response.body}');

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          // Refresh the vouchers list after successful update
          await fetchPaymentVouchers();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Exception in updatePaymentVoucher: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
