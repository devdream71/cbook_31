class PurchaseItemModel {
  String ?itemId;
  dynamic qty;
  String ?unitId;
  dynamic  price;
  dynamic subTotal;

  PurchaseItemModel({
     this.itemId,
     this.qty,
     this.unitId,
     this.price,
     this.subTotal,
  });

  // Factory constructor to create an object from JSON
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      itemId: json['item_id'],
      qty: json['qty'],
      unitId: json['unit_id'],
      price: json['price'],
      subTotal: json['sub_total'],
    );
  }

  // Method to convert an object to JSON
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'qty': qty,
      'unit_id': unitId,
      'price': price,
      'sub_total': subTotal,
    };
  }
}