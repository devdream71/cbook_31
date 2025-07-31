class Customer {
  final int id;
  final int userId;
  final String name;
  final String proprietorName;
  final double due;
  final String? address;
  final String? phone;
  final String? type;
  final String? avatar;
  final List<Purchase> purchases;

  Customer({
    required this.id,
    required this.userId,
    required this.name,
    required this.proprietorName,
    required this.due,
    this.type,
    this.address,
    this.phone,
    this.avatar,
    required this.purchases,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    String rawDue = json['due'] ?? '0';
    double parsedDue = double.tryParse(rawDue.replaceAll(',', '')) ?? 0.0;

    return Customer(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      proprietorName: json['proprietor_name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      due: parsedDue,
      purchases: (json['purchase'] as List?)
              ?.map((e) => Purchase.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Purchase {
  final int id;
  final String type;
  final String? billNumber;
  final int userId;
  final String transectionMethod;
  final int customerId;
  final String purchaseDate;
  final double grossTotal;
  final int paymentStatus;
  final String createdAt;
  final String updatedAt;

  Purchase({
    required this.id,
    required this.type,
    this.billNumber,
    required this.userId,
    required this.transectionMethod,
    required this.customerId,
    required this.purchaseDate,
    required this.grossTotal,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      billNumber: json['bill_number'],
      userId: json['user_id'] ?? 0,
      transectionMethod: json['transection_method'] ?? '',
      customerId: json['customer_id'] ?? 0,
      purchaseDate: json['pruchase_date'] ?? '',
      grossTotal: (json['gross_total'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CustomerResponse {
  final bool success;
  final String message;
  final List<Customer> data;

  CustomerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)?.map((e) => Customer.fromJson(e)).toList() ??
              [],
    );
  }
}
