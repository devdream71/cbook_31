import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChartViewRound extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final List<String> legendLabels;

  const DonutChartViewRound({
    super.key,
    required this.values,
    required this.labels,
    required this.legendLabels,
  });

  @override
  DonutChartViewRoundState createState() => DonutChartViewRoundState();
}

class DonutChartViewRoundState extends State<DonutChartViewRound>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> colors = [
    Colors.green,
    Colors.orange,
     AppColors.purple2,
    Colors.purple,
  ];

  double get totalValue => widget.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCirc,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PieChartSectionData> _buildAnimatedSections(double sweepPercent) {
    double sweepTotal = totalValue * sweepPercent;
    double consumed = 0;

    List<PieChartSectionData> animatedSections = [];

    for (int i = 0; i < widget.values.length; i++) {
      double remaining = sweepTotal - consumed;
      double currentValue = widget.values[i];

      if (remaining <= 0) break;

      double shownValue = remaining >= currentValue ? currentValue : remaining;

      animatedSections.add(
        PieChartSectionData(
          color: colors[i],
          value: shownValue,
          title: shownValue >= currentValue
              ? "${widget.labels[i]}\n${widget.values[i].toInt()}৳"
              : "",
          radius: 39,
          titleStyle: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      consumed += shownValue;
    }

    return animatedSections;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut chart
              SizedBox(
                width: 170,
                height: 170,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return PieChart(
                      PieChartData(
                        sections: _buildAnimatedSections(_animation.value),
                        centerSpaceRadius: 35,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 24),

              // Legend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.legendLabels.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: colors[index],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.legendLabels[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                height: 15,
                width: 15,
                color: Colors.green,
              ),
              const SizedBox(
                width: 2,
              ),

              /// 
              const Text(
                'Received',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                height: 15,
                width: 15,
                color: Colors.orange,
              ),
              const SizedBox(
                width: 2,
              ),
              const Text('Payment',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(
                width: 8,
              ),
              Container(
                height: 15,
                width: 15,
                color: AppColors.purple2,
              ),
              const SizedBox(
                width: 2,
              ),
              const Text('Income',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(
                width: 8,
              ),
              Container(
                height: 15,
                width: 15,
                color: Colors.purple,
              ),
              const SizedBox(
                width: 2,
              ),
              const Text('Expense',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}



