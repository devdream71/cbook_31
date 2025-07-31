class SalesReturnItem {
  final String ? userID;
  final String ? supplierID;
  final String ? supplierName;
  final String ? trasection;
  final String ? billNumber;
  final String ? purchaseDta;
  final String ? discount;
  final String ? grossTotal;
  final String ? detailsNote;
  ///
  final String ? purchaseID;
  final String ? purchaseDetailsID;
  final String ? type;
  final String ? purchaseDate;
  final String ? itemID;
  final String ? defaultQty;
  final String ? qty;
  final String ? rawQty;
  final String ? unitID;
  final String ? price;

  SalesReturnItem({
    this.userID, 
    this.supplierID, 
    this.supplierName, 
    this.trasection, 
    this.billNumber, 
    this.purchaseDta, 
    this.discount, 
    this.grossTotal, 
    this.detailsNote,
    //
    this.purchaseID,
    this.purchaseDetailsID,
    this.type,
    this.purchaseDate,
    this.itemID,
    this.defaultQty,
    this.qty,
    this.rawQty,
    this.unitID,
    this.price 

  });

  //factory

  factory SalesReturnItem.fromJson(Map<String, dynamic> json ) {
     return SalesReturnItem(
      userID: json["user_id"],
      supplierID: json['supplier_id'],
      supplierName: json['supplier_name'],
      trasection: json['transection_method'],
      billNumber: json['bill_number'],
      purchaseDta: json['pruchase_date'],
      discount: json['discount'],
      grossTotal: json['gross_total'],
      detailsNote: json['details_notes'],
      purchaseID: json['purchase_id'],
      purchaseDetailsID: json['purchase_details_id'],
      type: json['type'],
      purchaseDate: json['pruchase_date'],
      itemID: json['item_id'],
      defaultQty: json['default_qty'],
      qty: json['qty'],
      rawQty: json['raw_qty'],
      unitID: json['unit_id'],
      price: json['price']

     );
  }

  Map<String, dynamic> toJson () {
    return {
         'user_id' : userID,
         'supplier_id' : supplierID,
         'supplier_name' : supplierName,
         'transection_method' : trasection,
         'bill_number' : billNumber,
         'pruchase_date' : purchaseDta,
         'discount' : discount,
         'gross_total'  : grossTotal,
         'details_notes'  : detailsNote,
         'purchase_id' : purchaseID,
         'purchase_details_id' : purchaseDetailsID,
         'type' : type,
         'pruchase_date' : purchaseDate,
         'item_id' : itemID,
         'price' : price,
         'default_qty' : defaultQty,
         'qty' : qty,
         'raw_qty' : rawQty,
         'unit_id' : unitID,
           
     };
  }

}