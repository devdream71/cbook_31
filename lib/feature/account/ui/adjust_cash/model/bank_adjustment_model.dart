class BankAdjustmentResponse {
  final bool success;
  final String message;
  final List<BankAdjustmentData> data;

  BankAdjustmentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BankAdjustmentResponse.fromJson(Map<String, dynamic> json) {
    return BankAdjustmentResponse(
      success: json['success'],
      message: json['message'] ?? '',
      data: List<BankAdjustmentData>.from(
          json['data'].map((x) => BankAdjustmentData.fromJson(x))),
    );
  }
}

class BankAdjustmentData {
  final int ? id;
  final String? date;
  final String? billType;
  final String? billNumber;
  final String? account;
  final String? amount;

  BankAdjustmentData({
    this.id,
    this.date,
    this.billType,
    this.billNumber,
    this.account,
    this.amount,
  });

  factory BankAdjustmentData.fromJson(Map<String, dynamic> json) {
    return BankAdjustmentData(
      id: json['id'],
      date: json['date'],
      billType: json['bill_type'],
      billNumber: json['bill_number'],
      account: json['account'],
      amount: json['amount'],
    );
  }
}
