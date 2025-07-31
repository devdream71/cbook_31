import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_model.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_popup.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/update_expense_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/account_type_name_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpenseProvider with ChangeNotifier {
  List<PaidFormData> paidFormList = [];

  List<ExpenseItem> receiptItems = [];

  ExpenseListModel? expenseModel;

  bool isLoading = false;

  List<ExpenseData> expenseList = [];

  /// ✅ Add this for dynamic account selection
  PaidFormData? selectedAccountForUpdate;

  void addReceiptItem(ExpenseItem item) {
    receiptItems.add(item);
    notifyListeners();
  }

  void clearReceiptItems() {
    receiptItems.clear();
    //expenseList.clear();
    //paidFormList.clear();
    notifyListeners();
  }

  ///getting expemse paid form list
  String getAccountNameById(int id) {
    try {
      return paidFormList.firstWhere((element) => element.id == id).accountName;
    } catch (e) {
      return 'Unknown'; // fallback if ID not found
    }
  }

  String totalExpense = '0.00';

  ///expense list api call
  Future<void> fetchExpenseList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://commercebook.site/api/v1/expense/list'));

      if (response.statusCode == 200) {
        final result = ExpenseListModel.fromJson(json.decode(response.body));
        expenseList = result.data;

        totalExpense = result.totalExpense;
      } else {
        expenseList = [];
        debugPrint('Failed to load expense list');
      }
    } catch (e) {
      expenseList = [];
      debugPrint('Error fetching expense list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///acount type list bas on recived to , cash or bank

  Map<int, String> _accountNameMap = {};

  Map<int, String> get accountNameMap => _accountNameMap;

  /// Fetch accounts for both bank and cash once (or based on demand)
  Future<void> fetchAccountNames() async {
    try {
      final bankUrl =
          'https://commercebook.site/api/v1/receive/form/account?type=bank';
      final cashUrl =
          'https://commercebook.site/api/v1/receive/form/account?type=cash';

      final bankResponse = await http.post(Uri.parse(bankUrl));
      final cashResponse = await http.post(Uri.parse(cashUrl));

      if (bankResponse.statusCode == 200) {
        final data = json.decode(bankResponse.body);
        final accounts = List<AccountTypeNameModel>.from(
            data['data'].map((e) => AccountTypeNameModel.fromJson(e)));
        for (var acc in accounts) {
          _accountNameMap[acc.id] = acc.name;
        }
      }

      if (cashResponse.statusCode == 200) {
        final data = json.decode(cashResponse.body);
        final accounts = List<AccountTypeNameModel>.from(
            data['data'].map((e) => AccountTypeNameModel.fromJson(e)));
        for (var acc in accounts) {
          _accountNameMap[acc.id] = acc.name;
        }
      }
    } catch (e) {
      debugPrint('Error fetching accounts: $e');
    }

    notifyListeners();
  }

  ///expense update
  ExpenseEditModel? editExpenseData;

  ///expense update
  Future<void> fetchEditExpense(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://commercebook.site/api/v1/expense/edit/$id'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        editExpenseData = ExpenseEditModel.fromJson(result['data']);

        // Map API voucher details to receiptItems for showing in UI
        receiptItems = editExpenseData!.voucherDetails.map((detail) {
          return ExpenseItem(
            purchaseId: detail.purchaseId,
            receiptFrom: editExpenseData!.paidTo,
            note: detail.narration ?? '',
            amount: detail.amount,
          );
        }).toList();
      } else {
        debugPrint('Failed to load expense edit data');
      }
    } catch (e) {
      debugPrint('Error fetching expense edit data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///expense delete

  ///expense delete
  Future<void> deleteExpense(String id) async {
    final url = 'https://commercebook.site/api/v1/expense/remove?id=$id';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        // ✅ Correct: remove from the list you are displaying
        expenseList.removeWhere((expense) => expense.id.toString() == id);
        notifyListeners(); // This will refresh the UI
      } else {
        debugPrint('Failed to delete expense');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // ✅ API Fetch Method ///expense Paid From list
  Future<void> fetchPaidFormList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
          Uri.parse('https://commercebook.site/api/v1/expense/paid/form/list'));

      if (response.statusCode == 200) {
        final result = PaidFormModel.fromJson(json.decode(response.body));
        paidFormList = result.data;
      } else {
        debugPrint('Failed to load paid form list');
      }
    } catch (e) {
      debugPrint('Error fetching paid form list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///expense create.
  Future<bool> storeExpense({
    required String userId,
    required String invoiceNo,
    required String date,
    required String receivedTo,
    required String account,
    required double totalAmount,
    required String notes,
    required int status,
    required String billPersonId,
    required List<ExpenseItemPopUp> expenseItems,
  }) async {
    final url = Uri.parse('https://commercebook.site/api/v1/expense/store?'
        'user_id=$userId&expence_no=$invoiceNo&date=$date&paid_to=$receivedTo&account=$account&total_amount=$totalAmount&notes=$notes&status=$status&bill_person_id=$billPersonId');

    final body = ExpenseStoreRequest(expenseItems: expenseItems).toJson();

    debugPrint('url ${url.toString()}');

    debugPrint("body ${body.toString()}");

    debugPrint('===== STOP =====>');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // You can parse the response if needed
        return true;
      } else {
        debugPrint('Failed to store expense: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error storing express: $e');
      return false;
    }
  }

  Future<bool> updateExpense({
    required String expenseId,
    required String userId,
    required String invoiceNo,
    required String date,
    required String paidTo,
    required String account,
    required double totalAmount,
    required String notes,
    required int status,
    required int billPersonId,
    required List<ExpenseItemPopUp> expenseItems,
  }) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://commercebook.site/api/v1/expense/update?id=$expenseId&user_id=$userId&expence_no=$invoiceNo&date=$date&paid_to=$paidTo&account=$account&total_amount=$totalAmount&notes=$notes&status=$status&bill_person_id=$billPersonId');

    debugPrint("url ====> $url");

    final body = json.encode({
      'expense_items': expenseItems.map((e) => e.toJson()).toList(),
    });

    debugPrint('Sending Body: $body'); // ✅ Add this to see the payload

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint(
          'Response Status: ${response.statusCode}'); // ✅ Log status code
      debugPrint('Response Body: ${response.body}'); // ✅ Log response body

      if (response.statusCode == 200) {
        debugPrint('Expense updated successfully.');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to update expense.');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
