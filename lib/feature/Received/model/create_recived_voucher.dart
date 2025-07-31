class ReceivedVoucherItem {
  final String salesId;
  final String amount;

  ReceivedVoucherItem({
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


class ReceivedVoucherRequest {
  final int userId;
  final int voucherPerson;
  final int custoerID;
  final String voucherNumber;
  final String voucherDate; // yyyy-MM-dd
  final String voucherTime; // HH:mm:ss
  final dynamic receivedTo;  // "cash" or "bank"
  final int accountId;
  final dynamic receivedFrom;
  final String percent;     // "percent" or "flat"
  final double totalAmount;
  final double discount;
  final String notes;
  final List<ReceivedVoucherItem> voucherItems;

  ReceivedVoucherRequest({
    required this.userId,
    required this.voucherPerson,
    required this.custoerID,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.accountId,
    required this.receivedFrom,
    required this.percent,
    required this.totalAmount,
    required this.discount,
    required this.notes,
    required this.voucherItems,
  });

  /// URL query parameters
  Map<String, String> toQueryParameters() {
    return {
      'user_id': userId.toString(),
      'voucher_person': voucherPerson.toString(),
      'customer_id' : custoerID.toString(),
      'voucher_number': voucherNumber,
      'voucher_date': voucherDate,
      'voucher_time': voucherTime,
      'received_to': receivedTo,
      'account_id': accountId.toString(),
      'received_from': receivedFrom.toString(),
      'percent': percent,
      'total_amount': totalAmount.toStringAsFixed(2),
      'discount': discount.toStringAsFixed(2),
      'notes': notes,
    };
  }

  /// Body payload
  Map<String, dynamic> toJson() {
    return {
      'voucher_items': voucherItems.map((item) => item.toJson()).toList(),
    };
  }
}
