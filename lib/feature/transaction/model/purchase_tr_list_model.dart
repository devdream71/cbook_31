class PurchaseViewModel {
  bool? success;
  String? message;
  List<Data>? data;
  PurchaseSummary? summary;

  PurchaseViewModel({this.success, this.message, this.data, this.summary});

  PurchaseViewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = <Data>[];
    List<dynamic> rawList = json['data'];

    for (var item in rawList) {
      if (item is Map<String, dynamic> &&
          item.containsKey("total_pruchase") &&
          item.containsKey("total_payment") &&
          item.containsKey("total_due")) {
        summary = PurchaseSummary.fromJson(item);
      } else {
        data!.add(Data.fromJson(item));
      }
    }
  }
}

class PurchaseSummary {
  final String totalPurchase;
  final String totalPayment;
  final dynamic totalDue;

  PurchaseSummary({
    required this.totalPurchase,
    required this.totalPayment,
    required this.totalDue,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseSummary(
      totalPurchase: json['total_pruchase'] ?? '0',
      totalPayment: json['total_payment'] ?? '0',
      totalDue: json['total_due'] ?? 0,
    );
  }
}

class Data {
  dynamic userId;
  String? supplier;
  String? billNumber;
  String? pruchaseDate;
  dynamic discount;
  dynamic grossTotal;
  String? disabled;
  dynamic detailsNotes;
  String? transactionMethod;
  dynamic payment;
  dynamic due;
  dynamic paymentStatus;
  List<PurchaseDetails>? purchaseDetails;

  Data(
      {this.userId,
      this.supplier,
      this.billNumber,
      this.pruchaseDate,
      this.discount,
      this.grossTotal,
      this.disabled,
      this.detailsNotes,
      this.transactionMethod,
      this.payment,
      this.due,
      this.paymentStatus,
      this.purchaseDetails});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    supplier = json['supplier_name'];
    billNumber = json['bill_number'];
    pruchaseDate = json['purchase_date'];
    discount = json['discount'];
    grossTotal = json['gross_total'];
    disabled = json['disabled'];
    detailsNotes = json['details_notes'];
    transactionMethod = json['transaction_method'];
    payment = json['payment'];
    due = json['due'];
    paymentStatus = json['payment_status'];
    
    if (json['purchase_details'] != null) {
      purchaseDetails = <PurchaseDetails>[];
      json['purchase_details'].forEach((v) {
        purchaseDetails!.add(PurchaseDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['supplier_name'] = supplier;
    data['bill_number'] = billNumber;
    // data['transaction_method'] = transactionMethod;
    data['transaction_method'] = transactionMethod;
    data['purchase_date'] = pruchaseDate;
    data['discount'] = discount;
    data['gross_total'] = grossTotal;
    data['due'] = due;
    data['payment_status'] = paymentStatus;
    data['payment'] = payment;
    data['disabled'] = disabled;
    data['details_notes'] = detailsNotes;
    if (purchaseDetails != null) {
      data['purchase_details'] =
          purchaseDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseDetails {
  int? id;
  dynamic? purchaseId;
  //Null? purchaseDetailsId;
  String? type;
  String? pruchaseDate;
  int? itemId;
  int? defaultQty;
  dynamic qty;
  dynamic rawQty;
  int? unitId;
  dynamic price;
  dynamic subTotal;
  dynamic salesQty;
  dynamic returnQty;
  Null deletedAt;
  String? createdAt;
  String? updatedAt;

  PurchaseDetails(
      {this.id,
      this.purchaseId,
      //this.purchaseDetailsId,
      this.type,
      this.pruchaseDate,
      this.itemId,
      this.defaultQty,
      this.qty,
      this.rawQty,
      this.unitId,
      this.price,
      this.subTotal,
      this.salesQty,
      this.returnQty,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      required Data purchase});

  PurchaseDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purchaseId = json['purchase_id'];
    //purchaseDetailsId = json['purchase_details_id'];
    type = json['type'];
    pruchaseDate = json['purchase_date'];
    itemId = json['item_id'];
    defaultQty = json['default_qty'];
    qty = json['qty'];
    rawQty = json['raw_qty'];
    unitId = json['unit_id'];
    price = json['price'];
    subTotal = json['sub_total'];
    salesQty = json['sales_qty'];
    returnQty = json['return_qty'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['purchase_id'] = purchaseId;
    //data['purchase_details_id'] = this.purchaseDetailsId;
    data['type'] = type;
    data['purchase_date'] = pruchaseDate;
    data['item_id'] = itemId;
    data['default_qty'] = defaultQty;
    data['qty'] = qty;
    data['raw_qty'] = rawQty;
    data['unit_id'] = unitId;
    data['price'] = price;
    data['sub_total'] = subTotal;
    data['sales_qty'] = salesQty;
    data['return_qty'] = returnQty;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
