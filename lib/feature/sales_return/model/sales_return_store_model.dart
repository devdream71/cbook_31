class SalesReturnStoreModel {
  String purchaseDetailsId;
  String itemId;
  String qty;
  String unitId;
  String price;
  String subTotal;
  

  // Constructor
  SalesReturnStoreModel({
    required this.purchaseDetailsId,
    required this.itemId,
    required this.qty,
    required this.unitId,
    required this.price,
    required this.subTotal,
  });

  // From JSON (Map) to Dart object
  factory SalesReturnStoreModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnStoreModel(
      // purchaseDetailsId: json['sales_details_id'] ?? '',
      purchaseDetailsId: json['purchase_details_id'] ?? '',
      itemId: json['item_id'] ?? '',
      qty: json['qty'] ?? '',
      unitId: json['unit_id'] ?? '',
      price: json['price'] ?? '',
      subTotal: json['sub_total'] ?? '',
    );
  }

  // To JSON (Dart object) to Map
  Map<String, dynamic> toJson() {
    return {
      // 'sales_details_id': purchaseDetailsId,
      'purchase_details_id': purchaseDetailsId,
      'item_id': itemId,
      'qty': qty,
      'unit_id': unitId,
      'price': price,
      'sub_total': subTotal,
    };
  }
}
