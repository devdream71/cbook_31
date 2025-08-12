class ForgotPasswordResponse {
  final bool success;
  final String message;
  final ForgotPasswordData? data;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ForgotPasswordData.fromJson(json['data'])
          : null,
    );
  }
}

class ForgotPasswordData {
  final int id;
  final String? userType;
  final String? name;
  final String? nickName;
  final String email;
  final String? emailVerifiedAt;
  final String? phone;
  final int? countryId;
  final int? createdId;
  final int? roleId;
  final int? designationId;
  final int? billPersonId;
  final int? defaultBillPersonId;
  final String? address;
  final String? verificationCode;
  final String? avatar;
  final String? signature;
  final int? status;
  final String? createdDate;
  final String? createdAt;
  final String? updatedAt;
  final BusinessInfo? businessInfo;

  ForgotPasswordData({
    required this.id,
    this.userType,
    this.name,
    this.nickName,
    required this.email,
    this.emailVerifiedAt,
    this.phone,
    this.countryId,
    this.createdId,
    this.roleId,
    this.designationId,
    this.billPersonId,
    this.defaultBillPersonId,
    this.address,
    this.verificationCode,
    this.avatar,
    this.signature,
    this.status,
    this.createdDate,
    this.createdAt,
    this.updatedAt,
    this.businessInfo,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      id: json['id'],
      userType: json['user_type'],
      name: json['name'],
      nickName: json['nick_name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      phone: json['phone'],
      countryId: json['country_id'],
      createdId: json['created_id'],
      roleId: json['role_id'],
      designationId: json['designation_id'],
      billPersonId: json['bill_person_id'],
      defaultBillPersonId: json['default_bill_person_id'],
      address: json['address'],
      verificationCode: json['varification_code'],
      avatar: json['avatar'],
      signature: json['singture'],
      status: json['status'],
      createdDate: json['created_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      businessInfo: json['business_info'] != null
          ? BusinessInfo.fromJson(json['business_info'])
          : null,
    );
  }
}

class BusinessInfo {
  final int id;
  final int userId;
  final String companyName;
  final String? email;
  final String? openingBalance;
  final String? date;
  final int? countryId;
  final String? currency;
  final String? address;
  final String? tradeLicenseNo;
  final int? businessCategoryId;
  final int? businessTypeId;
  final String? vatNo1;
  final String? vatNo2;
  final String? taxNo1;
  final String? taxNo2;
  final String? logo;
  final String? favicon;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  BusinessInfo({
    required this.id,
    required this.userId,
    required this.companyName,
    this.email,
    this.openingBalance,
    this.date,
    this.countryId,
    this.currency,
    this.address,
    this.tradeLicenseNo,
    this.businessCategoryId,
    this.businessTypeId,
    this.vatNo1,
    this.vatNo2,
    this.taxNo1,
    this.taxNo2,
    this.logo,
    this.favicon,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      id: json['id'],
      userId: json['user_id'],
      companyName: json['company_name'],
      email: json['email'],
      openingBalance: json['opening_balance'],
      date: json['date'],
      countryId: json['country_id'],
      currency: json['currency'],
      address: json['address'],
      tradeLicenseNo: json['tread_license_no'],
      businessCategoryId: json['business_category_id'],
      businessTypeId: json['business_type_id'],
      vatNo1: json['vat_no1'],
      vatNo2: json['vat_no2'],
      taxNo1: json['tax_no1'],
      taxNo2: json['tax_no2'],
      logo: json['logo'],
      favicon: json['favicon'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
