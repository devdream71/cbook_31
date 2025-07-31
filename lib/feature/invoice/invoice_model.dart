class InvoiceItem {
  final String itemName;
  final String unit;
  final int quantity;
  final double amount;
  final dynamic discount;
  final dynamic customerName;
  final dynamic itemDiscountAmount;
  final dynamic itemDiscountPercentace;
  final dynamic itemVatTaxAmount;
  final dynamic itemvatTaxPercentace;

  InvoiceItem({
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.amount,
    this.discount,
    this.customerName,
    this.itemDiscountAmount,
    this.itemDiscountPercentace,
    this.itemVatTaxAmount,
    this.itemvatTaxPercentace
  });
}