class SaleItemModel {
  String ?itemId;
  dynamic qty;
  String ?unitId;
  dynamic price;
  dynamic subTotal;
  dynamic discountPercentage;
  dynamic discountAmount;
  dynamic taxPercent;
  dynamic taxAmount;
  String ? description;
  // dynamic totalItemVats;
  // dynamic totalItemDiscounts;

  SaleItemModel({
     this.itemId,
     this.qty,
     this.unitId,
     this.price,
     this.subTotal,
     this.discountPercentage,
     this.discountAmount,
     this.taxPercent,
     this.taxAmount,
     this.description,
    //  this.totalItemVats,
    //  this.totalItemDiscounts,
  });

  // Factory constructor to create an object from JSON
  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      itemId: json['item_id'],
      qty: json['qty'],
      unitId: json['unit_id'],
      price: json['price'],
      subTotal: json['sub_total'],
      discountPercentage: json['discount_percentage'],
      discountAmount: json['discount_amount'],
      taxPercent: json['tax_percent'],
      taxAmount: json['tax_amount'],
      description: json['description'],
      // totalItemDiscounts: json['total_item_discounts'],
      // totalItemVats: json['total_item_vats'],
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
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'tax_percent': taxPercent,
      'tax_amount': taxAmount,
      'description' : description,
      // 'total_item_vats' : totalItemVats,
      // 'total_item_discounts' : totalItemDiscounts,
    };
  }
}
