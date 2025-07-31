class EditIncomeVoucherResponse {
  final bool success;
  final String message;
  final IncomeVoucherData? data;

  EditIncomeVoucherResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EditIncomeVoucherResponse.fromJson(Map<String, dynamic> json) {
    return EditIncomeVoucherResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? IncomeVoucherData.fromJson(json['data']) : null,
    );
  }
}


class IncomeVoucherData {
  final int userId;
  final int billPersonId;
  final String type;
  final String voucherNumber;
  final String voucherDate;
  final String voucherTime;
  final String receivedTo;
  final int accountId;
  final int totalAmount;
  final dynamic notes;
  final List<VoucherDetail> voucherDetails;

  IncomeVoucherData({
    required this.userId,
    required this.billPersonId,
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

  factory IncomeVoucherData.fromJson(Map<String, dynamic> json) {
    return IncomeVoucherData(
      userId: json['user_id'],
      billPersonId: json['bill_person_id'],
      type: json['type'],
      voucherNumber: json['voucher_number'],
      voucherDate: json['voucher_date'],
      voucherTime: json['voucher_time'],
      receivedTo: json['received_to'],
      accountId: json['account_id'],
      totalAmount: json['total_amount'],
      notes: json['notes'],
      voucherDetails: (json['voucher_details'] as List<dynamic>?)
              ?.map((e) => VoucherDetail.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class VoucherDetail {
  final int id;
  final String type;
  final int voucherId;
  final int purchaseId;
  final dynamic narration;
  final int amount;
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
}

