class CompanyProfileUpdate {
  final int id;
  final String? name;
  final String? nickName;
  final String? email;
  final String? phone;
  final int? countryId;
  final String? currency;
  final String? address;
  final String? avatar;
  final String? signature;
  final String? companyName;

  CompanyProfileUpdate({
    required this.id,
    this.name,
    this.nickName,
    this.email,
    this.phone,
    this.countryId,
    this.currency,
    this.address,
    this.avatar,
    this.signature,
    this.companyName,
  });

  factory CompanyProfileUpdate.fromJson(Map<String, dynamic> json) {
    return CompanyProfileUpdate(
      id: json['id'],
      name: json['name'],
      nickName: json['nick_name'],
      email: json['email'],
      phone: json['phone'],
      countryId: json['country_id'],
      currency: json['currency'],
      address: json['address'],
      avatar: json['avatar'],
      signature: json['singture'],
      companyName: json['company_name'],
    );
  }
}
