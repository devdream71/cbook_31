// income_provider.dart
import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/expense/model/income_edit_model.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/receive_from_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/account_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/account_type_name_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/edit_income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_edit_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_list_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_form_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IncomeProvider with ChangeNotifier {
  IncomeListModel? incomeModel;
  bool isLoading = false;

  AccountModel? accountModel;
  List<String> accountNames = [];
  bool isAccountLoading = false;

  Map<String, int> receiptFromMap = {};

  // Receipt From API
  ReceiptFromModel? receiptFromModel;
  List<String> receiptFromNames = [];
  bool isReceiptLoading = false;

  List<ReceiptItem> receiptItems = [];

  void addReceiptItem(ReceiptItem item) {
    receiptItems.add(item);

    // If it's a new "receiptFrom", add it to the list
    if (!receiptFromNames.contains(item.receiptFrom)) {
      receiptFromNames.add(item.receiptFrom);
    }

    notifyListeners();
  }

  void clearReceiptItems() {
    receiptItems.clear();
    notifyListeners();
  }

  double get totalAmount {
    return editIncomeItems.fold(0.0, (sum, item) {
      return sum + (item.amount.toDouble());
    });
  }

  // Add this property for selected account during updates
  AccountData? selectedAccountForUpdate;

  // Add this property for selected received form during updates
  ReceiptFromData? selectedReceivedFormForUpdate;

  // Method to set selected account for update
  void setSelectedAccountForUpdate(AccountData? account) {
    selectedAccountForUpdate = account;
    notifyListeners();
  }

  // Method to set selected received form for update
  void setSelectedReceivedFormForUpdate(ReceiptFromData? receivedForm) {
    selectedReceivedFormForUpdate = receivedForm;
    notifyListeners();
  }

  ///recived form
  Future<void> fetchReceiptFromList() async {
    debugPrint('=== Starting fetchReceiptFromList ===');

    isReceiptLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/income/receive/form/list';

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        receiptFromModel = ReceiptFromModel.fromJson(data);
        receiptFromNames =
            receiptFromModel!.data.map((e) => e.accountName).toList();

        // Populate map here
        receiptFromMap = {
          for (var e in receiptFromModel!.data) e.accountName: e.id,
        };

        debugPrint('Receipt From Map: $receiptFromMap');

        debugPrint('Fetched Receipt From Names: $receiptFromNames');
      } else {
        debugPrint('API Error: Status ${response.statusCode}');
        receiptFromModel = null;
        receiptFromNames = [];
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
      receiptFromModel = null;
      receiptFromNames = [];
    }

    isReceiptLoading = false;
    debugPrint('=== fetchReceiptFromList completed ===');
    notifyListeners();
  }

  /// fetch account
  Future<void> fetchAccounts(String type) async {
    debugPrint('=== Starting fetchAccounts for type: $type ===');

    isAccountLoading = true;
    notifyListeners();

    final url =
        'https://commercebook.site/api/v1/receive/form/account?type=$type';
    debugPrint('API URL: $url');

    try {
      debugPrint('Making API request...');
      final response = await http.post(Uri.parse(url));

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      debugPrint('response Status code');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed JSON Data: $data');

        accountModel = AccountModel.fromJson(data);
        accountNames = accountModel!.data.map((e) => e.accountName).toList();

        debugPrint('Account Model Created Successfully');
        debugPrint('Total Accounts Found: ${accountModel!.data.length}');
        debugPrint('Account Names: $accountNames');

        // Print detailed account info
        for (int i = 0; i < accountModel!.data.length; i++) {
          final account = accountModel!.data[i];
          debugPrint(
              'Account $i: ID=${account.id}, Name=${account.accountName}');
        }
      } else {
        debugPrint('API Error: Status ${response.statusCode}');
        debugPrint('Error Body: ${response.body}');

        // Clear previous data on error
        accountModel = null;
        accountNames = [];
      }
    } catch (e, st) {
      debugPrint('Exception occurred: $e');
      debugPrint(st.toString());
      debugPrint('Stack trace: ${StackTrace.current}');

      debugPrint('❌ Exception: $e');

      // Clear data on exception
      accountModel = null;
      accountNames = [];
    }

    isAccountLoading = false;
    debugPrint(
        '=== fetchAccounts completed. Loading state: $isAccountLoading ===');
    notifyListeners();
  }


    
  String totalIncome = '0.00';


  ///income list. all
  Future<void> fetchIncomeList() async {
    isLoading = true;
    //notifyListeners();

    const url = 'https://commercebook.site/api/v1/income/list';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        incomeModel = IncomeListModel.fromJson(data);
        totalIncome = incomeModel?.totalIncome ?? '0.00';
      }
    } catch (e) {
      debugPrint('Error: $e');
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
    final bankUrl = 'https://commercebook.site/api/v1/receive/form/account?type=bank';
    final cashUrl = 'https://commercebook.site/api/v1/receive/form/account?type=cash';

    final bankResponse = await http.post(Uri.parse(bankUrl));
    final cashResponse = await http.post(Uri.parse(cashUrl));

    if (bankResponse.statusCode == 200) {
      final data = json.decode(bankResponse.body);
      final accounts = List<AccountTypeNameModel>.from(data['data'].map((e) => AccountTypeNameModel.fromJson(e)));
      for (var acc in accounts) {
        _accountNameMap[acc.id] = acc.name;
      }
    }

    if (cashResponse.statusCode == 200) {
      final data = json.decode(cashResponse.body);
      final accounts = List<AccountTypeNameModel>.from(data['data'].map((e) => AccountTypeNameModel.fromJson(e)));
      for (var acc in accounts) {
        _accountNameMap[acc.id] = acc.name;
      }
    }
  } catch (e) {
    debugPrint('Error fetching accounts: $e');
  }

  notifyListeners();
}





  ///delete income. ====>>>>>>><<<<<<
  Future<void> deleteIncome(String id) async {
    final url = 'https://commercebook.site/api/v1/income/remove?id=$id';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        incomeModel?.data
            .removeWhere((income) => income.id.toString() == id); // ✅ Correct
        notifyListeners(); // This will refresh the UI
      } else {
        debugPrint('Failed to delete income');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  ///create the income.
  Future<bool> storeIncome({
    required String userId,
    required String invoiceNo,
    required String date,
    required String receivedTo,
    required String account,
    required double totalAmount,
    required String notes,
    required int status,
    required List<IncomeItem> incomeItems,
    required String billPersonID,
  }) async {
    final url = Uri.parse('https://commercebook.site/api/v1/income/store?'
        'user_id=$userId&invoice_no=$invoiceNo&date=$date&received_to=$receivedTo&account=$account&total_amount=$totalAmount&notes=$notes&status=$status&bill_person_id=$billPersonID');

    final body = IncomeStoreRequest(incomeItems: incomeItems).toJson();

    debugPrint(url.toString());
    debugPrint(body.toString());

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
        debugPrint('Failed to store income: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error storing income: $e');
      return false;
    }
  }

  ///edit data

  ///income update
  IncomeEditModel? editIncomeData;

  ///update income.
  Future<bool> updateIncome({
    required String incomeId,
    required String userId,
    required String invoiceNo,
    required String date,
    required String receivedTo,
    required String account,
    required dynamic totalAmount,
    required String notes,
    //required int status,
    required List<IncomeItem> incomeItems,
  }) async {
    final url = Uri.parse('https://commercebook.site/api/v1/income/update?'
        'id=$incomeId&user_id=$userId&invoice_no=$invoiceNo&date=$date&received_to=$receivedTo&account=$account&total_amount=$totalAmount&notes=$notes');

    final body = IncomeStoreRequest(incomeItems: incomeItems).toJson();

    debugPrint('=== Income Update API Call ===');
    debugPrint('URL: $url');
    debugPrint('Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Income updated successfully');
        return true;
      } else {
        debugPrint('❌ Failed to update income: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating income: $e');
      return false;
    }
  }

  ////edit income by id
  List<EditIncomeItem> editIncomeItems =
      []; // This avoids the receiptItems conflict
  IncomeVoucherData? editIncomeDataItem;

  Future<void> fetchEditIncome(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://commercebook.site/api/v1/income/edit/$id'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final responseModel = EditIncomeVoucherResponse.fromJson(result);
        editIncomeDataItem = responseModel.data;

        if (editIncomeDataItem != null) {
          // Use a separate list
          editIncomeItems = editIncomeDataItem!.voucherDetails.map((detail) {
            return EditIncomeItem(
              purchaseId: detail.purchaseId,
              receiptFrom: editIncomeDataItem!.receivedTo,
              note: detail.narration,
              amount: detail.amount,
            );
          }).toList();
        }
      } else {
        debugPrint('Failed to load expense edit data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching expense edit data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ✅ API Fetch Method ///expense Paid From list

  List<ReceiveFromItem> receiveFormList = []; // ✅ Fixed

  Future<void> fetchReceiveFormList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://commercebook.site/api/v1/income/receive/form/list'));

      if (response.statusCode == 200) {
        final result = ReceiveFromModel.fromJson(json.decode(response.body));
        receiveFormList = result.data; // ✅ Now this works correctly
      } else {
        debugPrint('Failed to load receive form list');
      }
    } catch (e) {
      debugPrint('Error fetching receive form list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///getting expemse paid form list
  String getAccountNameById(int id) {
    try {
      return receiveFormList
          .firstWhere((element) => element.id == id)
          .accountName;
    } catch (e) {
      return 'Unknown'; // fallback if ID not found
    }
  }
}
