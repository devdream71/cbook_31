import 'package:flutter/material.dart';

class ExpenseListModel {
  bool success;
  String message;
  List<ExpenseData> data;
  String totalExpense; // Changed to String for consistency

  ExpenseListModel({
    required this.success,
    required this.message,
    required this.data,
    required this.totalExpense,
  });

  factory ExpenseListModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawData = json['data'] ?? [];
    List<ExpenseData> expenseDataList = [];
    String total = '0.00';

    // Process the data array
    for (var item in rawData) {
      if (item is Map<String, dynamic>) {
        if (item.containsKey('id')) {
          // This is an expense record
          try {
            expenseDataList.add(ExpenseData.fromJson(item));
          } catch (e) {
            debugPrint('Error parsing expense item: $e');
            debugPrint('Problematic item: $item');
          }
        } else if (item.containsKey('total_expense')) {
          // This is the total expense summary
          total = item['total_expense']?.toString() ?? '0.00';
        }
      }
    }

    return ExpenseListModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: expenseDataList,
      totalExpense: total,
    );
  }
}

class ExpenseData {
  int id;
  String type;
  String voucherNumber;
  String voucherDate;
  String voucherTime;
  String receivedTo;
  double totalAmount; // Changed to double for proper handling
  String notes;
  int accountID;

  ExpenseData({
    required this.id,
    required this.type,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.totalAmount,
    required this.notes,
    required this.accountID,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: _parseInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      voucherNumber: json['voucher_number']?.toString() ?? '',
      voucherDate: json['voucher_date']?.toString() ?? '',
      voucherTime: json['voucher_time']?.toString() ?? '',
      receivedTo: json['received_to']?.toString() ?? '',
      totalAmount: _parseDouble(json['total_amount']) ?? 0.0, // Fixed: Parse as double
      notes: json['notes']?.toString() ?? '',
      accountID: _parseInt(json['account_id']) ?? 0,
    );
  }

  // Helper method to safely parse integers
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method to safely parse doubles
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'voucher_number': voucherNumber,
      'voucher_date': voucherDate,
      'voucher_time': voucherTime,
      'received_to': receivedTo,
      'total_amount': totalAmount,
      'notes': notes,
      'account_id': accountID,
    };
  }

  @override
  String toString() {
    return 'ExpenseData(id: $id, voucherNumber: $voucherNumber, totalAmount: $totalAmount)';
  }
}


// class ExpenseListModel {
//   bool success;
//   String message;
//   List<ExpenseData> data;
//   dynamic totalExpense;

//   ExpenseListModel({
//     required this.success,
//     required this.message,
//     required this.data,
//     required this.totalExpense,
//   });

//   factory ExpenseListModel.fromJson(Map<String, dynamic> json) {
//     List<dynamic> rawData = json['data'] ?? [];
//     List<ExpenseData> expenseDataList = [];
//     String total = '0.00';

//     for (var item in rawData) {
//       if (item is Map<String, dynamic> && item.containsKey('id')) {
//         expenseDataList.add(ExpenseData.fromJson(item));
//       } else if (item is Map<String, dynamic> && item.containsKey('total_expense')) {
//         total = item['total_expense'] ?? '0.00';
//       }
//     }

//     return ExpenseListModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: expenseDataList,
//       totalExpense: total,
//     );
//   }
// }

// class ExpenseData {
//   int id;
//   String type;
//   String voucherNumber;
//   String voucherDate;
//   String voucherTime;
//   String receivedTo;
//   int totalAmount;
//   String notes;
//   int accountID;

//   ExpenseData({
//     required this.id,
//     required this.type,
//     required this.voucherNumber,
//     required this.voucherDate,
//     required this.voucherTime,
//     required this.receivedTo,
//     required this.totalAmount,
//     required this.notes,
//     required this.accountID,
//   });

//   factory ExpenseData.fromJson(Map<String, dynamic> json) {
//     return ExpenseData(
//       id: json['id'],
//       type: json['type'] ?? '',
//       voucherNumber: json['voucher_number'] ?? '',
//       voucherDate: json['voucher_date'] ?? '',
//       voucherTime: json['voucher_time'] ?? '',
//       receivedTo: json['received_to'] ?? '',
//       totalAmount: json['total_amount'] ?? 0,
//       notes: json['notes'] ?? '',
//       accountID: json['account_id'],
//     );
//   }
// }
