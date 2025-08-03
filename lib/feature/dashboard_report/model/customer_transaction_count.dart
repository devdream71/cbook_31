class CustomerTransactionCountModel {
  final bool success;
  final dynamic message;
  final int data;

  CustomerTransactionCountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerTransactionCountModel.fromJson(Map<String, dynamic> json) {
    return CustomerTransactionCountModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] ?? 0,
    );
  }
}
