// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class BarChartTop extends StatelessWidget {
//   const BarChartTop({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<ChartData> chartData = [
//       ChartData(1, 100),
//       ChartData(2, 80),
//       ChartData(3, 80),
//       ChartData(4, 100),
//       ChartData(5, 100),
//       ChartData(6, 120),
//       ChartData(7, 100),
//       ChartData(8, 90),
//       ChartData(9, 80),
//       ChartData(10, 100),
//       ChartData(11, 500), // Highest bar
//       ChartData(12, 100),
//       ChartData(13, 80),
//       ChartData(14, 100),
//       ChartData(15, 200),
//       ChartData(16, 300),
//       ChartData(17, 200),
//       ChartData(18, 100),
//       ChartData(19, 80),
//       ChartData(20, 90),
//       ChartData(21, 100),
//       ChartData(22, 90),
//       ChartData(23, 200),
//       ChartData(24, 100),
//       ChartData(25, 80),
//       ChartData(26, 400),
//       ChartData(27, 500), // Second highest bar
//       ChartData(28, 100),
//       ChartData(29, 100),
//       ChartData(30, 150),
//       ChartData(31, 100),
//     ];

//     return SfCartesianChart(
//       primaryXAxis: const CategoryAxis(
//         majorGridLines: MajorGridLines(width: 0),
//         labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//         labelRotation: -30, // Rotate the day labels by 20 degrees
//         interval: 1, // Ensure every day is displayed
//       ),
//       primaryYAxis: const NumericAxis(
//         interval: 100,
//         majorGridLines: MajorGridLines(width: 0.3),
//       ),
//       series: [
//         ColumnSeries<ChartData, int>(
//           dataSource: chartData,
//           xValueMapper: (ChartData data, _) => data.x,
//           yValueMapper: (ChartData data, _) => data.y,
//           color: const Color(0xff004aad),
//           width: 0.8,
//           spacing: 0.2, // Adjust spacing between bars
//         ),
//       ],
//     );
//   }
// }

// class ChartData {
//   ChartData(this.x, this.y);
//   final int x;
//   final double y;
// }
