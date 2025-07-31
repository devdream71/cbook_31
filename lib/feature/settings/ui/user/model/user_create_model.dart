class UserCreateResponseModel {
  final bool success;
  final String message;
  final CreatedUserData? data;

  UserCreateResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return UserCreateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CreatedUserData.fromJson(json['data']) : null,
    );
  }
}

class CreatedUserData {
  final int id;
  final String name;
  final String nickName;
  final String email;
  final String phone;
  final String userType;
  final String address;
  final String roleId;
  final String createdDate;
  final String status;
  final String avatar;
  final String? signature;

  CreatedUserData({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.phone,
    required this.userType,
    required this.address,
    required this.roleId,
    required this.createdDate,
    required this.status,
    required this.avatar,
    this.signature,
  });

  factory CreatedUserData.fromJson(Map<String, dynamic> json) {
    return CreatedUserData(
      id: json['id'],
      name: json['name'],
      nickName: json['nick_name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'],
      address: json['address'],
      roleId: json['role_id'].toString(),
      createdDate: json['created_date'],
      status: json['status'],
      avatar: json['avatar'],
      signature: json['singture'],
    );
  }
}
