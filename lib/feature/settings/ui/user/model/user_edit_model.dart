class UserEditModel {
  final int id;
  final String userType;
  final String name;
  final String nickName;
  final String phone;
  final int designationId;
  final int billPersonId;
  final int defaultBillPersonId;
  final String address;
  final int roleId;
  final String? avatar;
  final String? signature;
  final int status;

  UserEditModel({
    required this.id,
    required this.userType,
    required this.name,
    required this.nickName,
    required this.phone,
    required this.designationId,
    required this.billPersonId,
    required this.defaultBillPersonId,
    required this.address,
    required this.roleId,
    this.avatar,
    this.signature,
    required this.status,
  });

  factory UserEditModel.fromJson(Map<String, dynamic> json) {
    return UserEditModel(
      id: json['id'],
      userType: json['user_type'],
      name: json['name'],
      nickName: json['nick_name'],
      phone: json['phone'],
      designationId: json['designation'],
      billPersonId: int.parse(json['bill_person'].toString().replaceAll('"', '')),
      defaultBillPersonId: json['default_bill_person'],
      address: json['address'],
      roleId: json['role_id'],
      avatar: json['avatar'],
      signature: json['singture'],
      status: json['status'],
    );
  }
}
