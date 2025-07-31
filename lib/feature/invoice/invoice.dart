import 'dart:io';

import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceScreen extends StatefulWidget {
  final List<InvoiceItem> items;

  const InvoiceScreen({super.key, required this.items});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {

  Future<void> _viewPDF() async {
    try {
      final pdfFile = await generatePDF();
      if (await pdfFile.exists()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFPreviewScreen(pdfFile: pdfFile),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate PDF.")),
        );
      }
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _sharePDF() async {
    final pdfFile = await generatePDF();

    if (await pdfFile.exists()) {
      Share.shareXFiles([XFile(pdfFile.path)],
          text: "Here is your invoice PDF");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to generate PDF.")),
      );
    }
  }

  Future<void> _downloadPDF() async {
    final pdfFile = await generatePDF();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF Saved at: ${pdfFile.path}")),
    );
  }

  // Define file path

  Future<File> generatePDF() async {
    final totalAmount =
        widget.items.fold<double>(0.0, (sum, item) => sum + item.amount);
    final totalDiscount =
        widget.items.fold<double>(0.0, (sum, item) => sum + item.discount);
    final totalPayable = totalAmount - totalDiscount;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors
                  .grey200, // Light background color for a paper-like effect
              border: pw.Border.all(
                color: PdfColors.black,
                width: 2, // Border width
              ),
            ),
            padding: const pw.EdgeInsets.all(16), // Padding inside the border
            child: pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    child: pw.Column(children: [
                      pw.Text(
                        "Dream Tech International",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text("84/8 Naya Paltan, Dhaka",
                          style: const pw.TextStyle(color: PdfColors.black)),
                      pw.Text("01984994406",
                          style: const pw.TextStyle(color: PdfColors.black)),
                      pw.SizedBox(height: 10),
                      pw.Text("Invoice",
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black)),
                    ]),
                  ),

                  pw.SizedBox(height: 20),

                  // Bill To & Invoice Details
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Bill To:",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Cash Sales"),
                          pw.Text("Customer:}"),
                          pw.Text("Phone: "),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Bill No: Inv542",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Date: 12/10/2023"),
                          pw.Text("Bill Person:"),
                          pw.Text("Bill Time:"),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Invoice Items:",
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),

                      // Table Header
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                                  width: 1)), // Line under the header
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                                flex: 3,
                                child: pw.Text("Items",
                                    style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold))),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Text("Qty",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold))),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Text("Unit",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold))),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Text("Total",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold))),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 5),

                      // Invoice Items
                      ...widget.items.asMap().entries.map((entry) {
                        final item = entry.value;
                        return pw.Column(
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                    flex: 3,
                                    child: pw.Text(item.itemName,
                                        style:
                                            const pw.TextStyle(fontSize: 12))),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Text("${item.quantity}",
                                        textAlign: pw.TextAlign.center,
                                        style:
                                            const pw.TextStyle(fontSize: 12))),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Text(item.unit,
                                        textAlign: pw.TextAlign.center,
                                        style:
                                            const pw.TextStyle(fontSize: 12))),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Text(
                                        " ${item.amount.toStringAsFixed(2)}",
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold))),
                              ],
                            ),
                            pw.Divider(
                                thickness:
                                    0.6), // Horizontal line after each item
                          ],
                        );
                      }).toList(),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // Total Amounts
                  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.SizedBox(
                      width: 250,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          // _buildPDFRow("Qty", "3"),
                          _buildPDFRow("Qty ",
                              "${widget.items.fold(0, (sum, item) => sum + item.quantity)}"),

                          pw.Divider(
                            thickness: 1,
                            color: PdfColors.black,
                          ),

                         
                          _buildPDFRow("Amount", "tk. $totalAmount"),
                          _buildPDFRow("Discount", "tk. $totalDiscount"),
                          pw.Divider(thickness: 1, color: PdfColors.black),
                          _buildPDFRow("Total Amount", "tk. $totalPayable"),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Narration
                  pw.Text(
                    "Narration",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                      "The Right Place for Online Trading on Financial Markets. Learn More Now!"),
                ],
              ),
            ),
          );
        },
      ),
    );
   
    // Ensure storage permission is granted
    await _requestStoragePermission();

    // Get external storage directory (Downloads folder)
    Directory? directory = await getExternalStorageDirectory();
    String newPath = "";
    if (directory != null) {
      List<String> paths = directory.path.split("/");
      for (int i = 1; i < paths.length; i++) {
        if (paths[i] != "Android") {
          newPath += "/${paths[i]}";
        } else {
          break;
        }
      }
      newPath += "/Download"; // Save in Downloads folder
    } else {
      throw Exception("External storage not found.");
    }

    // Generate unique filename using date and time
    String formattedDate =
        DateTime.now().toIso8601String().replaceAll(":", "-");
    String fileName = "dt_invoice_$formattedDate.pdf";

    final file = File("$newPath/$fileName");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      openAppSettings();
    }
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("======");
    // print(widget.price.toString());
    // print(widget.qty.toString());

    for (var item in widget.items) {
      debugPrint("discount ====> ${item.discount}");
      debugPrint("amount => ${item.quantity}");
      
    }



    // print("${widget.items.first.itemName} ");

    return Scaffold(
      appBar: AppBar(title: const Text("Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text('${widget.items.first.itemName}}'),
                  const Text("Dream Tech International",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const Text(
                    "84/8 Naya Paltan, Dhaka",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  const Text(
                    "01984994406",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text("Invoice",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bill To:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    Text(
                      "Cash Sales",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    Text(
                      "Name: ",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    Text(
                      "Phone: ",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bill No: Inv542",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    Text(
                      "Date: 10/03/2025",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),

                    Text(
                      "Bill Person:",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    //Text("Bill Date:", style: TextStyle(color: Colors.black, fontSize: 12),),
                    Text(
                      "Bill Time:",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        headerCell("S.L", 35),
                        headerCell("Product name", 115),
                        headerCell("Qty", 45),
                        headerCell("Unit", 45),
                        headerCell("Price", 75),
                        headerCell("Amount", 50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Table Rows
                  ...List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    return tableRow(
                      sl: "  ${index + 1}",
                      productName: item.itemName,
                      qty: "  ${item.quantity}",
                      unit: '  ${item.unit}',
                      price:
                          "  ${item.amount / (item.quantity > 0 ? item.quantity : 1)}",
                      amount: "  ${item.amount}",
                    );
                  }),
                ],
              ),
            ),

            
            const SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildRow("Qty ",
                        "${widget.items.fold(0, (sum, item) => sum + item.quantity)}"), // Dynamic Qty
                    const DottedLine(),
                    // Dynamic Amount

                    _buildRow("Amount ",
                        "৳ ${widget.items.fold<double>(0.0, (sum, item) => sum + item.amount)}"),

                     
                    const DottedLine(),
                     
                    _buildRow(
                      "Discount",
                      widget.items.isNotEmpty
                          ? "${widget.items.first.discount}"
                          : "৳ 0.0",
                    ),

                    const DottedLine(),

                    _buildRow("Total Amount:",
                        "৳ ${widget.items.fold(0.0, (sum, item) => sum + item.amount) - widget.items.fold(0.0, (sum, item) => sum + item.discount)}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Narration",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "The Right Place for Online Trading on Financial Markets. Learn More Now! Get",
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
            const Spacer(),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _sharePDF,
                    icon: const Icon(Icons.share),
                    label: const Text("Share PDF"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  ElevatedButton.icon(
                    onPressed: _viewPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("View PDF"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  ElevatedButton.icon(
                    onPressed: _downloadPDF,
                    icon: const Icon(Icons.download),
                    label: const Text("Download PDF"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black),
      ),
    );
  }

  Widget tableRow({
    required String sl,
    required String productName,
    required String qty,
    required String unit,
    required String price,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          rowCell(sl, 35),
          rowCell(productName, 115),
          rowCell(qty, 45),
          rowCell(unit, 45),
          rowCell(price, 75),
          rowCell(amount, 50),
        ],
      ),
    );
  }

  Widget rowCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      ),
    );
  }
}

class PDFPreviewScreen extends StatefulWidget {
  final File pdfFile;

  const PDFPreviewScreen({super.key, required this.pdfFile});

  @override
  State<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  bool isPDFReady = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isPDFReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: Center(
        child: isPDFReady
            ? PDFView(
                filePath: widget.pdfFile.path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                onRender: (pages) {
                  setState(() {});
                },
                onError: (error) {
                  debugPrint(error.toString());
                },
                onPageError: (page, error) {
                  debugPrint('Page $page: ${error.toString()}');
                },
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
