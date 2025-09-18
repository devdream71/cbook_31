class PaymentVoucherModel {
  final int id;
  final int userId;
  final String? voucherDate;
  final String voucherNumber;
  final String customer;
  final double totalAmount;
  final List<VoucherDetail>? voucherDetails;

  PaymentVoucherModel({
    required this.id,
    required this.userId,
    this.voucherDate,
    required this.voucherNumber,
    required this.customer,
    required this.totalAmount,
    this.voucherDetails,
  });

  factory PaymentVoucherModel.fromJson(Map<String, dynamic> json) {
    return PaymentVoucherModel(
      id: _parseToInt(json['id']) ?? 0,
      userId: _parseToInt(json['user_id']) ?? 0,
      voucherDate: json['voucher_date']?.toString(),
      voucherNumber: json['voucher_number']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      totalAmount: _parseToDouble(json['total_amount']) ?? 0.0, // ✅ Safe conversion
      voucherDetails: json['voucher_details'] != null
          ? (json['voucher_details'] as List)
              .map((detail) => VoucherDetail.fromJson(detail))
              .toList()
          : null,
    );
  }

  // ✅ Helper method for safe double parsing
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ✅ Helper method for safe int parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class VoucherDetail {
  final int id;
  final int companyId;
  final int userId;
  final String type;
  final int voucherId;
  final int? purchaseId;
  final String? voucherDate;
  final String? narration;
  final double amount;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  VoucherDetail({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.type,
    required this.voucherId,
    this.purchaseId,
    this.voucherDate,
    this.narration,
    required this.amount,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory VoucherDetail.fromJson(Map<String, dynamic> json) {
    return VoucherDetail(
      id: PaymentVoucherModel._parseToInt(json['id']) ?? 0,
      companyId: PaymentVoucherModel._parseToInt(json['company_id']) ?? 0,
      userId: PaymentVoucherModel._parseToInt(json['user_id']) ?? 0,
      type: json['type']?.toString() ?? '',
      voucherId: PaymentVoucherModel._parseToInt(json['voucher_id']) ?? 0,
      purchaseId: PaymentVoucherModel._parseToInt(json['purchase_id']),
      voucherDate: json['voucher_date']?.toString(),
      narration: json['narration']?.toString(),
      amount: PaymentVoucherModel._parseToDouble(json['amount']) ?? 0.0, // ✅ Safe conversion
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}



// class PaymentVoucherModel {
//   final int id;
//   final int userId;
//   final String voucherDate;
//   final String voucherNumber;
//   final String customer;
//   final double totalAmount;

//   PaymentVoucherModel({
//     required this.id,
//     required this.userId,
//     required this.voucherDate,
//     required this.voucherNumber,
//     required this.customer,
//     required this.totalAmount,
//   });

//   factory PaymentVoucherModel.fromJson(Map<String, dynamic> json) {
//     return PaymentVoucherModel(
//       id: json['id'],
//       userId: json['user_id'],
//       voucherDate: json['voucher_date'],
//       voucherNumber: json['voucher_number'],
//       customer: json['customer'],
//       totalAmount: (json['total_amount'] as num).toDouble(),
//     );
//   }
// }




