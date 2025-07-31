// models/user_model.dart
class SetingsUserModel {
  final int id;
  final String name;
  final String? nickName;
  final String email;
  final String phone;
  final int? designationId;
  final String? avatar;
  final String? createdDate;
  final int status;

  SetingsUserModel({
    required this.id,
    required this.name,
    this.nickName,
    required this.email,
    required this.phone,
    this.designationId,
    this.avatar,
    this.createdDate,
    required this.status,
  });

  factory SetingsUserModel.fromJson(Map<String, dynamic> json) {
    return SetingsUserModel(
      id: json['id'],
      name: json['name'],
      nickName: json['nick_name'],
      email: json['email'],
      phone: json['phone'],
      designationId: json['designation_id'],
      avatar: json['avatar'],
      createdDate: json['created_date'],
      status: json['status'],
    );
  }
}
