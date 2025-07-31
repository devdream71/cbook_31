// supplier_transaction_model.dart
class SupplierTransactionModel {
  final dynamic data;

  SupplierTransactionModel({required this.data});

  factory SupplierTransactionModel.fromJson(Map<String, dynamic> json) {
    return SupplierTransactionModel(data: json['data'] ?? 0);
  }
}