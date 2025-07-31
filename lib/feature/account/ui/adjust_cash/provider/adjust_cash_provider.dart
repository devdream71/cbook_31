import 'dart:convert';

import 'package:cbook_dt/feature/account/ui/adjust_cash/model/adjust_cash.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/bank_adjustment_model.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/create_adjust_cash_model.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdjustCashProvider with ChangeNotifier {

  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();


  DateTime _selectedDate = DateTime.now();

  // String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }


  List<AdjustCash> _accounts = [];
  bool _isLoading = false;

  List<AdjustCash> get accounts => _accounts;
  bool get isLoading => _isLoading;

  
  ///fetch cash acccount.
  Future<void> fetchCashAccounts() async {
    _isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/accounts/cash-accounts';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];

        _accounts = items.map((e) => AdjustCash.fromJson(e)).toList();
      } else {
        debugPrint("Failed to load accounts: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


  ///store cash adjust.
  Future<AdjustCashResponse?> adjustCashStore({
  required String adjustCashType, // e.g. 'cash_add'
  required String accountId,
  required String amount,
  required String date,
  required String details,
  required String userId,
}) async {
  final url =
      'https://commercebook.site/api/v1/account/cash/adjustment/store?adjust_cash=$adjustCashType&account_id=$accountId&amount=$amount&date=$date&details=$details&user_id=$userId';
   

   debugPrint(" url ==> ${url}");
  try {
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return AdjustCashResponse.fromJson(jsonData);
    } else {
      debugPrint("Adjustment failed: ${response.body}");
      return null;
    }
  } catch (e) {
    debugPrint("API error: $e");
    return null;
  }
}




  
  }