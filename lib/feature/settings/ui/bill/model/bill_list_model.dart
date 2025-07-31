class BillPersonModel {
  final int id;
  final String name;
  final String nickName;
  final String email;
  final String phone;
  final int designationId;
  final String? avatar;
  final int date;
  final int status;

  BillPersonModel({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.phone,
    required this.designationId,
    this.avatar,
    required this.date,
    required this.status,
  });

  factory BillPersonModel.fromJson(Map<String, dynamic> json) {
    return BillPersonModel(
      id: json['id'],
      name: json['name'],
      nickName: json['nick_name'],
      email: json['email'],
      phone: json['phone'],
      designationId: json['designation_id'],
      avatar: json['avatar'],
      date: json['date'],
      status: json['status'],
    );
  }
}
