import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/adjust_bank/model/adjust_bank_model.dart';
import 'package:cbook_dt/feature/account/ui/adjust_bank/model/adjust_bank_response_model.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/model/bank_adjustment_model.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
 

class BankAdjustProvider with ChangeNotifier {

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



  List<BankAdjustAccount> _bankAccounts = [];

  List<BankAdjustAccount> get bankAccounts => _bankAccounts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ///show bank account type.
  Future<void> fetchBankAccounts() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/accounts/bank-accounts');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List accountsJson = data['data'];
        _bankAccounts = accountsJson.map((e) => BankAdjustAccount.fromJson(e)).toList();
      } else {
        _bankAccounts = [];
      }
    } catch (e) {
      _bankAccounts = [];
      debugPrint('Error fetching bank accounts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }



  ///bank adjust added.
  // ✅ POST Adjust Bank
  Future<AdjustBankResponse?> submitBankAdjustment({
    required String userId,
    required String adjustType, // 'cash_add' or 'cash_reduce'
    required String accountId,
    required String amount,
    required String date,
    required String details,
  }) async {
    final Uri url = Uri.parse(
        'https://commercebook.site/api/v1/account/bank/adjustment/store'
        '?user_id=$userId'
        '&adjust_bank=$adjustType'
        '&account_id=$accountId'
        '&amount=$amount'
        '&date=$date'
        '&details=$details');


        debugPrint(' url $url');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return AdjustBankResponse.fromJson(decoded);
      } else {
        debugPrint("Failed to post adjustment: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception in bank adjustment post: $e");
      return null;
    }
  }



  ///delete bank
  Future<bool> deleteBankVoucher(int bankId) async {
  final url =
      Uri.parse('https://commercebook.site/api/v1/account/bank/remove/?id=$bankId');

  try {
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        await fetchBankAccounts(); // Refresh list after delete
        return true;
      } else {
        debugPrint("Delete failed: ${data['message']}");
        return false;
      }
    } else {
      debugPrint("Failed to delete: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    debugPrint("Error deleting bank voucher: $e");
    return false;
  }
}


///accounht bank
  
  BankAdjustmentResponse? bankAdjustmentModel;

  Future<void> fetchBankAdjustments() async {
    _isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/accounts/bank';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        bankAdjustmentModel = BankAdjustmentResponse.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint("BankAdjustmentProvider error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }



}
