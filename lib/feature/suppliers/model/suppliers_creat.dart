class SupplierCreateResponse {
  final bool success;
  final String message;
  final SupplierData data;

  SupplierCreateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SupplierCreateResponse.fromJson(Map<String, dynamic> json) {
    return SupplierCreateResponse(
      success: json['success'],
      message: json['message'],
      data: SupplierData.fromJson(json['data']),
    );
  }
}

class SupplierData {
  final int id;
  final String name;
  final String proprietorName;
  final String email;
  final String phone;
  final String address;
  final String userId;
  final String type;
  final String openingBalance;
  final int status;
  final String createdAt;
  final String updatedAt;

  SupplierData({
    required this.id,
    required this.name,
    required this.proprietorName,
    required this.email,
    required this.phone,
    required this.address,
    required this.userId,
    required this.type,
    required this.openingBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierData.fromJson(Map<String, dynamic> json) {
    return SupplierData(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      proprietorName: json['proprietor_name'] ?? 'Unknown',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      userId: json['user_id']?.toString() ?? '0', // Ensure it's a string
      type: json['type'] ?? 'Unknown',
      openingBalance:
          json['opening_balance']?.toString() ?? '0.00', // Ensure it's a string
      status: int.tryParse(json['status'].toString()) ??
          0, // Handle integer conversion
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
