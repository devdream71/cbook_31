class ExpenseItem {
    String receiptFrom;
    dynamic note;
    double amount;
    dynamic purchaseId;

  ExpenseItem({
    required this.receiptFrom,
    this.note,
    required this.amount,
    this.purchaseId
  });
}