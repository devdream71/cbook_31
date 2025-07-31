class SaleReturnStore {
  final int salesDetailsId;
  final String item;
  final String qty;
  final String unitID;
  final String price;
  final String subTotal;

  SaleReturnStore ({
    required this.salesDetailsId,
    required this.item,
    required this.qty,
    required this.unitID,
    required this.price,
    required this.subTotal
  });

  factory SaleReturnStore.fromJson(Map<String, dynamic> json ) {
    return SaleReturnStore(
      salesDetailsId: json['sales_details_id'], 
      item: json['item_id'], 
      qty: json['qty'], 
      unitID: json['unit_id'], 
      price: json['price'], 
      subTotal: json['sub_total']
      );
  }

  Map<String, dynamic> toJson() {
    return {
      "sales_details_id" : salesDetailsId,
      'item_id' : item,
      'qty' : qty,
      "unit_id" :unitID,
      "price" : price,
      "sub_total" : subTotal,

    };
  }

}