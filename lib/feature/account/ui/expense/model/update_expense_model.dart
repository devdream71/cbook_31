class ExpenseEditModel {
  final int userId;
  final String type;
  final String voucherNumber;
  final String voucherDate;
  final String voucherTime;
  final String paidTo;
  final int accountId;
  final double totalAmount;
  final String? notes;
  final int billPersonId;
  final List<VoucherDetail> voucherDetails;

  ExpenseEditModel({
    required this.userId,
    required this.type,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.paidTo,
    required this.accountId,
    required this.totalAmount,
    required this.notes,
    required this.billPersonId,
    required this.voucherDetails,
  });

  factory ExpenseEditModel.fromJson(Map<String, dynamic> json) {
    return ExpenseEditModel(
      userId: json['user_id'],
      type: json['type'],
      voucherNumber: json['voucher_number'],
      voucherDate: json['voucher_date'],
      voucherTime: json['voucher_time'],
      paidTo: json['paid_to'],
      accountId: json['account_id'],
      totalAmount: json['total_amount'].toDouble(),
      notes: json['notes'],
      billPersonId: json['bill_person_id'],
      voucherDetails: (json['voucher_details'] as List)
          .map((e) => VoucherDetail.fromJson(e))
          .toList(),
    );
  }
}

class VoucherDetail {
  final int id;
  final String type;
  final int voucherId;
  final int purchaseId;
  final dynamic narration;
  final double amount;

  VoucherDetail({
    required this.id,
    required this.type,
    required this.voucherId,
    required this.purchaseId,
    this.narration,
    required this.amount,
  });

  factory VoucherDetail.fromJson(Map<String, dynamic> json) {
    return VoucherDetail(
      id: json['id'],
      type: json['type'],
      voucherId: json['voucher_id'],
      purchaseId: json['purchase_id'],
      narration: json['narration'],
      amount: json['amount'].toDouble(),
    );
  }
}
