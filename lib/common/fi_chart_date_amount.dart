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

    // if (provider.salesList.isEmpty) {
    //   return const Center(
    //     child: Text(
    //       'No sales data available.',
    //       style: TextStyle(color: Colors.black),
    //     ),
    //   );
    // }

    if (provider.salesList.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie or SVG illustration placeholder (optional)
        Icon(
          Icons.bar_chart,
          size: 60,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'No sales data found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please adjust the filter or try refreshing.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Trigger provider refresh manually
            // Provider.of<DashboardReportProvider>(context, listen: false)
            //     .fetchDashboardReport();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}


    double maxY = provider.maxSalesValue();
    // double interval = (maxY / 4).ceilToDouble();
    double interval = ((maxY / 4).ceilToDouble()).clamp(1, double.infinity);

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

