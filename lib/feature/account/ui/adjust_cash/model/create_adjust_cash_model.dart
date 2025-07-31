class AdjustCashResponse {
  final bool success;
  final String message;
  final AdjustCashData? data;

  AdjustCashResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdjustCashResponse.fromJson(Map<String, dynamic> json) {
    return AdjustCashResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? AdjustCashData.fromJson(json['data']) : null,
    );
  }
}

class AdjustCashData {
  final String type;
  final String userId;
  final String voucherDate;
  final String totalAmount;
  final String accountId;
  final String notes;
  final int id;

  AdjustCashData({
    required this.type,
    required this.userId,
    required this.voucherDate,
    required this.totalAmount,
    required this.accountId,
    required this.notes,
    required this.id,
  });

  factory AdjustCashData.fromJson(Map<String, dynamic> json) {
    return AdjustCashData(
      type: json['type'],
      userId: json['user_id'],
      voucherDate: json['voucher_date'],
      totalAmount: json['total_amount'],
      accountId: json['account_id'],
      notes: json['notes'],
      id: json['id'],
    );
  }
}
