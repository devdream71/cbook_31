// class SalesReturnHistoryModel {
//   final dynamic salesDetailsID;
//   final dynamic itemID;
//   final dynamic salesUnitId;
//   final String purchaseDate;
//   final dynamic billNumber;
//   final dynamic rate;
//   final dynamic unitPrice;
//   final dynamic unitQty;
//   final dynamic billQty;
//   final dynamic returnQty;

//   SalesReturnHistoryModel(
//       {required this.salesDetailsID,
//       required this.itemID,
//       required this.salesUnitId,
//       required this.purchaseDate,
//       required this.billNumber,
//       required this.rate,
//       required this.unitPrice,
//       required this.unitQty,
//       required this.billQty,
//       required this.returnQty,

      
//       });

//   factory SalesReturnHistoryModel.fromJson(Map<String, dynamic> json) {
//     return SalesReturnHistoryModel(
//       salesDetailsID: json['sales_details_id'],
//       itemID: json['item_id'],
//       salesUnitId: json['sales_unit_id'],
//       purchaseDate: json['purchase_date'],
//       billNumber: json['bill_number'],
//       rate: json['rate'],
//       unitPrice: json['unit_price'],
//       unitQty: json['unit_qty'],
//       billQty: json['bill_qty'],
//       returnQty: json['return_qty'],
//     );
//   }
// }



class SalesReturnHistoryModel {
  final dynamic salesDetailsID;
  final dynamic itemID;
  final dynamic salesUnitId;
  final String purchaseDate;
  final String billNumber;
  final String rate;
  final String unitPrice;
  final dynamic unitQty;
  final String billQty;
  final String returnQty;

  SalesReturnHistoryModel({
    required this.salesDetailsID,
    required this.itemID,
    required this.salesUnitId,
    required this.purchaseDate,
    required this.billNumber,
    required this.rate,
    required this.unitPrice,
    required this.unitQty,
    required this.billQty,
    required this.returnQty,
  });

  factory SalesReturnHistoryModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnHistoryModel(
      salesDetailsID: json['sales_details_id'],
      itemID: json['item_id'],
      salesUnitId: json['sales_unit_id'],
      purchaseDate: json['purchase_date']?.toString() ?? '', // ✅ FIXED KEY
      billNumber: json['bill_number']?.toString() ?? '',
      rate: json['rate']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      unitQty: json['unit_qty'],
      billQty: json['bill_qty']?.toString() ?? '',
      returnQty: json['return_qty']?.toString() ?? '0',
    );
  }
}
