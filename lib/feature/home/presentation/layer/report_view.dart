import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorTheme.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Report',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header Section
              const Text(
                'Sales Report',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                'Period: January 2024 - December 2024',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(),
              const SizedBox(height: 20),

              // Summary Section
              const Text(
                'Summary',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorTheme.primary, // Your color theme
                  borderRadius: BorderRadius.circular(
                      10.0), // Optional for rounded corners
                  boxShadow: const [
                    // Optional shadow for the decorated box
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ReportSummaryItem(
                        label: 'Total Sales',
                        value: '15,000',
                      ),
                      ReportSummaryItem(
                        label: 'Total Returns',
                        value: '1,500',
                      ),
                      ReportSummaryItem(
                        label: 'Net Sales',
                        value: '13,500',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Data Table Section
              const Text(
                'Sales Data',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey.shade200),
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Date',
                      style: TextStyle(color: Colors.black),
                    )),
                    DataColumn(
                        label: Text('Amount',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Return Amount',
                            style: TextStyle(color: Colors.black))),
                    DataColumn(
                        label: Text('Net Sales',
                            style: TextStyle(color: Colors.black))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Jan 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,200', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('150', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,050', style: TextStyle(color: Colors.black))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Feb 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,500', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('100', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,400', style: TextStyle(color: Colors.black))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Mar 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,800', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('200', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,600', style: TextStyle(color: Colors.black))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Apr 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,100', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('50', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,050', style: TextStyle(color: Colors.black))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('May 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,400', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('120', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,280', style: TextStyle(color: Colors.black))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jun 2024',
                          style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,200', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('100', style: TextStyle(color: Colors.black))),
                      DataCell(
                          Text('1,100', style: TextStyle(color: Colors.black))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A helper widget for displaying summary items in a card
class ReportSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const ReportSummaryItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
