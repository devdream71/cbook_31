class PurchaseUpdateModel {
  //String? purchaseDetailsId;
  String itemId;
  String qty;
  //String ?purchaseQty;
  String unitId;
  dynamic price;
  dynamic subTotal;

  PurchaseUpdateModel({
    //required this.purchaseDetailsId,
    required this.itemId,
    required this.qty,
    //required this.purchaseQty,
    required this.unitId,
    required this.price,
    required this.subTotal,
  });

  // Factory constructor to create an instance from JSON
  factory PurchaseUpdateModel.fromJson(Map<String, dynamic> json) {
    return PurchaseUpdateModel(
      //purchaseDetailsId: json['purchase_details_id'] ?? '',
      itemId: json['item_id'] ?? '',
      qty: json['qty'] ?? '',
      //purchaseQty: json['"purchase_qty'] ?? '',
      unitId: json['unit_id'] ?? '',
      price: json['price'] ?? '',
      subTotal: json['sub_total'] ?? '',
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      //'purchase_details_id': purchaseDetailsId,
      'item_id': itemId,
      'qty': qty,
      //'purchase_qty': purchaseQty,
      'unit_id': unitId,
      'price': price,
      'sub_total': subTotal,
    };
  }
}