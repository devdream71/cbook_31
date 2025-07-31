import 'dart:convert';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/model/create_payment_out.dart';
import 'package:cbook_dt/feature/paymentout/model/payment_out_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  // Future<void> fetchPaymentVouchers() async {
  //   isLoading = true;
  //   notifyListeners();

  //   final url = Uri.parse('https://commercebook.site/api/v1/payment-vouchers');

  //   try {
  //     final response = await http.get(url);
  //     debugPrint('API STATUS CODE: ${response.statusCode}');
  //     debugPrint('API RESPONSE: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final extractedData = json.decode(response.body);
  //       if (extractedData['success'] == true && extractedData['data'] != null) {
  //         final List<dynamic> data = extractedData['data'];
  //         debugPrint('DATA LENGTH: ${data.length}');

  //         _vouchers = data
  //             .map((voucher) => PaymentVoucherModel.fromJson(voucher))
  //             .toList();
  //       } else {
  //         debugPrint('Data key is null or API success false');
  //         _vouchers = [];
  //       }
  //     } else {
  //       debugPrint('HTTP ERROR');
  //       _vouchers = [];
  //     }
  //   } catch (error) {
  //     debugPrint('EXCEPTION: $error');
  //     _vouchers = [];
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchPaymentVouchers() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/payment-vouchers');

    try {
      final response = await http.get(url);
      debugPrint('API STATUS CODE: ${response.statusCode}');
      debugPrint('API RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);

        if (extractedData['success'] == true && extractedData['data'] != null) {
          final List<dynamic> data = extractedData['data'];

          // Remove the last element and check if it's total_payment
          final lastItem = data.last;
          if (lastItem is Map<String, dynamic> && lastItem.containsKey('total_payment')) {
            _totalPayment = double.tryParse(lastItem['total_payment'].toString()) ?? 0.0;
            data.removeLast(); // remove total_payment from list
          } else {
            _totalPayment = 0.0;
          }

          _vouchers = data.map((voucher) => PaymentVoucherModel.fromJson(voucher)).toList();
        } else {
          _vouchers = [];
          _totalPayment = 0.0;
        }
      } else {
        _vouchers = [];
        _totalPayment = 0.0;
      }
    } catch (error) {
      debugPrint('EXCEPTION: $error');
      _vouchers = [];
      _totalPayment = 0.0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //bill person api call.
  Future<void> fetchBillPersons() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/bill/person/list');

    try {
      final response = await http.get(url);
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
    final url = Uri.parse(
        'https://commercebook.site/api/v1/payment-vouchers/removes?id=$id');
    try {
      final response = await http.post(url);
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
        },
        body: bodyJson,
      );

      debugPrint('Store Payment Voucher API status: ${response.statusCode}');
      debugPrint('Store Payment Voucher API response: ${response.body}');

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
    final url =
        Uri.parse('https://commercebook.site/api/v1/payment-vouchers/edit/$id');

    try {
      final response = await http.get(url);
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
  Future<bool> updatePaymentVoucher(String voucherId, PaymentVoucherRequest request) async {
   // Future<bool> updatePaymentVoucher(String voucherId, update.PaymentVoucherRequestUpdate request) async {
    isLoading = true;
    notifyListeners();

    try {
      // Create query parameters for the URL
      final queryParams = {
        'id': voucherId,
        'user_id': request.userId.toString(),
        'voucher_person': request.voucherPerson.toString(),
        'voucher_number': request.voucherNumber,
        'voucher_date': request.voucherDate,
        'voucher_time': request.voucherTime,
        'payment_form': request .paymentForm, // Note: API uses 'payment_form'
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
        'voucher_items': request.voucherItems.map((item) => {
          'sales_id': item.salesId,
          'amount': item.amount,
        }).toList(),
      };

      final bodyJson = json.encode(bodyData);

      debugPrint('--- Update Payment Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------------');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
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
