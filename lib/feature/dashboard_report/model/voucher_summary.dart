class VoucherSummary {
  final int received;
  final int payment;
  final int income;
  final int expense;

  VoucherSummary({
    required this.received,
    required this.payment,
    required this.income,
    required this.expense,
  });

  factory VoucherSummary.fromJson(Map<String, dynamic> json) {
    return VoucherSummary(
      received: json['received'] ?? 0,
      payment: json['payment'] ?? 0,
      income: json['income'] ?? 0,
      expense: json['expense'] ?? 0,
    );
  }
}