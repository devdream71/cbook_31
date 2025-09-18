class SaleUpdateModel {
  String itemId;
  dynamic qty;
  String unitId;
  dynamic price;
  dynamic subTotal;
  dynamic salesUpdateDiscountPercentace;
  dynamic salesUpdateDiscountAmount;
  dynamic salesUpdateVATTAXAmount;
  dynamic salesUpdateVATTAXPercentance;
  dynamic dis;

  SaleUpdateModel({
    required this.itemId,
    required this.qty,
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
      itemId: json['item_id'] ?? '',
      qty: json['qty'] ?? '',
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

  // Fixed toJson method
  Map<String, dynamic> toJson() {
    // Parse and fix unit_id format
    String formattedUnitId = unitId;
    List<String> unitParts = unitId.split('_');
    
    // Format as "id_symbol_qty" instead of "id_symbol_qty.00"
    if (unitParts.length >= 3) {
      String id = unitParts[0];
      String symbol = unitParts[1];
      String qtyPart = unitParts[2];
      
      // Remove decimal if it's a whole number
      double? qtyValue = double.tryParse(qtyPart);
      if (qtyValue != null && qtyValue % 1 == 0) {
        qtyPart = qtyValue.toInt().toString();
      }
      
      formattedUnitId = "${id}_${symbol}_$qtyPart";
    }

    // Format quantity - remove .00 if whole number
    String formattedQty = qty.toString();
    double? qtyValue = double.tryParse(formattedQty);
    if (qtyValue != null && qtyValue % 1 == 0) {
      formattedQty = qtyValue.toInt().toString();
    }

    // Handle tax_percent - null if no tax, formatted string if tax exists
    dynamic formattedTaxPercent;
    if (salesUpdateVATTAXPercentance != null && 
        salesUpdateVATTAXPercentance.toString().isNotEmpty &&
        salesUpdateVATTAXPercentance.toString() != "0" &&
        salesUpdateVATTAXPercentance.toString() != "0.00" &&
        salesUpdateVATTAXPercentance.toString() != "") {
      formattedTaxPercent = salesUpdateVATTAXPercentance;
    } else {
      formattedTaxPercent = null; // This will be serialized as null in JSON
    }

    return {
      'item_id': itemId,
      'qty': formattedQty,
      'unit_id': formattedUnitId,
      'price': price,
      'sub_total': subTotal,
      'discount_percentage': salesUpdateDiscountPercentace ?? "0",
      'discount_amount': salesUpdateDiscountAmount ?? "0",
      'tax_amount': salesUpdateVATTAXAmount ?? "0.00",
      'tax_percent': formattedTaxPercent, // null or actual tax value
      'description': dis,
    };
  }
}




// class SaleUpdateModel {
//   //dynamic purchaseDetailsId;
//   String itemId;
//   dynamic qty;
//   //dynamic purchaseQty;
//   String unitId;
//   dynamic price;
//   dynamic subTotal;
//   dynamic salesUpdateDiscountPercentace;
//   dynamic salesUpdateDiscountAmount;
//   dynamic salesUpdateVATTAXAmount;
//   dynamic salesUpdateVATTAXPercentance;
//   dynamic dis;

//   SaleUpdateModel({
//     //required this.purchaseDetailsId,
//     required this.itemId,
//     required this.qty,
//    // required this.purchaseQty,
//     required this.unitId,
//     required this.price,
//     required this.subTotal,
//       this.salesUpdateDiscountPercentace,
//       this.salesUpdateDiscountAmount,
//       this.salesUpdateVATTAXAmount,
//       this.salesUpdateVATTAXPercentance,
//       this.dis,
//   });

//   // Factory constructor to create an instance from JSON
//   factory SaleUpdateModel.fromJson(Map<String, dynamic> json) {
//     return SaleUpdateModel(
//       //purchaseDetailsId: json['purchase_id'] ?? '',
//       itemId: json['item_id'] ?? '',
//       qty: json['qty'] ?? '',
//       //purchaseQty: json['"sales_qty'] ?? '',
//       unitId: json['unit_id'] ?? '',
//       price: json['price'] ?? '',
//       subTotal: json['sub_total'] ?? '',
//       salesUpdateDiscountPercentace: json['discount_percentage'] ?? '',
//       salesUpdateDiscountAmount: json['discount_amount'] ?? '',
//       salesUpdateVATTAXAmount: json['tax_amount'] ?? '',
//       salesUpdateVATTAXPercentance: json['tax_percent'] ?? '',
//       dis: json['description'] ?? ''

//     );
//   }

//   // Method to convert instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       //'purchase_details_id': purchaseDetailsId,
//       'item_id': itemId,
//       'qty': qty,
//       //'sales_qty': purchaseQty,
//       'unit_id': unitId,
//       'price': price,
//       'sub_total': subTotal,
//       'discount_percentage': salesUpdateDiscountPercentace,
//       'discount_amount': salesUpdateDiscountAmount,
//       'tax_amount': salesUpdateVATTAXAmount,
//       'tax_percent': salesUpdateVATTAXPercentance,
//       'description': dis,
//     };
//   }
// }