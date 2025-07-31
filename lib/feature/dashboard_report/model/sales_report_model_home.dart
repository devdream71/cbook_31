class SalesReportModel {
  final String date;
  final double sales;

  SalesReportModel({required this.date, required this.sales});

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      date: json['date'],
      sales: (json['sales'] as num).toDouble(),
    );
  }
}
