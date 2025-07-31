import 'package:flutter/material.dart';

class ReturnTableScreen extends StatelessWidget {
  const ReturnTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Table(
                border: TableBorder.all(
                  color: Colors.black, // Black border for the entire table
                  width: 1, // Border thickness
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2), // Wider column for Item Name
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  // Table Header
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color(0xffbac3ef), // Header background color
                    ),
                    children: [
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            "Item Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            "Unit",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            "Qty",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            "Price",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            "Amount",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Table Rows with TextField and Fixed Height
                  for (int i = 0; i < 3; i++)
                    const TableRow(
                      children: [
                        SizedBox(
                          height: 30,
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Column(
            children: List.generate(
              3, // Number of rows
              (index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(
                  Icons.pending_outlined,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
