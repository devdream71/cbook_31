class SalesResponse {
  final bool success;
  final String message;
  final List<SaleItem> data;
  final SalesSummary? summary; // new summary field

  SalesResponse({
    required this.success,
    required this.message,
    required this.data,
    this.summary,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>;

    // Separate normal sales and the summary (last element assumed summary)
    List<SaleItem> sales = [];
    SalesSummary? summary;

    if (rawData.isNotEmpty) {
      // Check if last element looks like summary (has total_sales key)
      final last = rawData.last;
      if (last is Map<String, dynamic> && last.containsKey('total_sales')) {
        summary = SalesSummary.fromJson(last);
        // Remove last item from sales list
        sales = rawData.sublist(0, rawData.length - 1)
            .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        sales = rawData.map((e) => SaleItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    return SalesResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: sales,
      summary: summary,
    );
  }
}

class SalesSummary {
  final String totalSales;
  final String totalReceived;
  final double totalDue;

  SalesSummary({
    required this.totalSales,
    required this.totalReceived,
    required this.totalDue,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalSales: json['total_sales']?.toString() ?? '0',
      totalReceived: json['total_received']?.toString() ?? '0',
      totalDue: double.tryParse(json['total_due']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SaleItem {
  final int userId;
  final dynamic customerId;
  final String customerName;
  final String transactionMethod;
  final String billNumber;
  final String purchaseDate;
  final double discount;
  final double? tax;  // Added tax field (nullable double)
  final double grossTotal;
  final String? detailsNotes;
  final String disabled;
  final double receipt;
  final double due;
  final int paymentStatus;
  final List<PurchaseDetail> purchaseDetails;

  SaleItem({
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.transactionMethod,
    required this.billNumber,
    required this.purchaseDate,
    required this.discount,
    this.tax,
    required this.grossTotal,
    this.detailsNotes,
    required this.disabled,
    required this.receipt,
    required this.due,
    required this.paymentStatus,
    required this.purchaseDetails,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      userId: json['user_id'] ?? 0,
      customerId: json['customer_id'] ?? 'N/A',
      customerName: json['customer_name'] ?? 'N/A',
      transactionMethod: json['transaction_method'] ?? '',
      billNumber: json['bill_number'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      tax: json['tax'] == null ? null : double.tryParse(json['tax'].toString()),
      grossTotal: double.tryParse(json['gross_total'].toString()) ?? 0.0,
      detailsNotes: json['details_notes'],
      disabled: json['disabled'] ?? '',
      receipt: (json['receipt'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
      paymentStatus: int.tryParse(json['payment_status'].toString()) ?? 0,
      purchaseDetails: (json['purchase_details'] as List)
          .map((e) => PurchaseDetail.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseDetail {
  final int id;
  final int purchaseId;
  final String purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final int itemId;
  final double qty;
  final double rawQty;
  final int unitId;
  final double price;
  final double subTotal;
  final double salesQty;
  final double returnQty;
  final double discountAmount;
  final double discountPercentage;
  final double taxAmount;
  final double taxPercentage;
  final String? description;
  final String? deletedAt;      // Added nullable deletedAt
  final String? createdAt;      // Added nullable createdAt
  final String? updatedAt;      // Added nullable updatedAt

  PurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.purchaseDetailsId,
    required this.type,
    required this.purchaseDate,
    required this.itemId,
    required this.qty,
    required this.rawQty,
    required this.unitId,
    required this.price,
    required this.subTotal,
    required this.salesQty,
    required this.returnQty,
    required this.discountAmount,
    required this.discountPercentage,
    required this.taxAmount,
    required this.taxPercentage,
    this.description,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'] ?? 0,
      purchaseId: json['purchase_id'] ?? 0,
      purchaseDetailsId: json['purchase_details_id'] ?? '',
      type: json['type'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      itemId: json['item_id'] ?? 0,
      qty: double.tryParse(json['qty'].toString()) ?? 0.0,
      rawQty: double.tryParse(json['raw_qty'].toString()) ?? 0.0,
      unitId: json['unit_id'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      subTotal: double.tryParse(json['sub_total'].toString()) ?? 0.0,
      salesQty: double.tryParse(json['sales_qty'].toString()) ?? 0.0,
      returnQty: double.tryParse(json['return_qty'].toString()) ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      discountPercentage:
          double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      taxPercentage:
          double.tryParse(json['tax_percent']?.toString() ?? '0') ?? 0.0,
      description: json['description'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
 



