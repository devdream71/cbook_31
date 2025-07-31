class PurchaseStoreModel {
  String purchaseDetailsId;
  String itemId;
  String qty;
  String unitId;
  String price;
  String subTotal;

  // Constructor
  PurchaseStoreModel({
    required this.purchaseDetailsId,
    required this.itemId,
    required this.qty,
    required this.unitId,
    required this.price,
    required this.subTotal,
  });

  // From JSON (Map) to Dart object
  factory PurchaseStoreModel.fromJson(Map<String, dynamic> json) {
    return PurchaseStoreModel(
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
      'purchase_details_id': purchaseDetailsId,
      'item_id': itemId,
      'qty': qty,
      'unit_id': unitId,
      'price': price,
      'sub_total': subTotal,
    };
  }
}