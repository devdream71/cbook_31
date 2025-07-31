import 'package:flutter/material.dart';

class TableView extends StatelessWidget {
  final List<List<String>> tableData = [
    ["12/12/2024", "Sal-3541635", "Jasim", "2,500"],
    ["12/12/2024", "Pur-6123", "Korim", "3,600"],
    ["12/12/2024", "RCV-2313", "Rohim", "7,500"],
    ["12/12/2024", "PAV-23131", "Korim", "2,300"],
    ["12/12/2024", "IN-23131", "Korim", "3,600"],
    ["12/12/2024", "EX-35213", "Rohim", "200"],
    ["12/12/2024", "Con-3213", "Rohim", "200"],
    ["12/12/2024", "JUV-23131", "Korim", "20,000"],
    ["12/12/2024", "Sal-3541635", "Jasim", "2,500"],
    ["12/12/2024", "Pur-6123", "Korim", "3,600"],
    ["12/12/2024", "RCV-2313", "Rohim", "7,500"],
    ["12/12/2024", "PAV-23131", "Korim", "2,300"],
    ["12/12/2024", "IN-23131", "Korim", "3,600"],
    ["12/12/2024", "EX-35213", "Rohim", "200"],
  ];

   TableView({super.key});

  TableRow buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.green),
      children: [
        tableCell("Date", isHeader: true, align: TextAlign.center),
        tableCell("Bill No", isHeader: true, align: TextAlign.left),
        tableCell("Account Name", isHeader: true, align: TextAlign.left),
        tableCell("Amount", isHeader: true, align: TextAlign.right),
      ],
    );
  }

  TableCell tableCell(String text,
      {bool isHeader = false, TextAlign align = TextAlign.center}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.white : Colors.black,
          ),
          textAlign: align,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(2),
        },
        border: TableBorder.all(color: Colors.transparent),
        children: [
          buildHeaderRow(),
          ...tableData.asMap().entries.map((entry) {
            int index = entry.key;
            List<String> row = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey.shade200,
              ),
              children: [
                tableCell(row[0], align: TextAlign.center),
                tableCell(row[1], align: TextAlign.left),
                tableCell(row[2], align: TextAlign.left),
                tableCell(row[3], align: TextAlign.right),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
