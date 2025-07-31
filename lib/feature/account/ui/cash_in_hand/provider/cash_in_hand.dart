import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/model/cash_in_hand.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 

class CashInHandProvider extends ChangeNotifier {
  CashInHandModel? cashInHandModel;
  bool isLoading = false;

  ///show cash in hand
  Future<void> fetchCashInHandData() async {
    isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/accounts/cash-in/hand';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        cashInHandModel = CashInHandModel.fromJson(data);
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    isLoading = false;
    notifyListeners();
  }


  ///delet cash in hand.
  Future<bool> deleteCashInHand(int id) async {
  final url = 'https://commercebook.site/api/v1/account/cash-in/hand/remove/?id=$id';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        // Optionally refresh list after delete
        await fetchCashInHandData();
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
    debugPrint("Error during delete: $e");
    return false;
  }
}



}
