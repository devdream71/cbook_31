// // supplier_transaction_model.dart
// class SupplierTransactionModel {
//   final dynamic data;

//   SupplierTransactionModel({required this.data});

//   factory SupplierTransactionModel.fromJson(Map<String, dynamic> json) {
//     return SupplierTransactionModel(data: json['data'] ?? 0);
//   }
// }


class SupplierTransactionModel {
  final double data;

  SupplierTransactionModel({required this.data});

  factory SupplierTransactionModel.fromJson(Map<String, dynamic> json) {
    // Convert to double safely
    double rawValue = (json['data'] ?? 0).toDouble();

    // Format to 2 decimals, then parse back to double
    double formattedValue = double.parse(rawValue.toStringAsFixed(2));

    return SupplierTransactionModel(data: formattedValue);
  }
}
