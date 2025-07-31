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
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
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
          
           const SizedBox(height: 10),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Light grey background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY + 10,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = provider.salesList[group.x].date;
                            return BarTooltipItem(
                              '৳${rod.toY.toStringAsFixed(0)}\n$date',
                              const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 32,
                            getTitlesWidget: (value, _) => Padding(
                              padding: const EdgeInsets.only(right: 0), //6 was
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              if (index % 2 == 0 &&
                                  index < provider.salesList.length) {
                                return Transform.rotate(
                                  angle: - 0.8,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      provider.salesList[index].date,
                                      style: const TextStyle(
                                          fontSize: 9, color: Colors.purple),
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
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade100,
                          strokeWidth: 0.8,
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

