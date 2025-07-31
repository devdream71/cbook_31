class LoginResponse {
  final bool success;
  final String message;
  final UserData data;

  LoginResponse({required this.success, required this.message, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final String email;
  final String password;
  final String token;
  final int id;
  final String name;
  final String phone;
  final String? avatar;

  UserData({
    required this.email,
    required this.password,
    required this.token,
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'],
      password: json['password'],
      token: json['token'],
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}
