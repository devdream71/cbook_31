class ReceiptItem {
  final String receiptFrom;
  final String amount;
  final String note;
  final String ? accountId;

  ReceiptItem(
      {required this.receiptFrom, 
      required this.amount, 
      required this.note,
        this.accountId,
      });
}
