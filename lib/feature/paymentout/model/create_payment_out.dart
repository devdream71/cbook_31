class VoucherItem {
  final String salesId;
  final String amount;

  VoucherItem({
    required this.salesId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'sales_id': salesId,
      'amount': amount,
    };
  }
}

class PaymentVoucherRequest {
  final int userId;
  final int customerId;
  final int voucherPerson;
  final String voucherNumber;
  final String voucherDate; // format: yyyy-MM-dd
  final String voucherTime; // format: HH:mm:ss
  final String paymentForm; // e.g., "cash"
  final int accountId;
  final int paymentTo;
  final String percent; // e.g. "percent" or "flat"
  final double totalAmount;
  final double discount;
  final String notes;
  final List<VoucherItem> voucherItems;

  PaymentVoucherRequest({
    required this.userId,
    required this.customerId,
    required this.voucherPerson,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.paymentForm,
    required this.accountId,
    required this.paymentTo,
    required this.percent,
    required this.totalAmount,
    required this.discount,
    required this.notes,
    required this.voucherItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'voucher_items': voucherItems.map((item) => item.toJson()).toList(),
    };
  }

  /// Build URL query parameters string for GET request URL
  Map<String, String> toQueryParameters() {
    return {
      'user_id': userId.toString(),
      'customer_id': customerId.toString(),
      'voucher_person': voucherPerson.toString(),
      'voucher_number': voucherNumber,
      'voucher_date': voucherDate,
      'voucher_time': voucherTime,
      'payment_form': paymentForm,
      'account_id': accountId.toString(),
      'payment_to': paymentTo.toString(),
      'percent': percent,
      'total_amount': totalAmount.toStringAsFixed(2),
      'discount': discount.toStringAsFixed(2),
      'notes': notes,
    };
  }
}
