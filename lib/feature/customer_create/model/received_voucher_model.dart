// In your ReceivedVoucherCustomer model class, fix the parsing like this:

class ReceivedVoucherCustomer {
  final int id;
  final String billNumber;
  final String purchaseDate;
  final String voucherDate;
  final double grossTotal;
  final double due; // Make sure this is double

  ReceivedVoucherCustomer({
    required this.id,
    required this.billNumber,
    required this.purchaseDate,
    required this.voucherDate,
    required this.grossTotal,
    required this.due,
  });

  factory ReceivedVoucherCustomer.fromJson(Map<String, dynamic> json) {
    return ReceivedVoucherCustomer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      billNumber: json['bill_number']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString() ?? '',
      voucherDate: json['voucher_date']?.toString() ?? 'N/A',
      
      // ✅ Fixed: Handle both string and number for grossTotal
      grossTotal: _parseToDouble(json['gross_total']),
      
      // ✅ Fixed: Handle both string and number for due
      due: _parseToDouble(json['due']),
    );
  }

  // ✅ Helper method to safely parse string or number to double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_number': billNumber,
      'purchase_date': purchaseDate,
      'voucher_date': voucherDate,
      'gross_total': grossTotal,
      'due': due,
    };
  }
}




// // models/payment_voucher_model.dart
// class ReceivedVoucherCustomer {
//   final int id;
//   final String billNumber;
//   final String purchaseDate;
//   final String voucherDate;
//   final double grossTotal;
//   final double due;

//   ReceivedVoucherCustomer({
//     required this.id,
//     required this.billNumber,
//     required this.purchaseDate,
//     required this.voucherDate,
//     required this.grossTotal,
//     required this.due,
//   });

//   factory ReceivedVoucherCustomer.fromJson(Map<String, dynamic> json) {
//     return ReceivedVoucherCustomer(
//       id: json['id'],
//       billNumber: json['bill_number'],
//       purchaseDate: json['purchase_date'],
//       voucherDate: json['voucher_date'],
//       grossTotal: (json['gross_total'] as num).toDouble(),
//       due: (json['due'] as num).toDouble(),
//     );
//   }
// }
