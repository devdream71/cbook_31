class CustomerTransactionModel {
  final int data;

  CustomerTransactionModel({required this.data});

  factory CustomerTransactionModel.fromJson(Map<String, dynamic> json) {
    return CustomerTransactionModel(
      data: json['data'] ?? 0,
    );
  }
}
