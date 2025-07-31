import 'package:flutter/material.dart';
import 'package:qr_flutter_new/qr_flutter.dart';

class CustomInvoicePage extends StatelessWidget {
  const CustomInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Pdf view",
          style: TextStyle(
              color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header Section
              Container(
                color: Colors.green[800],
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/image/cbook_logo.png",
                            height: 40), // Replace with your logo
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dream Tech International",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "84/8 Naya paltan,Dhaka",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              "01898494406",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                    const RotatedBox(
                      quarterTurns: -1,
                      child: Text("Unpaid",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Bill to and Info
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bill To:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 12)),
                        Text("Fridi Store",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Text("Md Jasim Uddin Nizami",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Text("01984994406",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Text("jasim5814@gmail.com",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Text("Laksam, Cumilla",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bill No: Inv542",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Date: 12/10/2023",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Bill Person:",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Hasan Gaffar",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 10),
              const Text("Invoice",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black)),
              const SizedBox(height: 10),

              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FixedColumnWidth(30),
                    1: FixedColumnWidth(130),
                    2: FixedColumnWidth(90),
                    3: FixedColumnWidth(60),
                    4: FixedColumnWidth(60), // Increased Qty width
                    5: FixedColumnWidth(60), // Increased Unit width
                    6: FixedColumnWidth(60),
                    7: FixedColumnWidth(70),
                  },
                  children: [
                    _buildTableHeader(),
                    _buildTableRow([
                      "01",
                      "Hp Monitor DGR",
                      "HP452144",
                      "18,500",
                      "02",
                      "Pc",
                      "18,000",
                      "36,000"
                    ]),
                    _buildTableRow([
                      "02",
                      "DELL Monitore",
                      "DELL12546",
                      "17,000",
                      "01",
                      "Pc",
                      "17,000",
                      "34,000"
                    ]),

                    /// ✅ Inserted White Spacer Row Before Total
                    TableRow(
                      children: List.generate(8, (_) {
                        return Container(
                          height: 20,
                          color: Colors.white,
                          child: const Text(""),
                        );
                      }),
                    ),

                    _buildTotalRow(),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Bottom Info and QR
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      "The Right Place for Online Trading on Financial Markets.",
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  QrImageView(
                    data: "Invoice#Inv542",
                    size: 80,
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Discount  2%         1,000",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Vat/Tax  15%       4,500",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Total Amount     53,500",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text("Due                     53,500",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),
              // Footer Signatures
              const Divider(thickness: 0.8),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Receiver",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                  Text("Sales Person",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                  Text("Manager",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                ],
              ),

              // SizedBox(height: 8,),

              // Text('data', style: TextStyle(color: Colors.black),)
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black);
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xfff2f2f2)),
      children: [
        _tableCell("SL", headerStyle),
        _tableCell("Product name", headerStyle),
        _tableCell("Code", headerStyle),
        _tableCell("MRP", headerStyle),
        _tableCell("Qty", headerStyle),
        _tableCell("Unit", headerStyle),
        _tableCell("Price", headerStyle),
        _tableCell("Amount", headerStyle),
      ],
    );
  }

  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values
          .map((text) => Padding(
                padding: const EdgeInsets.all(6),
                child: Text(text,
                    style: const TextStyle(fontSize: 12, color: Colors.black)),
              ))
          .toList(),
    );
  }

  TableRow _buildTotalRow() {
    const TextStyle totalStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12);
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xfff2f2f2)),
      children: [
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        _tableCell("Total", totalStyle),
        _tableCell("03", totalStyle),
        const SizedBox(),
        _tableCell("50,000", totalStyle),
      ],
    );
  }

  Widget _tableCell(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }
}
