class BankBalanceModel {
  final bool success;
  final String message;
  final int data;

  BankBalanceModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BankBalanceModel.fromJson(Map<String, dynamic> json) {
    return BankBalanceModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? 0,
    );
  }
}
