import 'dart:io';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dotted_line/dotted_line.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';  

class NewInvoicePage extends StatefulWidget {
  final List<InvoiceItem> items;
  final String customerName;
  final String? billPersion;
  final dynamic discountPercent;
  final dynamic discountAmount;
  final dynamic taxIdPercent;
  final dynamic taxAmount;
  const NewInvoicePage({
    super.key,
    required this.items,
    required this.customerName,
    this.billPersion,
    this.discountAmount,
    this.discountPercent,
    this.taxIdPercent,
    this.taxAmount,
  });

  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  String selectedStatus = "1";

  String? selectedDropdownValue;

  Future<Uint8List> loadLogoImage() async {
    final data = await rootBundle.load('assets/image/cbook_logo.png');
    return data.buffer.asUint8List();
  }

  ///=======>share pdf
  Future<void> _viewPDF() async {
    ///discount text , left right
    pw.Widget customDiscount(String text, String text2) {
      return pw.Container(
        width: 150,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(text,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
            pw.Text(text2,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
          ],
        ),
      );
    }

    // Calculate total quantity
    final totalQuantity = widget.items.fold<int>(
      0,
      (previousValue, element) => previousValue + (element.quantity),
    );

    // Calculate total amount
    final totalAmount = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ),
    );

    // Format
    final formattedTotalAmount = NumberFormat("#,##0.00").format(totalAmount);

    //convert to number to word
    String convertDoubleToWords(double value) {
      int wholePart = value.floor();
      int decimalPart = ((value - wholePart) * 100).round();

      String words = "${NumberToWordsEnglish.convert(wholePart)} taka";
      if (decimalPart > 0) {
        words += " and ${NumberToWordsEnglish.convert(decimalPart)} paisa";
      }
      return words[0].toUpperCase() + words.substring(1);
    }

    pw.Widget buildDottedLine(
        {double width = 150, double dotSize = 1, int dotCount = 50}) {
      return pw.Container(
        width: width,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(dotCount, (_) {
            return pw.Container(
              width: dotSize,
              height: 1,
              color: PdfColors.grey,
            );
          }),
        ),
      );
    }

    final pdf = pw.Document();

    final pw.TextStyle headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );

    const pw.TextStyle cellStyle = pw.TextStyle(
      fontSize: 8,
    );

    bool showCompanyPhoneNumber = false;
    bool showMRP = false;
    bool showQRCode = false;
    bool showbodyWaterMarkLogo = false;
    bool showItemDiscountAndPercentance = false;
    bool showItemVatTaxAmountAndPercentance = false;
    bool showItemCode = false;
    //bool showSlNo = false;
    bool showBillDiscountAmountAndPercentance = false;
    bool showBillVatTaxAmountAndPercentance = false;
    bool showAmountinWord = false;
    //bool showNarration = false;
    //bool showSignatureRightShow = false;

    Future<void> _loadCheckboxState() async {
      final prefs = await SharedPreferences.getInstance();
      bool? isChecked = prefs.getBool('checkbox_Company Phone Number');
      final mrpChecked = prefs.getBool('checkbox_MRP');
      final qrCodeChecked = prefs.getBool('checkbox_QR Code');
      final bodyWaterMarkLogo = prefs.getBool('checkbox_Body Watermark logo');
      final itemDiscountAndPercentance =
          prefs.getBool('checkbox_Item Discount Amount & Percentance');
      final itemVatTaxAmountAndPercentance =
          prefs.getBool('checkbox_ItemVatTaxAmountAndPercentance');
      final itemCode = prefs.getBool('checkbox_Item Code');
      final siNo = prefs.getBool('checkbox_S.l No');
      final billDiscountAmountAndPercentance =
          prefs.getBool('checkbox_Bill Discount Amount & Percentance');
      final billVatTaxAmountAndPercentance =
          prefs.getBool('checkbox_Bill Vat/Tax Amount & Percentance');
      final amountinWord = prefs.getBool('checkbox_Amount in Word');
      final narrationNote = prefs.getBool('checkbox_Narration');
      //final signatureRightShow = prefs.getBool('checkbox_Signature Right Show');

      setState(() {
        showCompanyPhoneNumber = isChecked ?? false;
        showMRP = mrpChecked ?? false;
        showQRCode = qrCodeChecked ?? false;
        showbodyWaterMarkLogo = bodyWaterMarkLogo ?? false;

        showItemDiscountAndPercentance = itemDiscountAndPercentance ?? false;
        showItemVatTaxAmountAndPercentance =
            itemVatTaxAmountAndPercentance ?? false;
        showItemCode = itemCode ?? false;
        showSlNo = siNo ?? false;
        showBillDiscountAmountAndPercentance =
            billDiscountAmountAndPercentance ?? false;
        showBillVatTaxAmountAndPercentance =
            billVatTaxAmountAndPercentance ?? false;
        showAmountinWord = amountinWord ?? false;
        showNarration = narrationNote ?? false;
        //showSignatureRightShow = signatureRightShow ?? false;
      });
    }

    final logoBytes = await loadLogoImage();
    final logoImage = pw.MemoryImage(logoBytes);

    // final columnAlignments = {
    //   0: pw.Alignment.center, // SL
    //   1: pw.Alignment.bottomLeft, // Product
    //   2: pw.Alignment.center, // Code
    //   3: pw.Alignment.center, // MRP
    //   4: pw.Alignment.center, // Qty
    //   5: pw.Alignment.center, // Unit
    //   6: pw.Alignment.center, // Price
    //   7: pw.Alignment.center, //discount
    //   8: pw.Alignment.center, //vat
    //   9: pw.Alignment.center, // Amount
    // };

    pdf.addPage(
      // Define styles (place this at the top of your _viewPDF method)

      // Define these styles at the top of your method or widget

      // Define styles (place this at the top of your _viewPDF method)

      pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin:
              const pw.EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 1),
          build: (pw.Context context) => pw.Stack(children: [
                if (showbodyWaterMarkLogo)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.09,
                      child: pw.Center(
                        child: pw.Image(
                          logoImage,
                          width: 300,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          //left
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Dream Tech International",
                                    style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text("84/8 Naya Paltan, Dhaka",
                                    style: const pw.TextStyle(fontSize: 9)),
                                // pw.Text("0198994406",
                                //     style: const pw.TextStyle(fontSize: 9)),
                                if (showCompanyPhoneNumber)
                                  pw.Text('Phone: 01759546853',
                                      style: const pw.TextStyle(fontSize: 9)),
                              ]),

                          //right image
                          pw.SizedBox(
                            width: 40,
                            height: 40,
                            child: pw.Image(logoImage),
                          ),
                        ]),
                    pw.SizedBox(height: 8),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("Invoice",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Bill to:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 9)),
                              pw.Text(widget.customerName,
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold))
                            ],
                          ),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("Bill No: inv542",
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.Text(
                                  "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                                  style: const pw.TextStyle(
                                      color: PdfColors.black, fontSize: 9),
                                ),
                                pw.Text(
                                    "Bill Person:  ${widget.billPersion != null && widget.billPersion!.trim().isNotEmpty ? widget.billPersion : "No Bill Person"}",
                                    style: const pw.TextStyle(fontSize: 9))
                              ]),
                        ]),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        "Paid",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green, // ✅ Set text color here
                        ),
                      ),
                    ),
                    pw.Table(
                      border: pw.TableBorder(
                        bottom: pw.BorderSide(
                          color: PdfColor.fromHex('#f5f5f5'),
                          width: 0.5,
                        ),
                      ),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1), // SL
                        1: const pw.FlexColumnWidth(4), // Product
                        if (showItemCode)
                          2: const pw.FlexColumnWidth(2), // Code
                        if (showMRP) 3: const pw.FlexColumnWidth(2), // MRP
                        /* (showMRP ? 4 : 3)*/ 4:
                            const pw.FlexColumnWidth(2), // Qty
                        /*(showMRP ? 5 : 4)*/ 5:
                            const pw.FlexColumnWidth(2), // Unit
                        /*(showMRP ? 6 : 5)*/ 6:
                            const pw.FlexColumnWidth(2), // Price
                        /*(showItemDiscountAndPercentance ? 7 : 6)*/ 7:
                            const pw.FlexColumnWidth(2), // Discount
                        /*(showItemVatTaxAmountAndPercentance ? 8 : 7)*/ 8:
                            const pw.FlexColumnWidth(2), // VAT
                        /*(showMRP ? 9 : 8)*/ 9:
                            const pw.FlexColumnWidth(2), // Amount
                      },
                      children: [
                        // Header Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('E0E0E0'),
                          ),
                          children: [
                            pw.Text("S.L", style: headerStyle),
                            pw.Text("Product", style: headerStyle),
                            if (showItemCode)
                              pw.Text("Code", style: headerStyle),
                            if (showMRP) pw.Text("MRP", style: headerStyle),
                            pw.Text("Qty", style: headerStyle),
                            pw.Text("Unit", style: headerStyle),
                            pw.Text("Price", style: headerStyle),
                            if (showItemDiscountAndPercentance)
                              pw.Text("Discount", style: headerStyle),
                            if (showItemVatTaxAmountAndPercentance)
                              pw.Text("Vat/Tax", style: headerStyle),
                            pw.Text("Amount", style: headerStyle),
                          ]
                              .map((cell) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: cell,
                                    ),
                                  ))
                              .toList(),
                        ),

                        // Data Rows
                        for (int i = 0; i < widget.items.length; i++)
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                    color: PdfColors.black, width: 0.3),
                              ),
                            ),
                            children: [
                              pw.Text('${i + 1}', style: cellStyle),
                              pw.Text(widget.items[i].itemName,
                                  style: cellStyle),
                              if (showItemCode) pw.Text('-', style: cellStyle),
                              if (showMRP) pw.Text('0', style: cellStyle),
                              pw.Text(widget.items[i].quantity.toString(),
                                  style: cellStyle),
                              pw.Text(widget.items[i].unit,
                                  style: cellStyle),
                              pw.Text(
                                ((widget.items[i].amount /
                                        (widget.items[i].quantity > 0
                                            ? widget.items[i].quantity
                                            : 1)))
                                    .toStringAsFixed(2),
                                style: cellStyle,
                              ),
                              if (showItemDiscountAndPercentance)
                                pw.Text(
                                  '${widget.items[i].itemDiscountPercentace?.toStringAsFixed(0) ?? '0'}% '
                                  '${widget.items[i].itemDiscountAmount?.toStringAsFixed(2) ?? '0.00'}',
                                  style: cellStyle,
                                ),
                              if (showItemVatTaxAmountAndPercentance)
                                pw.Text(
                                  '${widget.items[i].itemvatTaxPercentace?.toStringAsFixed(0) ?? '0'}% '
                                  '${widget.items[i].itemVatTaxAmount?.toStringAsFixed(2) ?? '0.00'}',
                                  style: cellStyle,
                                ),
                              pw.Text(
                                widget.items[i].amount.toStringAsFixed(2),
                                style: cellStyle,
                              ),
                            ]
                                .map((cell) => pw.Padding(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: cell,
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text("Total: $totalQuantity",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.SizedBox(
                          width: 20,
                        ),
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(formattedTotalAmount,
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        //left
                        pw.SizedBox(
                          width: 150,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 4.0),
                            child: pw.Text(
                              "The Right Place for Online Trading on Financial Markets.",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),

                        pw.SizedBox(width: 10),

                        if (showQRCode)
                          pw.SizedBox(
                            width: 70,
                            height: 70,
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: 'Invoice#Inv542',
                              width: 50,
                              height: 50,
                            ),
                          ),

                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            //discount
                            if (showBillDiscountAmountAndPercentance)
                              buildDottedLine(),
                            if (showBillDiscountAmountAndPercentance)
                              customDiscount(
                                  "Discount ${widget.discountPercent}%",
                                  "${widget.discountAmount}"),
                            if (showBillVatTaxAmountAndPercentance)
                              buildDottedLine(),
                            if (showBillVatTaxAmountAndPercentance)
                              customDiscount(
                                  "Vat/Tax ${widget.discountPercent}%",
                                  "${widget.discountAmount}"),
                            buildDottedLine(),
                            customDiscount(
                                "Total Amount", formattedTotalAmount),
                            buildDottedLine(),
                            customDiscount("Due", "0"),
                            buildDottedLine(),
                            customDiscount("Paid", ""),
                            buildDottedLine(),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 20),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (showAmountinWord)
                            pw.Align(
                              alignment: pw.Alignment.center,
                              child: pw.Text(convertDoubleToWords(totalAmount)),
                            ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(children: [
                          pw.Container(width: 100, child: pw.Divider()),
                          pw.Text("Receiver/Customer",
                              style: const pw.TextStyle(fontSize: 10))
                        ]),
                        pw.Column(children: [
                          pw.Container(width: 100, child: pw.Divider()),
                          pw.Text("Sales Person",
                              style: const pw.TextStyle(fontSize: 10))
                        ]),
                        pw.Column(children: [
                          pw.Container(width: 100, child: pw.Divider()),
                          pw.Text("Manager",
                              style: const pw.TextStyle(fontSize: 10))
                        ]),
                      ],
                    ),
                    pw.Container(
                        height: 20,
                        width: double.infinity,
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200))
                  ],
                ),
              ])),
    );

    // Save PDF to bytes
    Uint8List bytes = await pdf.save();

    // Get temporary directory
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice.pdf");

    // Write bytes to the file
    await file.writeAsBytes(bytes);

    // Share the PDF file
    await Share.shareXFiles([XFile(file.path)],
        text: 'Here is your invoice PDF');

    // Show the PDF preview
    // await Printing.layoutPdf(

    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
  }

  ///=======>printing layout

  Future<void> _viewPDFGenPrinting() async {
    ///discount text , left right
    pw.Widget customDiscount(String text, String text2) {
      return pw.Container(
        width: 150,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(text,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
            pw.Text(text2,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
          ],
        ),
      );
    }

    pw.Widget buildDottedLine(
        {double width = 150, double dotSize = 1, int dotCount = 50}) {
      return pw.Container(
        width: width,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(dotCount, (_) {
            return pw.Container(
              width: dotSize,
              height: 1,
              color: PdfColors.grey,
            );
          }),
        ),
      );
    }

    // Calculate total quantity
    final totalQuantity = widget.items.fold<int>(
      0,
      (previousValue, element) => previousValue + (element.quantity ?? 0),
    );

// Calculate total amount
    final totalAmount = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ?? 0),
    );

    //convert to number to word
    String convertDoubleToWords(double value) {
      int wholePart = value.floor();
      int decimalPart = ((value - wholePart) * 100).round();

      String words = "${NumberToWordsEnglish.convert(wholePart)} taka";
      if (decimalPart > 0) {
        words += " and ${NumberToWordsEnglish.convert(decimalPart)} paisa";
      }
      return words[0].toUpperCase() + words.substring(1);
    }

    final String taxPercentOnly =
        widget.taxIdPercent.split('_').last.split('.').first;

// Format
    final formattedTotalAmount = NumberFormat("#,##0.00").format(totalAmount);

    final pdf = pw.Document();

    final pw.TextStyle headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );

    const pw.TextStyle cellStyle = pw.TextStyle(
      fontSize: 8,
    );

    bool showCompanyPhoneNumber = false;
    bool showMRP = false;
    bool showQRCode = false;
    bool showbodyWaterMarkLogo = false;

    Future<void> _loadCheckboxState() async {
      final prefs = await SharedPreferences.getInstance();
      bool? isChecked = prefs.getBool('checkbox_Company Phone Number');
      final mrpChecked = prefs.getBool('checkbox_MRP');
      final qrCodeChecked = prefs.getBool('checkbox_QR Code');
      final bodyWaterMarkLogo = prefs.getBool('checkbox_Body Watermark logo');

      setState(() {
        showCompanyPhoneNumber = isChecked ?? false;
        showMRP = mrpChecked ?? false;
        showQRCode = qrCodeChecked ?? false;
        showbodyWaterMarkLogo = bodyWaterMarkLogo ?? false;
      });
    }

    final logoBytes = await loadLogoImage();
    final logoImage = pw.MemoryImage(logoBytes);

    final columnAlignments = {
      0: pw.Alignment.center, // SL
      1: pw.Alignment.bottomLeft, // Product
      2: pw.Alignment.center, // Code
      3: pw.Alignment.center, // MRP
      4: pw.Alignment.center, // Qty
      5: pw.Alignment.center, // Unit
      6: pw.Alignment.center, // Price
      7: pw.Alignment.center, // discount
      8: pw.Alignment.center, // vat
      9: pw.Alignment.center, // Amount
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 1),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  //left
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Dream Tech International",
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text("84/8 Naya Paltan, Dhaka",
                            style: const pw.TextStyle(fontSize: 9)),
                        if (showCompanyPhoneNumber)
                          pw.Text("phone: 01759546853")
                      ]),

                  //right image
                  pw.SizedBox(
                    width: 40,
                    height: 40,
                    child: pw.Image(logoImage),
                  ),
                ]),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Invoice",
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill to:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.customerName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                    ],
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Bill No: inv542",
                            style: const pw.TextStyle(fontSize: 9)),
                        // pw.Text("Date: 12/10/2023",
                        //     style: const pw.TextStyle(fontSize: 9)),
                        pw.Text(
                          "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                          style: const pw.TextStyle(
                              color: PdfColors.black, fontSize: 9),
                        ),
                        pw.Text(
                            "Bill Person:  ${widget.billPersion != null && widget.billPersion!.trim().isNotEmpty ? widget.billPersion : "No Bill Person"}",
                            style: const pw.TextStyle(fontSize: 9))
                      ]),
                ]),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Paid",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green, // ✅ Set text color here
                ),
              ),
            ),

            pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(
                  color: PdfColor.fromHex('#f5f5f5'),
                  width: 0.5,
                ),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // SL
                1: const pw.FlexColumnWidth(4), // Product
                2: const pw.FlexColumnWidth(2), // Code
                if (showMRP) 3: const pw.FlexColumnWidth(2), // MRP
                (showMRP ? 4 : 3): const pw.FlexColumnWidth(2), // Qty
                (showMRP ? 5 : 4): const pw.FlexColumnWidth(2), // Unit
                (showMRP ? 6 : 5): const pw.FlexColumnWidth(2), // Price
                (showMRP ? 7 : 6): const pw.FlexColumnWidth(2), // Discount
                (showMRP ? 8 : 7): const pw.FlexColumnWidth(2), // VAT
                (showMRP ? 9 : 8): const pw.FlexColumnWidth(2), // Amount
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E0E0E0'),
                  ),
                  children: [
                    pw.Text("S.L", style: headerStyle),
                    pw.Text("Product", style: headerStyle),
                    pw.Text("Code", style: headerStyle),
                    if (showMRP) pw.Text("MRP", style: headerStyle),
                    pw.Text("Qty", style: headerStyle),
                    pw.Text("Unit", style: headerStyle),
                    pw.Text("Price", style: headerStyle),
                    pw.Text("Discount", style: headerStyle),
                    pw.Text("Vat/Tax", style: headerStyle),
                    pw.Text("Amount", style: headerStyle),
                  ]
                      .map((cell) => pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: cell,
                            ),
                          ))
                      .toList(),
                ),

                // Data Rows
                for (int i = 0; i < widget.items.length; i++)
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 0.3),
                      ),
                    ),
                    children: [
                      pw.Text('${i + 1}', style: cellStyle),
                      pw.Text(widget.items[i].itemName ?? '', style: cellStyle),
                      pw.Text('-', style: cellStyle),
                      if (showMRP) pw.Text('0', style: cellStyle),
                      pw.Text(widget.items[i].quantity.toString(),
                          style: cellStyle),
                      pw.Text(widget.items[i].unit ?? '', style: cellStyle),
                      pw.Text(
                        ((widget.items[i].amount /
                                (widget.items[i].quantity > 0
                                    ? widget.items[i].quantity
                                    : 1)))
                            .toStringAsFixed(2),
                        style: cellStyle,
                      ),
                      pw.Text(
                        '${widget.items[i].itemDiscountPercentace?.toStringAsFixed(0) ?? '0'}% '
                        '${widget.items[i].itemDiscountAmount?.toStringAsFixed(2) ?? '0.00'}',
                        style: cellStyle,
                      ),
                      pw.Text(
                        '${widget.items[i].itemvatTaxPercentace?.toStringAsFixed(0) ?? '0'}% '
                        '${widget.items[i].itemVatTaxAmount?.toStringAsFixed(2) ?? '0.00'}',
                        style: cellStyle,
                      ),
                      pw.Text(
                        widget.items[i].amount.toStringAsFixed(2),
                        style: cellStyle,
                      ),
                    ]
                        .map((cell) => pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: cell,
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),

          
            pw.SizedBox(height: 10),

            ///toatl section.
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Total: $totalQuantity",
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(
                  width: 20,
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(formattedTotalAmount,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                //left
                pw.SizedBox(
                  width: 150,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 4.0),
                    child: pw.Text(
                      "The Right Place for Online Trading on Financial Markets.",
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(width: 10),

                if (showQRCode)
                  pw.SizedBox(
                      width: 70,
                      height: 70,
                      child: pw.BarcodeWidget(
                          data: 'Invoice#Inv542',
                          barcode: pw.Barcode.qrCode(),
                          width: 50,
                          height: 50)),

               

                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    //discount
                    buildDottedLine(),
                    customDiscount("Discount ${widget.discountPercent}%",
                        "${widget.discountAmount}"),
                    buildDottedLine(),
                    customDiscount(
                        "Vat/Tax $taxPercentOnly%", "${widget.taxAmount}"),
                    buildDottedLine(),
                    customDiscount("Total Amount", formattedTotalAmount),
                    buildDottedLine(),
                    customDiscount("Due", "0"),
                    buildDottedLine(),
                    customDiscount("Paid", "0"),
                    buildDottedLine(),
                  ],
                ),
              ],
            ),

            pw.SizedBox(
              height: 4,
            ),

            ///inword
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(convertDoubleToWords(totalAmount)),

                  // customDiscount(
                  //     "In Words:", " One thousand and five hundred"),
                ),
                pw.SizedBox(
                  width: 20,
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Receiver/Customer",
                      style: const pw.TextStyle(fontSize: 10))
                ]),
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Sales Person",
                      style: const pw.TextStyle(fontSize: 10))
                ]),
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Manager", style: const pw.TextStyle(fontSize: 10))
                ]),
              ],
            )
          ],
        ),
      ),
    );

    // Save PDF to bytes
    Uint8List bytes = await pdf.save();

    // Get temporary directory
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice.pdf");

    // Write bytes to the file
    await file.writeAsBytes(bytes);

    // Share the PDF file
    //await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice PDF');

    // Show the PDF preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<File> _viewPDFDownload() async {
    ///discount text , left right
    pw.Widget customDiscount(String text, String text2) {
      return pw.Container(
        width: 150,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(text,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
            pw.Text(text2,
                style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
          ],
        ),
      );
    }

    pw.Widget buildDottedLine(
        {double width = 150, double dotSize = 1, int dotCount = 50}) {
      return pw.Container(
        width: width,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(dotCount, (_) {
            return pw.Container(
              width: dotSize,
              height: 1,
              color: PdfColors.grey,
            );
          }),
        ),
      );
    }

    // Calculate total quantity
    final totalQuantity = widget.items.fold<int>(
      0,
      (previousValue, element) => previousValue + (element.quantity ?? 0),
    );

    // Calculate total amount
    final totalAmount = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ?? 0),
    );

    // Format
    final formattedTotalAmount = NumberFormat("#,##0.00").format(totalAmount);

    //convert to number to word
    String convertDoubleToWords(double value) {
      int wholePart = value.floor();
      int decimalPart = ((value - wholePart) * 100).round();

      String words = "${NumberToWordsEnglish.convert(wholePart)} taka";
      if (decimalPart > 0) {
        words += " and ${NumberToWordsEnglish.convert(decimalPart)} paisa";
      }
      return words[0].toUpperCase() + words.substring(1);
    }

    final String taxPercentOnly =
        widget.taxIdPercent.split('_').last.split('.').first;

    final pdf = pw.Document();

    final logoBytes = await loadLogoImage();
    final logoImage = pw.MemoryImage(logoBytes);

    final columnAlignments = {
      0: pw.Alignment.center, // SL
      1: pw.Alignment.bottomLeft, // Product
      2: pw.Alignment.center, // Code
      3: pw.Alignment.center, // MRP
      4: pw.Alignment.center, // Qty
      5: pw.Alignment.center, // Unit
      6: pw.Alignment.center, // Price
      7: pw.Alignment.center, // Amount
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 1),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  //left
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Dream Tech International",
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text("84/8 Naya Paltan, Dhaka",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("0198994406",
                            style: const pw.TextStyle(fontSize: 9)),
                      ]),

                  //right image
                  pw.SizedBox(
                    width: 40,
                    height: 40,
                    child: pw.Image(logoImage),
                  ),
                ]),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Invoice",
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill to:',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      pw.Text(widget.customerName,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold))
                    ],
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Bill No: inv542",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text(
                          "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                          style: const pw.TextStyle(
                              color: PdfColors.black, fontSize: 9),
                        ),
                        pw.Text(
                            "Bill Person:  ${widget.billPersion != null && widget.billPersion!.trim().isNotEmpty ? widget.billPersion : "No Bill Person"}",
                            style: const pw.TextStyle(fontSize: 9))
                      ]),
                ]),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Paid",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green, // ✅ Set text color here
                ),
              ),
            ),
            pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(
                  color: PdfColor.fromHex('#f5f5f5'),
                  width: 0.5,
                ),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // SL
                1: const pw.FlexColumnWidth(4), // Product
                2: const pw.FlexColumnWidth(2), // Code
                3: const pw.FlexColumnWidth(2), // MRP
                4: const pw.FlexColumnWidth(2), // Qty
                5: const pw.FlexColumnWidth(2), // Unit
                6: const pw.FlexColumnWidth(2), // Price
                7: const pw.FlexColumnWidth(2), // Amount
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E0E0E0'),
                  ),
                  children: List.generate(8, (j) {
                    final headers = [
                      "S.L",
                      "Product",
                      "Code",
                      "MRP",
                      "Qty",
                      "Unit",
                      "Price",
                      "Amount"
                    ];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Align(
                        alignment:
                            columnAlignments[j] ?? pw.Alignment.centerLeft,
                        child: pw.Text(
                          headers[j],
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Data Rows
                for (int i = 0; i < widget.items.length; i++)
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 0.3),
                      ),
                    ),
                    children: List.generate(8, (j) {
                      final item = widget.items[i];
                      final rowData = [
                        '${i + 1}', // SL
                        item.itemName ?? '',
                        '-' ?? '0', // Replace with actual code if needed
                        '0' ?? '0', // Replace with actual MRP if needed
                        item.quantity.toString(),
                        item.unit ?? '',
                        ((item.amount /
                                (item.quantity > 0 ? item.quantity : 1)))
                            .toStringAsFixed(2),
                        '${item.itemDiscountPercentace?.toStringAsFixed(0) ?? '0'}% ${item.itemDiscountAmount?.toStringAsFixed(2) ?? '0.00'}',
                        '${item.itemvatTaxPercentace?.toStringAsFixed(0) ?? '0'}% ${item.itemVatTaxAmount?.toStringAsFixed(2) ?? '0.00'}',

                        item.amount.toStringAsFixed(2),
                      ];

                      return pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Align(
                          alignment:
                              columnAlignments[j] ?? pw.Alignment.centerLeft,
                          child: pw.Text(
                            rowData[j],
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Total: $totalQuantity",
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(
                  width: 20,
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(formattedTotalAmount,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                //left
                pw.SizedBox(
                  width: 150,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 4.0),
                    child: pw.Text(
                      "The Right Place for Online Trading on Financial Markets.",
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(width: 10),

                pw.SizedBox(
                  width: 70,
                  height: 70,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'Invoice#Inv542',
                    width: 50,
                    height: 50,
                  ),
                ),

                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    //discount
                    buildDottedLine(),
                    customDiscount("Discount ${widget.discountPercent}%",
                        "${widget.discountAmount}"),
                    buildDottedLine(),
                    customDiscount(
                        "Vat/Tax $taxPercentOnly%", "${widget.taxAmount}"),
                    buildDottedLine(),
                    customDiscount("Total Amount", formattedTotalAmount),
                    buildDottedLine(),
                    customDiscount("Due", "0"),
                    buildDottedLine(),
                    customDiscount("Paid", "0"),
                    buildDottedLine(),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.only(right: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(convertDoubleToWords(totalAmount)),

                    // customDiscount(
                    //     "In Words:", " One thousand and five hundred"),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Receiver/Customer",
                      style: const pw.TextStyle(fontSize: 10))
                ]),
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Sales Person",
                      style: const pw.TextStyle(fontSize: 10))
                ]),
                pw.Column(children: [
                  pw.Container(width: 100, child: pw.Divider()),
                  pw.Text("Manager", style: const pw.TextStyle(fontSize: 10))
                ]),
              ],
            ),
            pw.Container(
                height: 20,
                width: double.infinity,
                decoration: const pw.BoxDecoration(color: PdfColors.grey200))
          ],
        ),
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

  bool showCompanyPhoneNumber = false;
  bool showMRP = false;
  bool showQRCode = false;
  bool showbodyWaterMarkLogo = false;
  bool showItemDiscountAndPercentance = false;
  bool showItemVatTaxAmountAndPercentance = false;
  bool showItemCode = false;
  bool showSlNo = false;
  bool showBillDiscountAmountAndPercentance = false;
  bool showBillVatTaxAmountAndPercentance = false;
  bool showAmountinWord = false;
  bool showNarration = false;

  @override
  void initState() {
    super.initState();
    _loadCheckboxState();
  }

  Future<void> _loadCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isChecked = prefs.getBool('checkbox_Company Phone Number');
    final mrpChecked = prefs.getBool('checkbox_MRP');
    final qrCodeChecked = prefs.getBool('checkbox_QR Code');
    final bodyWaterMarkLogo = prefs.getBool('checkbox_Body Watermark logo');
    final itemDiscountAndPercentance =
        prefs.getBool('checkbox_Item Discount Amount & Percentance');
    final itemVatTaxAmountAndPercentance =
        prefs.getBool('checkbox_ItemVatTaxAmountAndPercentance');
    final itemCode = prefs.getBool('checkbox_Item Code');
    final siNo = prefs.getBool('checkbox_S.l No');
    final billDiscountAmountAndPercentance =
        prefs.getBool('checkbox_Bill Discount Amount & Percentance');
    final billVatTaxAmountAndPercentance =
        prefs.getBool('checkbox_Bill Vat/Tax Amount & Percentance');
    final amountinWord = prefs.getBool('checkbox_Amount in Word');
    final narrationNote = prefs.getBool('checkbox_Narration');

    setState(() {
      showCompanyPhoneNumber = isChecked ?? false;
      showMRP = mrpChecked ?? false;
      showQRCode = qrCodeChecked ?? false;
      showbodyWaterMarkLogo = bodyWaterMarkLogo ?? false;
      showItemDiscountAndPercentance = itemDiscountAndPercentance ?? false;
      showItemVatTaxAmountAndPercentance =
          itemVatTaxAmountAndPercentance ?? false;
      showItemCode = itemCode ?? false;
      showSlNo = siNo ?? false;
      showBillDiscountAmountAndPercentance =
          billDiscountAmountAndPercentance ?? false;
      showBillVatTaxAmountAndPercentance =
          billVatTaxAmountAndPercentance ?? false;
      showAmountinWord = amountinWord ?? false;
      showNarration = narrationNote ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=====> item discount ${widget.items.first.itemDiscountAmount}');
    debugPrint('=====> item vat ${widget.items.first.itemVatTaxAmount}');
    debugPrint(
        '=====> item dis per ${widget.items.first.itemDiscountPercentace}');
    debugPrint(
        '=====> item vat per ${widget.items.first.itemvatTaxPercentace}');

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    TextStyle tableHeaderStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
    const TextStyle tableCellStyle = TextStyle(
      fontSize: 10,
      color: Colors.black,
    );
    // 1. Calculate total
    final totalAmount = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.amount ?? 0),
    );

// 2. Format
    final formattedTotalAmount = NumberFormat("#,##0.00").format(totalAmount);

    ///amount
    String convertDoubleToWords(double value) {
      int wholePart = value.floor();
      int decimalPart = ((value - wholePart) * 100).round();

      String words = "${NumberToWordsEnglish.convert(wholePart)} taka";
      if (decimalPart > 0) {
        words += " and ${NumberToWordsEnglish.convert(decimalPart)} paisa";
      }

      // Capitalize first letter
      return words[0].toUpperCase() + words.substring(1);
    }

    final String taxPercentOnly =
        widget.taxIdPercent.split('_').last.split('.').first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "pdf view",
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>const BillInvoicePrint()));
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BillInvoicePrint()),
                );
                await _loadCheckboxState();
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Stack(
        children: [
          if (showbodyWaterMarkLogo)
            Opacity(
              opacity: 0.09, // adjust this value as needed for transparency
              child: Center(
                child: Image.asset(
                  'assets/image/cbook_logo.png', //assets\image\cbook_logo.png
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Dream Tech International",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black)),
                                      const Text("84/8 Naya Paltan, Dhaka",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),

                                      // ✅ Conditionally show Company Phone Number
                                      if (showCompanyPhoneNumber)
                                        const Text(
                                          "0198994406",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11),
                                        ),
                                      // Text("0198994406",
                                      //     style: TextStyle(
                                      //         color: Colors.black, fontSize: 11)),
                                    ],
                                  ),
                                  // Wrapping QrImage inside a SizedBox
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          'assets/image/cbook_logo.png')),
                                ],
                              ),
                            ),
                            const SizedBox(height: 1),

                            //invoice
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text("Invoice",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(height: 1),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bill To:\n${widget.customerName}",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Bill No: Inv542",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10)),
                                      Text(
                                        "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 10),
                                      ),

                                      //  "Bill Person: ${widget.billPersion != null && widget.billPersion!.trim().isNotEmpty ? widget.billPersion : "No Bill Person"}",
                                      Text(
                                          "Bill Person: ${widget.billPersion != null && widget.billPersion!.trim().isNotEmpty ? widget.billPersion : "N/A"}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 1),

                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text("Paid",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                            ),

                            const SizedBox(height: 6),

                            ///table list.
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Table(
                                  border: TableBorder.all(
                                      color: Colors.transparent), //black12

                                  defaultColumnWidth:
                                      const IntrinsicColumnWidth(),
                                  children: [
                                    // Header Row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(
                                        0xfff2f2f2,
                                      )),
                                      children: [
                                        if (showSlNo)
                                          tableCell(
                                            "SL",
                                            tableHeaderStyle,
                                          ),
                                        tableCell(
                                            "Product name", tableHeaderStyle),
                                        if (showItemCode)
                                          tableCell("Code", tableHeaderStyle),
                                        if (showMRP)
                                          tableCell("MRP", tableHeaderStyle),
                                        //tableCell("MRP", tableHeaderStyle),
                                        tableCell("Qty", tableHeaderStyle),
                                        tableCell("Unit", tableHeaderStyle),
                                        tableCell("Price", tableHeaderStyle),
                                        if (showItemDiscountAndPercentance)
                                          tableCell(
                                              "Discount", tableHeaderStyle),
                                        if (showItemVatTaxAmountAndPercentance)
                                          tableCell(
                                              "Vat/Tax", tableHeaderStyle),
                                        tableCell("Amount", tableHeaderStyle),
                                      ],
                                    ),

                                    ...List.generate(widget.items.length,
                                        (index) {
                                      final item = widget.items[index];
                                      return TableRow(
                                        children: [
                                          if (showSlNo)
                                            tableCell(
                                                "${index + 1}", tableCellStyle),
                                          tableCell(
                                              item.itemName, tableCellStyle),
                                          if (showItemCode)
                                            tableCell("-", tableCellStyle),
                                          if (showMRP)
                                            tableCell("0", tableCellStyle),
                                          tableCell(item.quantity.toString(),
                                              tableCellStyle),
                                          tableCell(item.unit, tableCellStyle),
                                          tableCell(
                                            (item.amount /
                                                    (item.quantity > 0
                                                        ? item.quantity
                                                        : 1))
                                                .toStringAsFixed(2),
                                            tableCellStyle,
                                          ),
                                          if (showItemDiscountAndPercentance)
                                            tableCell(
                                              '${item.itemDiscountPercentace}% ${item.itemDiscountAmount}',
                                              tableCellStyle,
                                            ),
                                          if (showItemVatTaxAmountAndPercentance)
                                            tableCell(
                                              '${item.itemvatTaxPercentace}% ${item.itemVatTaxAmount}',
                                              tableCellStyle,
                                            ),
                                          tableCell(formattedTotalAmount,
                                              tableCellStyle),
                                        ],
                                      );
                                    }),

                                    // Data Row 1
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Spacer(),

                            // Bottom Info (with all text color black)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showNarration)
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        "The Right Place for Online Trading on Financial Markets.",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                if (showQRCode)
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: QrImageView(
                                      data: "Invoice#Inv542",
                                      version: QrVersions.auto,
                                      size: 60.0,
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (showBillDiscountAmountAndPercentance)
                                      const SizedBox(
                                        width: 150,
                                        child: DottedLine(
                                          dashColor: Colors.black12,
                                          lineThickness: 1.0,
                                          dashLength: 3.0,
                                          dashGapLength: 1.0,
                                        ),
                                      ),
                                    //"${(widget.discountAmount == null || widget.discountAmount.trim().isEmpty || widget.discountAmount.toLowerCase() == 'n/a') ? '0.00' : widget.discountAmount}"
                                    //${widget.discountAmount}

                                    if (showBillDiscountAmountAndPercentance)
                                      customDiscount(
                                          "Discount ${widget.discountPercent}%",
                                          "${(widget.discountAmount == null || widget.discountAmount.trim().isEmpty || widget.discountAmount.toLowerCase() == 'n/a') ? '0.00' : widget.discountAmount}"),

                                    if (showBillVatTaxAmountAndPercentance)
                                      const SizedBox(
                                        width: 150,
                                        child: DottedLine(
                                          dashColor: Colors.black12,
                                          lineThickness: 1.0,
                                          dashLength: 3.0,
                                          dashGapLength: 1.0,
                                        ),
                                      ),

                                    if (showBillVatTaxAmountAndPercentance)
                                      customDiscount(
                                          "Vat/Tax ${taxPercentOnly}%",
                                          "${widget.taxAmount}"),
                                    const SizedBox(
                                      width: 150,
                                      child: DottedLine(
                                        dashColor: Colors.black12,
                                        lineThickness: 1.0,
                                        dashLength: 3.0,
                                        dashGapLength: 1.0,
                                      ),
                                    ),
                                    // customDiscount("Total Amount", "53,500"),
                                    customDiscount(
                                        "Total Amount", formattedTotalAmount),
                                    const SizedBox(
                                      width: 150,
                                      child: DottedLine(
                                        dashColor: Colors.black12,
                                        lineThickness: 1.0,
                                        dashLength: 3.0,
                                        dashGapLength: 1.0,
                                      ),
                                    ),
                                    customDiscount("Due", "0"),
                                    const SizedBox(
                                      width: 150,
                                      child: DottedLine(
                                        dashColor: Colors.black12,
                                        lineThickness: 1.0,
                                        dashLength: 3.0,
                                        dashGapLength: 1.0,
                                      ),
                                    ),
                                    customDiscount("Paid ", "0"),
                                    const SizedBox(
                                      width: 150,
                                      child: DottedLine(
                                        dashColor: Colors.black12,
                                        lineThickness: 1.0,
                                        dashLength: 3.0,
                                        dashGapLength: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            //Text("${convertDoubleToWords(totalAmount)}"),

                            if (showAmountinWord)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 220,
                                    child: Text(
                                      "In Word: ${convertDoubleToWords(totalAmount)}",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 30),

                            // Footer Signatures
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        child: Divider(),
                                      ),
                                      Text("Receiver/Customer",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        child: Divider(),
                                      ),
                                      Text("Sales Person",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        child: Divider(),
                                      ),
                                      Text("Manager",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),

                                //pdf share =====>
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _viewPDF();
                                  },
                                  icon: const Icon(Icons.share, size: 16),
                                  label: const Text(
                                    "Share PDF",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Rounded corners
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 3,
                                ),

                                //printing pdf
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _viewPDFGenPrinting();
                                    debugPrint('vieww pdf called');
                                  }, //_viewPDF
                                  icon: const Icon(Icons.picture_as_pdf,
                                      size: 18),
                                  label: const Text(
                                    "View PDF",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Rounded corners
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),

                                //download
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _viewPDFDownload();
                                  }, //
                                  icon: const Icon(
                                    Icons.download,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Download PDF",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Rounded corners
                                    ),
                                  ),
                                ),

                                //settings
                                const SizedBox(
                                  width: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  TableRow tableRow({
    required String sl,
    required String productName,
    required String code,
    required String mrp,
    required String qty,
    required String unit,
    required String price,
    required String discount,
    required String vatTax,
    required String amount,
  }) {
    return TableRow(
      children: [
        rowCell(sl),
        rowCell(productName),
        rowCell(code),
        rowCell(mrp),
        rowCell(qty),
        rowCell(unit),
        rowCell(price),
        rowCell(discount),
        rowCell(vatTax),
        rowCell(amount),
      ],
    );
  }

  Widget rowCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 7, color: Colors.black),
      ),
    );
  }

  ///custome widget

  Widget customDiscount(String text, String text2) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: SizedBox(
        width: 150, // adjust as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text,
                style: const TextStyle(color: Colors.black, fontSize: 10)),
            Text(text2,
                style: const TextStyle(color: Colors.black, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: style.copyWith(
          fontSize: 7,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  TableRow tableRowBottomAlign(List<String> cells) {
    return TableRow(
      children: List.generate(cells.length, (index) {
        final text = cells[index];
        final isRightAligned =
            [3, 4, 6, 7].contains(index); // MRP, Qty, Price, Amount
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Align(
            alignment:
                isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(fontSize: 8, color: Colors.black),
            ),
          ),
        );
      }),
    );
  }
}
