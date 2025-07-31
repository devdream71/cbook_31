class CustomerCreateResponse {
  final bool success;
  final String message;
  final CustomerData data;

  CustomerCreateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerCreateResponse.fromJson(Map<String, dynamic> json) {
    return CustomerCreateResponse(
      success: json['success'],
      message: json['message'],
      data: CustomerData.fromJson(json['data']),
    );
  }
}

class CustomerData {
  final int userId; // Changed from String to int  
  final String? type;
  final String name;
  final String proprietorName;
  final String email;
  final String phone;
  final double openingBalance; // Changed from String to double
  final String address;
  final int status;
  final String? createdAt;
  final String? updatedAt;
  final int id;
  final dynamic level;
  final dynamic levelType;

  CustomerData({
    required this.userId,
    this.type,
    required this.name,
    required this.proprietorName,
    required this.email,
    required this.phone,
    required this.openingBalance,
    required this.address,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.level,
    this.levelType,
    required this.id,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      userId: json['user_id'] ?? 0,
      type: json['type'],
      name: json['name'],
      proprietorName: json['proprietor_name'],
      email: json['email'],
      phone: json['phone'],
      level: json['level'],
      levelType: json['level_type'],
      openingBalance: (json['opening_balance'] ?? 0).toDouble(), // Convert to double
      address: json['address'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      id: json['id'] ?? 0,
    );
  }
}


