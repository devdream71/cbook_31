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
  final dynamic email;
  final dynamic password;
  final String token;
  final int id;
  final int companyId;
  final dynamic name;
  final dynamic phone;
  final dynamic avatar;
  //final int companyID;
  final String ? companyName;

  UserData({
    required this.email,
    required this.password,
    required this.token,
    required this.id,
    required this.companyId,
    required this.name,
    required this.phone,
    //required this.companyID,
    this.companyName,
    
    this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'],
      //companyID: json['company_id'],
      password: json['password'],
      token: json['token'],
      id: json['id'],
      companyId : json['company_id'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      companyName: json['company_name'],

    );
  }
}
