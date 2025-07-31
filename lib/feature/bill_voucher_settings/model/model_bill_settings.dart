class BillSettingModel {
  final String data;
  final String? value;

  BillSettingModel({required this.data, required this.value});

  factory BillSettingModel.fromJson(Map<String, dynamic> json) {
    return BillSettingModel(
      data: json['data'],
      value: json['value'],
    );
  }
}
