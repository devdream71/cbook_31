import 'package:flutter/material.dart';

class ReceiveVoucherModel {
  final int id;
  final int userId;
  final String? voucherDate;
  final String voucherNumber;
  final String customer;
  final double totalAmount;
  final List<VoucherDetail> voucherDetails;

  ReceiveVoucherModel({
    required this.id,
    required this.userId,
    required this.voucherDate,
    required this.voucherNumber,
    required this.customer,
    required this.totalAmount,
    required this.voucherDetails,
  });

  factory ReceiveVoucherModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReceiveVoucherModel(
        id: _parseInt(json['id']),
        userId: _parseInt(json['user_id']),
        voucherDate: json['voucher_date']?.toString(),
        voucherNumber: json['voucher_number']?.toString() ?? '',
        customer: json['customer']?.toString() ?? '',
        totalAmount: _parseDouble(json['total_amount']),
        voucherDetails: _parseVoucherDetails(json['voucher_details']),
      );
    } catch (e) {
     // debugPrint('Error parsing ReceiveVoucherModel: $e');
     // debugPrint('JSON data: $json');
      rethrow;
    }
  }

  // Helper method to parse voucher details safely
  static List<VoucherDetail> _parseVoucherDetails(dynamic details) {
    if (details == null) return [];
    if (details is! List) return [];
    
    try {
      return details
          .map((item) => VoucherDetail.fromJson(item))
          .toList();
    } catch (e) {
      //debugPrint('Error parsing voucher details: $e');
      return [];
    }
  }

  // Helper methods for safe parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'voucher_date': voucherDate,
      'voucher_number': voucherNumber,
      'customer': customer,
      'total_amount': totalAmount,
      'voucher_details': voucherDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

class VoucherDetail {
  final int id;
  final String type;
  final int voucherId;
  final int purchaseId;
  final String? narration;
  final double amount;

  VoucherDetail({
    required this.id,
    required this.type,
    required this.voucherId,
    required this.purchaseId,
    required this.narration,
    required this.amount,
  });

  factory VoucherDetail.fromJson(Map<String, dynamic> json) {
    try {
      return VoucherDetail(
        id: ReceiveVoucherModel._parseInt(json['id']),
        type: json['type']?.toString() ?? '',
        voucherId: ReceiveVoucherModel._parseInt(json['voucher_id']),
        purchaseId: ReceiveVoucherModel._parseInt(json['purchase_id']),
        narration: json['narration']?.toString(),
        amount: ReceiveVoucherModel._parseDouble(json['amount']),
      );
    } catch (e) {
      //debugPrint('Error parsing VoucherDetail: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'voucher_id': voucherId,
      'purchase_id': purchaseId,
      'narration': narration,
      'amount': amount,
    };
  }
}



// class ReceiveVoucherModel {
//   final int id;
//   final int userId;
//   final String voucherDate;
//   final String voucherNumber;
//   final String customer;
//   final double totalAmount;
//   final List<VoucherDetail> voucherDetails;

//   ReceiveVoucherModel({
//     required this.id,
//     required this.userId,
//     required this.voucherDate,
//     required this.voucherNumber,
//     required this.customer,
//     required this.totalAmount,
//     required this.voucherDetails,
//   });

//   factory ReceiveVoucherModel.fromJson(Map<String, dynamic> json) {
//     return ReceiveVoucherModel(
//       id: json['id'],
//       userId: json['user_id'],
//       voucherDate: json['voucher_date'],
//       voucherNumber: json['voucher_number'],
//       customer: json['customer'],
//       totalAmount: (json['total_amount'] as num).toDouble(),
//       voucherDetails: (json['voucher_details'] as List)
//           .map((item) => VoucherDetail.fromJson(item))
//           .toList(),
//     );
//   }
// }

// class VoucherDetail {
//   final int id;
//   final String type;
//   final int voucherId;
//   final int purchaseId;
//   final String? narration;
//   final double amount;

//   VoucherDetail({
//     required this.id,
//     required this.type,
//     required this.voucherId,
//     required this.purchaseId,
//     required this.narration,
//     required this.amount,
//   });

//   factory VoucherDetail.fromJson(Map<String, dynamic> json) {
//     return VoucherDetail(
//       id: json['id'],
//       type: json['type'],
//       voucherId: json['voucher_id'],
//       purchaseId: json['purchase_id'],
//       narration: json['narration'],
//       amount: (json['amount'] as num).toDouble(),
//     );
//   }
// }
