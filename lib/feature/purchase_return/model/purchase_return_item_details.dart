class PurchaseHistoryModel {
  final int purchaseDetailsId;
  final int itemId;
  final String purchaseDate;
  final String type;
  final String billNumber;
  final dynamic rate;
  final dynamic billQty;
  final double outQty;
  final double currentQty;
  final dynamic supplierName;
  final int unitID;
  final int? secondaryUnitID;
  final dynamic unitQty;
  final dynamic unitPrice;
  final int purchaseUnitId;
  final dynamic pruchaseQty;
  final dynamic purchaseRawQty;

  PurchaseHistoryModel({
    required this.purchaseDetailsId,
    required this.itemId,
    required this.purchaseDate,
    required this.type,
    required this.billNumber,
    required this.rate,
    required this.billQty,
    required this.outQty,
    required this.currentQty,
    this.supplierName,
    required this.unitID,
    required this.secondaryUnitID,
    required this.unitQty,
    required this.unitPrice,
    required this.purchaseUnitId,
    this.pruchaseQty,
    this.purchaseRawQty,
  });

  factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryModel(
      purchaseDetailsId: json["purchase_details_id"],
      itemId: json["item_id"],
      // purchaseDate: json["pruchase_date"],
      purchaseDate: json["purchase_date"],
      type: json["type"],
      billNumber: json["bill_number"],
      rate: json["rate"],
      billQty: json["bill_qty"],
      outQty: (json["out_qty"] ?? 0).toDouble(),
      currentQty: (json["current_qty"] ?? 0).toDouble(),
      supplierName: json["supplier_name"] ?? "",
      unitID: int.tryParse(json["unit_id"].toString()) ?? 0,
      secondaryUnitID: json["secondary_unit_id"],
      unitQty: json["unit_qty"],
      unitPrice: json["unit_price"],
      purchaseUnitId: json["purchase_unit_id"],
      pruchaseQty: json["pruchase_qty"],
      purchaseRawQty: json['pruchase_raw_qty'],

    );
  }
}

 