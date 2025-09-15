class CompanyModel {
  final int companyId;
  final String companyName;
  final String? role;
  final int status;
  final String? logo;

  CompanyModel({
    required this.companyId,
    required this.companyName,
    this.role,
    required this.status,
    this.logo,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id'],
      companyName: json['company_name'],
      role: json['role'],
      logo : json['company_logo'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'role': role,
      'status': status,
      'company_logo': logo,

    };
  }
}