class PaymentVoucherModel {
  final int id;
  final int userId;
  final String voucherDate;
  final String voucherNumber;
  final String customer;
  final double totalAmount;

  PaymentVoucherModel({
    required this.id,
    required this.userId,
    required this.voucherDate,
    required this.voucherNumber,
    required this.customer,
    required this.totalAmount,
  });

  factory PaymentVoucherModel.fromJson(Map<String, dynamic> json) {
    return PaymentVoucherModel(
      id: json['id'],
      userId: json['user_id'],
      voucherDate: json['voucher_date'],
      voucherNumber: json['voucher_number'],
      customer: json['customer'],
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }
}




// class PaymentVoucherModel {
//   final int userId;
//   final int id;
//   final String voucherDate;
//   final String voucherNumber;
//   final String customer;
//   final double totalAmount;

//   PaymentVoucherModel({
//     required this.id,
//     required this.userId,
//     required this.voucherDate,
//     required this.voucherNumber,
//     required this.customer,
//     required this.totalAmount,
//   });

//   factory PaymentVoucherModel.fromJson(Map<String, dynamic> json) {
//     return PaymentVoucherModel(
//       id: json['id'],
//       userId: json['user_id'],
//       voucherDate: json['voucher_date'],
//       voucherNumber: json['voucher_number'],
//       customer: json['customer'],
//       totalAmount: (json['total_amount'] as num).toDouble(),
//     );
//   }
// }


