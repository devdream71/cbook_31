class UserProfile {
  final int id;
  final String userType;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userType: json['user_type'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
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
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
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