// // Create this model class for PaymentVoucherItem
// class PaymentVoucherItem {
//   final String salesId;
//   final String amount;

//   PaymentVoucherItem({
//     required this.salesId,
//     required this.amount,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'sales_id': salesId,
//       'amount': amount,
//     };
//   }

//   factory PaymentVoucherItem.fromJson(Map<String, dynamic> json) {
//     return PaymentVoucherItem(
//       salesId: json['sales_id']?.toString() ?? '',
//       amount: json['amount']?.toString() ?? '0',
//     );
//   }
// }


// // If you have a PaymentVoucherRequest class, it might look like this:
// class PaymentVoucherRequestUpdate {
//   final int userId;
//   final int customerId;
//   final int voucherPerson;
//   final String voucherNumber;
//   final String voucherDate;
//   final String voucherTime;
//   final String paymentForm;
//   final int accountId;
//   final int paymentTo;
//   final String percent;
//   final double totalAmount;
//   final double discount;
//   final String notes;
//   final List<PaymentVoucherItem> voucherItems;

//   PaymentVoucherRequestUpdate({
//     required this.userId,
//     required this.customerId,
//     required this.voucherPerson,
//     required this.voucherNumber,
//     required this.voucherDate,
//     required this.voucherTime,
//     required this.paymentForm,
//     required this.accountId,
//     required this.paymentTo,
//     required this.percent,
//     required this.totalAmount,
//     required this.discount,
//     required this.notes,
//     required this.voucherItems,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'customer_id': customerId,
//       'voucher_person': voucherPerson,
//       'voucher_number': voucherNumber,
//       'voucher_date': voucherDate,
//       'voucher_time': voucherTime,
//       'payment_form': paymentForm,
//       'account_id': accountId,
//       'payment_to': paymentTo,
//       'discount_type': percent,
//       'total_amount': totalAmount,
//       'discount_amount': discount,
//       'notes': notes,
//       'voucher_items': voucherItems.map((item) => item.toJson()).toList(),
//     };
//   }
// }