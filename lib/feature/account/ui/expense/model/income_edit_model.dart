class IncomeEditModel {
  final bool success;
  final String message;
  final IncomeData data;

  IncomeEditModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IncomeEditModel.fromJson(Map<String, dynamic> json) {
    return IncomeEditModel(
      success: json['success'],
      message: json['message'],
      data: IncomeData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class IncomeData {
  final int userId;
  final String type;
  final String voucherNumber;
  final String voucherDate;
  final String voucherTime;
  final String receivedTo;
  final int accountId;
  final num totalAmount;
  final String notes;
  final List<VoucherDetail> voucherDetails;

  IncomeData({
    required this.userId,
    required this.type,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.accountId,
    required this.totalAmount,
    required this.notes,
    required this.voucherDetails,
  });

  factory IncomeData.fromJson(Map<String, dynamic> json) {
    return IncomeData(
      userId: json['user_id'],
      type: json['type'],
      voucherNumber: json['voucher_number'],
      voucherDate: json['voucher_date'],
      voucherTime: json['voucher_time'],
      receivedTo: json['received_to'],
      accountId: json['account_id'],
      totalAmount: json['total_amount'],
      notes: json['notes'],
      voucherDetails: (json['voucher_details'] as List)
          .map((e) => VoucherDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': type,
        'voucher_number': voucherNumber,
        'voucher_date': voucherDate,
        'voucher_time': voucherTime,
        'received_to': receivedTo,
        'account_id': accountId,
        'total_amount': totalAmount,
        'notes': notes,
        'voucher_details': voucherDetails.map((e) => e.toJson()).toList(),
      };
}

class VoucherDetail {
  final int id;
  final String type;
  final int voucherId;
  final int purchaseId;
  final String narration;
  final num amount;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  VoucherDetail({
    required this.id,
    required this.type,
    required this.voucherId,
    required this.purchaseId,
    required this.narration,
    required this.amount,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VoucherDetail.fromJson(Map<String, dynamic> json) {
    return VoucherDetail(
      id: json['id'],
      type: json['type'],
      voucherId: json['voucher_id'],
      purchaseId: json['purchase_id'],
      narration: json['narration'],
      amount: json['amount'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'voucher_id': voucherId,
        'purchase_id': purchaseId,
        'narration': narration,
        'amount': amount,
        'deleted_at': deletedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
