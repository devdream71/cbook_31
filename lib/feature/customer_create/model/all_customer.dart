class CustomerResponse {
  final bool success;
  final String message;
  final List<ContactModel> data;

  CustomerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => ContactModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((item) => item.toJson()).toList(),
      };
}

class ContactModel {
  final int id;
  final String name;
  final String type;
  final String? address;
  final String? phone;
  final String due;

  ContactModel({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.phone,
    required this.due,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      due: json['due'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'address': address,
        'phone': phone,
        'due': due,
      };
}
