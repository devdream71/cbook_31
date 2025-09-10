import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/adjust_cash.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/create_adjust_cash_model.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdjustCashProvider with ChangeNotifier {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<AdjustCash> _accounts = [];

  // Getters
  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);
  List<AdjustCash> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  /// Fetch cash accounts
  Future<void> fetchCashAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = '${AppUrl.baseurl}accounts/cash-accounts';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        _accounts = items.map((e) => AdjustCash.fromJson(e)).toList();
      } else {
        debugPrint("Failed to load accounts: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching accounts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Store cash adjustment
  Future<AdjustCashResponse?> adjustCashStore({
    required String adjustCashType,
    required String accountId,
    required String amount,
    required String date,
    String? details,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Build URL with query parameters
      final uri =
          Uri.parse('${AppUrl.baseurl}account/cash/adjustment/store').replace(
        queryParameters: {
          'adjust_cash': adjustCashType,
          'account_id': accountId,
          'amount': amount,
          'date': date,
          'details': details ?? '',
          'user_id': userId,
        },
      );

      debugPrint("Request URL: $uri");

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final result = AdjustCashResponse.fromJson(jsonData);

        // Clear form data after successful operation
        accountNameController.clear();
        detailsController.clear();
        _selectedDate = DateTime.now();

        return result;
      } else {
        debugPrint("Adjustment failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("API error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 
}
