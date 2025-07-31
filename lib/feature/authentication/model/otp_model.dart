




// API Model
class VerificationResponse {
  final bool success;
  final String message;
  final UserData? data;

  VerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "Unknown error",
      // data: json["data"] != null ? UserData.fromJson(json["data"]) : null,
       data: UserData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data!.toJson(),
    };
  }
}

class UserData {
  int id;
  String userType;
  String name;
  String email;
  String emailVerifiedAt;
  String phone;
  dynamic countryId;
  int createdId;
  String verificationCode;
  dynamic avatar;
  int status;
  String createdAt;
  String updatedAt;

  UserData({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.phone,
    this.countryId,
    required this.createdId,
    required this.verificationCode,
    this.avatar,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
       id: json['id'],
      userType: json['user_type'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      phone: json['phone'],
      countryId: json['country_id'],
      createdId: json['created_id'],
      verificationCode: json['varification_code'],
      avatar: json['avatar'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_type': userType,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'country_id': countryId,
      'created_id': createdId,
      'varification_code': verificationCode,
      'avatar': avatar,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
