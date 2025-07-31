class ReceiveVoucherModel {
  final int id;
  final int userId;
  final String voucherDate;
  final String voucherNumber;
  final String customer;
  final double totalAmount;
  final List<VoucherDetail> voucherDetails;

  ReceiveVoucherModel({
    required this.id,
    required this.userId,
    required this.voucherDate,
    required this.voucherNumber,
    required this.customer,
    required this.totalAmount,
    required this.voucherDetails,
  });

  factory ReceiveVoucherModel.fromJson(Map<String, dynamic> json) {
    return ReceiveVoucherModel(
      id: json['id'],
      userId: json['user_id'],
      voucherDate: json['voucher_date'],
      voucherNumber: json['voucher_number'],
      customer: json['customer'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      voucherDetails: (json['voucher_details'] as List)
          .map((item) => VoucherDetail.fromJson(item))
          .toList(),
    );
  }
}

class VoucherDetail {
  final int id;
  final String type;
  final int voucherId;
  final int purchaseId;
  final String? narration;
  final double amount;

  VoucherDetail({
    required this.id,
    required this.type,
    required this.voucherId,
    required this.purchaseId,
    required this.narration,
    required this.amount,
  });

  factory VoucherDetail.fromJson(Map<String, dynamic> json) {
    return VoucherDetail(
      id: json['id'],
      type: json['type'],
      voucherId: json['voucher_id'],
      purchaseId: json['purchase_id'],
      narration: json['narration'],
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
