class Purchase {
  final int id;
  final String type;
  final String billNumber;
  final String purchaseDate;
  final double grossTotal;

  Purchase({
    required this.id,
    required this.type,
    required this.billNumber,
    required this.purchaseDate,
    required this.grossTotal,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      billNumber: json['bill_number'] ?? '',
      purchaseDate: json['pruchase_date'] ?? '',
      grossTotal: (json['gross_total'] ?? 0).toDouble(),
    );
  }
}

class Supplier {
  final int id;
  final String name;
  final String proprietorName;
  final double due;
  final List<Purchase> purchases; // Added purchase list

  Supplier({
    required this.id,
    required this.name,
    required this.proprietorName,
    required this.due,
    required this.purchases, // Include purchase list
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    var purchaseList = <Purchase>[];
    if (json['purchase'] != null) {
      purchaseList = List<Purchase>.from(
        json['purchase'].map((x) => Purchase.fromJson(x)),
      );
    }

    return Supplier(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      proprietorName: json['proprietor_name'] ?? '',
      // due: (json['due'] ?? 0).toDouble(),
      due: double.tryParse((json['due'] ?? '0').toString().replaceAll(',', '')) ?? 0.0,
      purchases: purchaseList, // Assign purchases list
    );
  }
}

class SupplierResponse {
  final bool success;
  final String message;
  final List<Supplier> data;

  SupplierResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SupplierResponse.fromJson(Map<String, dynamic> json) {
    return SupplierResponse(
      success: json['success'] ?? false,
      message: json['message'].toString(),
      data: json['data'] != null
          ? List<Supplier>.from(json['data'].map((x) => Supplier.fromJson(x)))
          : [],
    );
  }
}



