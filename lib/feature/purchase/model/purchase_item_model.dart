class ItemModel {
  String? category;
  String? subCategory;
  String? itemName;
  dynamic itemCode;
  dynamic mrp;
  dynamic quantity;
  dynamic total;
  dynamic price;
  dynamic unit;

  ItemModel({
    this.category,
    this.subCategory,
    this.itemName,
    this.itemCode,
    this.mrp,
    this.quantity,
    this.total,
    this.price,
    this.unit,
  });

  @override
  String toString() {
    return 'ItemModel(itemName: $itemName, price: $price, quantity: $quantity, unit: $unit)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          itemCode == other.itemCode;

  @override
  int get hashCode => itemCode.hashCode;
}



 