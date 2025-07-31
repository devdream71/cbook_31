class RegisterResponse {
  final bool success;
  final String message;
  final UserData? data;

  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "Unknown error",
      data: json["data"] != null ? UserData.fromJson(json["data"]) : null,
    );
  }
}

class UserData {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final int? countryId;
  final int? verificationCode;
  final String? createdAt;
  final String? updatedAt;
  final String? token;

  UserData({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.countryId,
    this.verificationCode,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"] ?? 0, // Default to 0 if null
      name: json["name"] ?? "", // Default empty string if null
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      countryId: json["country_id"],
      verificationCode: json["varification_code"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      token: json["token"] ?? "", // Ensure token is always a string
    );
  }
}



