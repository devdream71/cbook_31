class PaymentVoucherCustomer {
  final int id;
  final String billNumber;
  final String purchaseDate;
  final String voucherDate;
  final double grossTotal;
  final double receiptAmount;
  final double due;

  PaymentVoucherCustomer({
    required this.id,
    required this.billNumber,
    required this.purchaseDate,
    required this.voucherDate,
    required this.grossTotal,
    required this.receiptAmount,
    required this.due,
  });

  factory PaymentVoucherCustomer.fromJson(Map<String, dynamic> json) {
    return PaymentVoucherCustomer(
      id: _parseToInt(json['id']) ?? 0,
      billNumber: json['bill_number']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString() ?? '',
      voucherDate: json['voucher_date']?.toString() ?? 'N/A',
      grossTotal: _parseToDouble(json['gross_total']) ?? 0.0, // ✅ Safe conversion
      receiptAmount: _parseToDouble(json['receipt_amount']) ?? 0.0, // ✅ Safe conversion
      due: _parseToDouble(json['due']) ?? 0.0, // ✅ Safe conversion
    );
  }

  // ✅ Helper method for safe double parsing
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove any currency symbols or spaces before parsing
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  // ✅ Helper method for safe int parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'PaymentVoucherCustomer{id: $id, billNumber: $billNumber, grossTotal: $grossTotal, due: $due}';
  }
}



// //models/payment_voucher_model.dart
// class PaymentVoucherCustomer {
//   final int id;
//   final String billNumber;
//   final String purchaseDate;
//   final String voucherDate;
//   final double grossTotal;
//   final double due;

//   PaymentVoucherCustomer({
//     required this.id,
//     required this.billNumber,
//     required this.purchaseDate,
//     required this.voucherDate,
//     required this.grossTotal,
//     required this.due,
//   });

//   factory PaymentVoucherCustomer.fromJson(Map<String, dynamic> json) {
//     return PaymentVoucherCustomer(
//         id: json['id'],
//       billNumber: json['bill_number'],
//       purchaseDate: json['purchase_date'],
//       voucherDate: json['voucher_date'],
//       grossTotal: (json['gross_total'] as num).toDouble(),
//       due: (json['due'] as num).toDouble(),
//     );
//   }
// }


 