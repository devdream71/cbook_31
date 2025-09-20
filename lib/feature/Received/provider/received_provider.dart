import 'dart:convert';
import 'package:cbook_dt/feature/Received/model/create_recived_voucher_model.dart';
import 'package:cbook_dt/feature/Received/model/received_list_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 

class ReceiveVoucherProvider with ChangeNotifier {
  List<ReceiveVoucherModel> _vouchers = [];
  bool isLoading = false;

  List<ReceiveVoucherModel> get vouchers => _vouchers;

  double _totalReceived = 0.0;
  double get totalReceived => _totalReceived;  

  /// Receive voucher item show all
  Future<void> fetchReceiveVouchers({DateTime? startDate, DateTime? endDate}) async {
    debugPrint('🔍 Starting fetchReceiveVouchers...');
    debugPrint('🔍 Date range: $startDate to $endDate');
    
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      String url = '${AppUrl.baseurl}receive-vouchers';
      
      // ✅ Add date parameters to URL if provided
      if (startDate != null && endDate != null) {
        final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        url += '?start_date=$startDateStr&end_date=$endDateStr';
      }

      debugPrint('🔍 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url), 
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('🔍 Response status: ${response.statusCode}');
      debugPrint('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);

        if (extractedData['success'] == true && extractedData['data'] != null) {
          final List<dynamic> rawData = List.from(extractedData['data']);
          debugPrint('🔍 Raw data length: ${rawData.length}');

          List<ReceiveVoucherModel> fetchedVouchers = [];
          double apiTotalReceived = 0.0;

          // ✅ Process each item in the data array
          for (int i = 0; i < rawData.length; i++) {
            var item = rawData[i];
            debugPrint('🔍 Processing item $i: $item');
            
            if (item is Map<String, dynamic>) {
              if (item.containsKey('total_received')) {
                // ✅ Extract total_received value
                apiTotalReceived = _parseDouble(item['total_received']);
                debugPrint('🔍 Found total_received: $apiTotalReceived');
              } else if (item.containsKey('id') && 
                        item.containsKey('voucher_number') && 
                        item.containsKey('customer')) {
                // ✅ This is a valid voucher object
                try {
                  var voucher = ReceiveVoucherModel.fromJson(item);
                  fetchedVouchers.add(voucher);
                  debugPrint('🔍 Added voucher: ${voucher.voucherNumber}');
                } catch (e) {
                  debugPrint('🔍 Error parsing voucher at index $i: $e');
                  debugPrint('🔍 Problematic item: $item');
                }
              } else {
                debugPrint('🔍 Unknown item structure at index $i: $item');
              }
            }
          }

          _vouchers = fetchedVouchers;
          
          // ✅ Use API total if available, otherwise calculate from filtered vouchers
          if (apiTotalReceived > 0) {
            _totalReceived = apiTotalReceived;
          } else {
            _totalReceived = _vouchers.fold(0.0, (sum, v) => sum + v.totalAmount);
          }

          debugPrint('🔍 Final results:');
          debugPrint('🔍 Vouchers count: ${_vouchers.length}');
          debugPrint('🔍 Total received: $_totalReceived');
          debugPrint('🔍 Voucher numbers: ${_vouchers.map((v) => v.voucherNumber).toList()}');

        } else {
          debugPrint('🔍 API success is false or data is null');
          _vouchers = [];
          _totalReceived = 0.0;
        }
      } else {
        debugPrint('🔍 API Error: ${response.statusCode} - ${response.body}');
        _vouchers = [];
        _totalReceived = 0.0;
      }
    } catch (e) {
      debugPrint('🔍 Exception in fetchReceiveVouchers: $e');
      debugPrint('🔍 Stack trace: ${StackTrace.current}');
      _vouchers = [];
      _totalReceived = 0.0;
    } finally {
      isLoading = false;
      debugPrint('🔍 Setting isLoading to false and notifying listeners');
      notifyListeners();
    }
  }

  // ✅ Helper method for safe double parsing
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove commas and parse
      final cleanValue = value.replaceAll(',', '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Delete payment voucher
  Future<bool> deleteRecivedVoucher(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${AppUrl.baseurl}receive-vouchers/removes?id=$id');
    try {
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      });
      debugPrint('DELETE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          await fetchReceiveVouchers(); // Refresh the list after deletion
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      return false;
    }
  }

  /// Store received voucher
  Future<bool> storeReceivedVoucher(ReceivedVoucherRequest request) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/receive-vouchers/store',
        request.toQueryParameters(),
      );

      final bodyJson = json.encode(request.toJson());

      debugPrint('--- Received Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: bodyJson,
      );

      debugPrint('API Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      isLoading = false;
      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Exception in storeReceivedVoucher: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get by id for update
  Future<Map<String, dynamic>?> fetchReceiveVoucherById(String id) async {
    final url = Uri.parse('${AppUrl.baseurl}receive-vouchers/edit/$id');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');     

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
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

  /// Update received voucher
  Future<bool> updateReceivedVoucher(String voucherId, ReceivedVoucherRequest request) async {
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
        'received_to': request.receivedTo,
        'account_id': request.accountId.toString(),
        'received_from': request.receivedFrom.toString(),
        'percent': request.percent,
        'total_amount': request.totalAmount.toString(),
        'discount': request.discount.toString(),
        'notes': request.notes,
      };

      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/receive-vouchers/update',
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

      debugPrint('--- Update Received Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------------');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: bodyJson,
      );

      debugPrint('Update API Status Code: ${response.statusCode}');
      debugPrint('Update API Response Body: ${response.body}');

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        // Refresh the vouchers list after successful update
        await fetchReceiveVouchers();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Exception in updateReceivedVoucher: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}


