class UserProfile {
  final int id;
  final String name;
  final String nickName;
  final String email;
  final String phone;
  final String companyName;
  final String currency;
  final dynamic countryId;
  final String address;
  final String avatar;
  final String singture;
  final String logo;

  UserProfile({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.currency,
    required this.countryId,
    required this.address,
    required this.avatar,
    required this.singture,
    required this.logo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? '',
      nickName: json['nick_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['company_name'] ?? '',
      currency: json['currency'] ?? '',
      countryId: json['country_id'] ?? 0,
      address: json['address'] ?? '',
      avatar: json['avatar'] ?? '',
      singture: json['singture'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nick_name': nickName,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'currency': currency,
      'country_id': countryId,
      'address': address,
      'avatar': avatar,
      'singture': singture,
      'logo': logo,
    };
  }
}

class ProfileResponse {
  final bool success;
  final String message;
  final UserProfile data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: UserProfile.fromJson(json['data']),
    );
  }
}







// class UserProfile {
//   final int id;
//   final dynamic userType;
//   final dynamic name;
//   final dynamic email;
//   final dynamic phone;
//   final dynamic avatar;
  
//   final dynamic createdAt;
//   final dynamic updatedAt;

//   UserProfile({
//     required this.id,
//     required this.userType,
//     required this.name,
//     required this.email,
//     this.phone,
//     this.avatar,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory UserProfile.fromJson(Map<String, dynamic> json) {
//     return UserProfile(
//       id: json['id'],
//       userType: json['user_type'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       avatar: json['avatar'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_type': userType,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'avatar': avatar,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }

// class ProfileResponse {
//   final bool success;
//   final String message;
//   final UserProfile data;

//   ProfileResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//   });

//   factory ProfileResponse.fromJson(Map<String, dynamic> json) {
//     return ProfileResponse(
//       success: json['success'],
//       message: json['message'],
//       data: UserProfile.fromJson(json['data']),
//     );
//   }
// }