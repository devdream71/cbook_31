import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBarChart extends StatefulWidget {
  const CustomBarChart({super.key});

  @override
  CustomBarChartState createState() => CustomBarChartState();
}

class CustomBarChartState extends State<CustomBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BarChartGroupData> _buildAnimatedBars(
      double animationValue, List<SalesReportModel> salesList) {
    return List.generate(salesList.length, (index) {
      double value = salesList[index].sales.toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value * animationValue,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50),
                const Color(0xFF81C784),
                Colors.lightGreen.shade300,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: value,
              color: Colors.grey.shade200.withOpacity(0.3),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardReportProvider>(context);

    if (provider.isLoading) {
      return const Center(child: SizedBox());
    }

    if (provider.salesList.isEmpty) {
      return const Center(
        child: Text(
          'No sales data available.',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    double maxY = provider.maxSalesValue();
    double interval = (maxY / 4).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const SizedBox(height: 10),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY + 10,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87.withOpacity(0.8),
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = provider.salesList[group.x].date;
                            return BarTooltipItem(
                              '৳${rod.toY.toStringAsFixed(0)}\n$date',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) => Container(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.teal.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 35,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              if (index % 2 == 0 &&
                                  index < provider.salesList.length) {
                                return Transform.rotate(
                                  angle: -0.6,
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      provider.salesList[index].date,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.purple.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                          bottom:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: interval,
                        verticalInterval: 1,
                        drawHorizontalLine: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade400,
                          strokeWidth: 1.2,
                          dashArray: [4, 4],
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.shade400,
                          strokeWidth: 1.2,
                          dashArray: [4, 4],
                        ),
                      ),
                      barGroups: _buildAnimatedBars(
                          _animation.value, provider.salesList),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
// import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CustomBarChart extends StatefulWidget {
//   const CustomBarChart({super.key});

//   @override
//   CustomBarChartState createState() => CustomBarChartState();
// }

// class CustomBarChartState extends State<CustomBarChart>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   List<BarChartGroupData> _buildAnimatedBars(
//       double animationValue, List<SalesReportModel> salesList) {
//     return List.generate(salesList.length, (index) {
//       double value = salesList[index].sales.toDouble();
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: value * animationValue,
//             gradient: LinearGradient(
//               colors: [
//                 const Color(0xFF4CAF50),
//                 const Color(0xFF81C784),
//                 Colors.lightGreen.shade300,
//               ],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//             width: 12,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//             // Add shadow effect to bars
//             backDrawRodData: BackgroundBarChartRodData(
//               show: true,
//               toY: value,
//               color: Colors.grey.shade200.withOpacity(0.3),
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashboardReportProvider>(context);

//     if (provider.isLoading) {
//       return const Center(child: SizedBox());
//     }

//     if (provider.salesList.isEmpty) {
//       return const Center(
//         child: Text(
//           'No sales data available.',
//           style: TextStyle(color: Colors.black),
//         ),
//       );
//     }

//     double maxY = provider.maxSalesValue();
//     double interval = (maxY / 4).ceilToDouble();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 240,
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return Container(
//                   ////===>best one
//                   decoration: BoxDecoration(
//                     // Modern gradient background
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.blue.shade50,
//                         Colors.indigo.shade50,
//                         Colors.white,
//                         Colors.green.shade50,
//                       ],
//                       stops: const [0.0, 0.3, 0.7, 1.0],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     // Add shadow
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade300,
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                         spreadRadius: 2,
//                       ),
//                     ],
//                     // Add border
//                     border: Border.all(
//                       color: Colors.grey.shade200,
//                       width: 1,
//                     ),
//                   ),
//                   // Add padding inside container
//                   padding: const EdgeInsets.all(16),
//                   child: BarChart(
//                     BarChartData(
//                       maxY: maxY + 10,
//                       minY: 0,
//                       barTouchData: BarTouchData(
//                         enabled: true,
//                         touchTooltipData: BarTouchTooltipData(
//                           tooltipBgColor: Colors.black87.withOpacity(0.8),
//                           tooltipRoundedRadius: 8,
//                           tooltipPadding: const EdgeInsets.all(8),
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             final date = provider.salesList[group.x].date;
//                             return BarTooltipItem(
//                               '৳${rod.toY.toStringAsFixed(0)}\n$date',
//                               const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: interval,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, _) => Container(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: Text(
//                                 '${value.toInt()}',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.teal.shade600,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: 1,
//                             reservedSize: 35,
//                             getTitlesWidget: (value, _) {
//                               int index = value.toInt();
//                               if (index % 2 == 0 &&
//                                   index < provider.salesList.length) {
//                                 return Transform.rotate(
//                                   angle: -0.6,
//                                   child: Container(
//                                     padding: const EdgeInsets.only(top: 8),
//                                     child: Text(
//                                       provider.salesList[index].date,
//                                       style: TextStyle(
//                                         fontSize: 9,
//                                         color: Colors.purple.shade600,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ),
//                         rightTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                         topTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(
//                         show: true,
//                         border: Border(
//                           left:
//                               BorderSide(color: Colors.grey.shade300, width: 1),
//                           bottom:
//                               BorderSide(color: Colors.grey.shade300, width: 1),
//                         ),
//                       ),
//                       gridData: FlGridData(
//                         show: true,
//                         horizontalInterval: interval,
//                         verticalInterval: 1,
//                         drawVerticalLine: false,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey.shade300.withOpacity(0.5),
//                           strokeWidth: 0.8,
//                           dashArray: [5, 5], // Dashed lines
//                         ),
//                       ),
//                       barGroups: _buildAnimatedBars(
//                           _animation.value, provider.salesList),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//// good one. with bg
// import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
// import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CustomBarChart extends StatefulWidget {
//   const CustomBarChart({super.key});

//   @override
//   CustomBarChartState createState() => CustomBarChartState();
// }

// class CustomBarChartState extends State<CustomBarChart>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   List<BarChartGroupData> _buildAnimatedBars(
//       double animationValue, List<SalesReportModel> salesList) {
//     return List.generate(salesList.length, (index) {
//       double value = salesList[index].sales.toDouble();
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: value * animationValue,
//             gradient: LinearGradient(
//               colors: [
//                 const Color(0xFF4CAF50),
//                 const Color(0xFF81C784),
//                 Colors.lightGreen.shade300,
//               ],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//             width: 12,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//             // Add shadow effect to bars
//             backDrawRodData: BackgroundBarChartRodData(
//               show: true,
//               toY: value,
//               color: Colors.grey.shade200.withOpacity(0.3),
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashboardReportProvider>(context);

//     if (provider.isLoading) {
//       return const Center(child: SizedBox());
//     }

//     if (provider.salesList.isEmpty) {
//       return const Center(
//         child: Text(
//           'No sales data available.',
//           style: TextStyle(color: Colors.black),
//         ),
//       );
//     }

//     double maxY = provider.maxSalesValue();
//     double interval = (maxY / 4).ceilToDouble();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 240,
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     // Modern gradient background
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.blue.shade50,
//                         Colors.indigo.shade50,
//                         Colors.white,
//                         Colors.green.shade50,
//                       ],
//                       stops: const [0.0, 0.3, 0.7, 1.0],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     // Add shadow
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade300,
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                         spreadRadius: 2,
//                       ),
//                     ],
//                     // Add border
//                     border: Border.all(
//                       color: Colors.grey.shade200,
//                       width: 1,
//                     ),
//                   ),
//                   // Add padding inside container
//                   padding: const EdgeInsets.all(16),
//                   child: BarChart(
//                     BarChartData(
//                       maxY: maxY + 10,
//                       minY: 0,
//                       barTouchData: BarTouchData(
//                         enabled: true,
//                         touchTooltipData: BarTouchTooltipData(
//                           tooltipBgColor: Colors.black87.withOpacity(0.8),
//                           tooltipRoundedRadius: 8,
//                           tooltipPadding: const EdgeInsets.all(8),
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             final date = provider.salesList[group.x].date;
//                             return BarTooltipItem(
//                               '৳${rod.toY.toStringAsFixed(0)}\n$date',
//                               const TextStyle(
//                                 color: Colors.white, 
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: interval,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, _) => Container(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: Text(
//                                 '${value.toInt()}',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.teal.shade600,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: 1,
//                             reservedSize: 35,
//                             getTitlesWidget: (value, _) {
//                               int index = value.toInt();
//                               if (index % 2 == 0 &&
//                                   index < provider.salesList.length) {
//                                 return Transform.rotate(
//                                   angle: -0.6,
//                                   child: Container(
//                                     padding: const EdgeInsets.only(top: 8),
//                                     child: Text(
//                                       provider.salesList[index].date,
//                                       style: TextStyle(
//                                         fontSize: 9, 
//                                         color: Colors.purple.shade600,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ),
//                         rightTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                         topTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(
//                         show: true,
//                         border: Border(
//                           left: BorderSide(color: Colors.grey.shade300, width: 1),
//                           bottom: BorderSide(color: Colors.grey.shade300, width: 1),
//                         ),
//                       ),
//                       gridData: FlGridData(
//                         show: true,
//                         horizontalInterval: interval,
//                         verticalInterval: 1,
//                         drawVerticalLine: false,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey.shade300.withOpacity(0.5),
//                           strokeWidth: 0.8,
//                           dashArray: [5, 5], // Dashed lines
//                         ),
//                       ),
//                       barGroups: _buildAnimatedBars(
//                           _animation.value, provider.salesList),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


////=====> old fi_chart
// import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
// import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CustomBarChart extends StatefulWidget {
//   const CustomBarChart({super.key});

//   @override
//   CustomBarChartState createState() => CustomBarChartState();
// }

// class CustomBarChartState extends State<CustomBarChart>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   List<BarChartGroupData> _buildAnimatedBars(
//       double animationValue, List<SalesReportModel> salesList) {
//     return List.generate(salesList.length, (index) {
//       double value = salesList[index].sales.toDouble();
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: value * animationValue,
//             gradient: const LinearGradient(
//               colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//             width: 10,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashboardReportProvider>(context);

//     if (provider.isLoading) {
//       return const Center(child: SizedBox());
//     }

//     if (provider.salesList.isEmpty) {
//       return const Center(
//         child: Text(
//           'No sales data available.',
//           style: TextStyle(color: Colors.black),
//         ),
//       );
//     }

//     double maxY = provider.maxSalesValue();
//     double interval = (maxY / 4).ceilToDouble();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 240,
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100, // Light grey background
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: BarChart(
//                     BarChartData(
//                       maxY: maxY + 10,
//                       minY: 0,
//                       barTouchData: BarTouchData(
//                         enabled: true,
//                         touchTooltipData: BarTouchTooltipData(
//                           tooltipBgColor: Colors.black87,
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             final date = provider.salesList[group.x].date;
//                             return BarTooltipItem(
//                               '৳${rod.toY.toStringAsFixed(0)}\n$date',
//                               const TextStyle(
//                                   color: Colors.white, fontSize: 12),
//                             );
//                           },
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: interval,
//                             reservedSize: 32,
//                             getTitlesWidget: (value, _) => Padding(
//                               padding: const EdgeInsets.only(right: 0), //6 was
//                               child: Text(
//                                 '${value.toInt()}',
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.teal,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             interval: 1,
//                             getTitlesWidget: (value, _) {
//                               int index = value.toInt();
//                               if (index % 2 == 0 &&
//                                   index < provider.salesList.length) {
//                                 return Transform.rotate(
//                                   angle: -0.8,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(top: 10.0),
//                                     child: Text(
//                                       provider.salesList[index].date,
//                                       style: const TextStyle(
//                                           fontSize: 9, color: Colors.purple),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ),
//                         rightTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                         topTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       gridData: FlGridData(
//                         show: true,
//                         horizontalInterval: 20,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey.shade100,
//                           strokeWidth: 0.8,
//                         ),
//                       ),
//                       barGroups: _buildAnimatedBars(
//                           _animation.value, provider.salesList),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
