class SaleUpdateModel {
  //dynamic purchaseDetailsId;
  String itemId;
  dynamic qty;
  //dynamic purchaseQty;
  String unitId;
  dynamic price;
  dynamic subTotal;
  dynamic salesUpdateDiscountPercentace;
  dynamic salesUpdateDiscountAmount;
  dynamic salesUpdateVATTAXAmount;
  dynamic salesUpdateVATTAXPercentance;
  dynamic dis;

  SaleUpdateModel({
    //required this.purchaseDetailsId,
    required this.itemId,
    required this.qty,
   // required this.purchaseQty,
    required this.unitId,
    required this.price,
    required this.subTotal,
      this.salesUpdateDiscountPercentace,
      this.salesUpdateDiscountAmount,
      this.salesUpdateVATTAXAmount,
      this.salesUpdateVATTAXPercentance,
      this.dis,
  });

  // Factory constructor to create an instance from JSON
  factory SaleUpdateModel.fromJson(Map<String, dynamic> json) {
    return SaleUpdateModel(
      //purchaseDetailsId: json['purchase_id'] ?? '',
      itemId: json['item_id'] ?? '',
      qty: json['qty'] ?? '',
      //purchaseQty: json['"sales_qty'] ?? '',
      unitId: json['unit_id'] ?? '',
      price: json['price'] ?? '',
      subTotal: json['sub_total'] ?? '',
      salesUpdateDiscountPercentace: json['discount_percentage'] ?? '',
      salesUpdateDiscountAmount: json['discount_amount'] ?? '',
      salesUpdateVATTAXAmount: json['tax_amount'] ?? '',
      salesUpdateVATTAXPercentance: json['tax_percent'] ?? '',
      dis: json['description'] ?? ''

    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      //'purchase_details_id': purchaseDetailsId,
      'item_id': itemId,
      'qty': qty,
      //'sales_qty': purchaseQty,
      'unit_id': unitId,
      'price': price,
      'sub_total': subTotal,
      'discount_percentage': salesUpdateDiscountPercentace,
      'discount_amount': salesUpdateDiscountAmount,
      'tax_amount': salesUpdateVATTAXAmount,
      'tax_percent': salesUpdateVATTAXPercentance,
      'description': dis,
    };
  }
}