class AdjustBankResponse {
  final bool success;
  final String message;
  final AdjustBankData? data;

  AdjustBankResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdjustBankResponse.fromJson(Map<String, dynamic> json) {
    return AdjustBankResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? AdjustBankData.fromJson(json['data']) : null,
    );
  }
}

class AdjustBankData {
  final int id;
  final String type;
  final String userId;
  final String voucherDate;
  final String totalAmount;

  AdjustBankData({
    required this.id,
    required this.type,
    required this.userId,
    required this.voucherDate,
    required this.totalAmount,
  });

  factory AdjustBankData.fromJson(Map<String, dynamic> json) {
    return AdjustBankData(
      id: json['id'],
      type: json['type'],
      userId: json['user_id'],
      voucherDate: json['voucher_date'],
      totalAmount: json['total_amount'],
    );
  }
}
