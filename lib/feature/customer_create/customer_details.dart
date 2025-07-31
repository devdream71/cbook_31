import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/customer_create/customer_update.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final int customerId;
  final List<Purchase> purchases;
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.purchases,
    required this.customer,
  });

  @override
  _SupplierDetailsScreenState createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<CustomerDetailsScreen> {
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? customerDetails;

  @override
  void initState() {
    super.initState();
    fetchSupplierDetails();
  }

  Future<void> fetchSupplierDetails() async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/customer/edit/${widget.customerId}');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          customerDetails = data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load customer details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  ///open sms
  Future<void> _openSms({required String phone, String? body}) async {
    final encodedBody = body != null ? Uri.encodeComponent(body) : '';
    final uriString = Platform.isAndroid
        ? 'sms:$phone?body=$encodedBody'
        : 'sms:$phone&body=$encodedBody';
    final uri = Uri.parse(uriString);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  ////open whats app
  Future<void> openWhatsApp({
    required BuildContext context,
    required String phone, // include country code, e.g. "919876543210"
    String message = '',
  }) async {
    final encodedMsg = Uri.encodeComponent(message);
    final uri = Platform.isIOS
        ? Uri.parse("https://wa.me/$phone?text=$encodedMsg")
        : Uri.parse("whatsapp://send?phone=$phone&text=$encodedMsg");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp is not installed')),
      );
    }
  }

  Widget buildDetailRow(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        title: const Text(
          "Party Details",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///left text , name, phone, gmail, address, levell
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //name
                                Text(
                                  customerDetails?["name"] ?? "Customer Name",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                //proprietor_name
                                Text(
                                  customerDetails?["proprietor_name"] ??
                                      "proprietor name",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black),
                                ),

                                //phone
                                Text(
                                  customerDetails?["phone"] ?? "phone",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black),
                                ),

                                //gmail
                                Text(
                                  customerDetails?["email"] ?? "email",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black),
                                ),

                                //address
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    customerDetails?["address"] ?? "address",
                                    maxLines: 1, // Limit to one line
                                    overflow: TextOverflow
                                        .ellipsis, // Show ... if overflow
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ///edit, value, icon,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //edit data
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: IconButton(
                                    iconSize: 20, // match icon size
                                    padding: EdgeInsets
                                        .zero, // remove inner padding :contentReference[oaicite:1]{index=1}
                                    constraints:
                                        const BoxConstraints(), // override default 48×48 minimum :contentReference[oaicite:2]{index=2}
                                    visualDensity: VisualDensity
                                        .compact, // further tighten around the icon :contentReference[oaicite:3]{index=3}
                                    onPressed: () {
                                      final c = widget.customer;
                                      final customerData = CustomerData(
                                        id: c.id,
                                        userId: c.userId,
                                        name: c.name,
                                        proprietorName: c.proprietorName,
                                        email:
                                            "", // or pass real email if available
                                        phone: c.phone ?? "",
                                        address: c.address ?? "",
                                        openingBalance: c.due,
                                        status: 1,
                                        createdAt: "",
                                        updatedAt: "",
                                        type: c.type,
                                        level: null,
                                        levelType: null,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustomerUpdate(
                                              customer: customerData),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit_document,
                                        size: 20),
                                  ),
                                ),
                                const Text(
                                  "Receivable",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  "${customerDetails?["opening_balance"] ?? '0'}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // handle SMS tap

                                        _openSms(
                                            phone: '01759546853',
                                            body: 'Hello from  cBook!');
                                      },
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          'assets/image/communication.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => openWhatsApp(
                                        context: context,
                                        phone: '01759546853',
                                        message:
                                            'Hello from cbook!', // optional
                                      ),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          'assets/image/whatsapp_color.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // handle Report tap
                                      },
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          'assets/image/pdf.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          height: 10,
                          thickness: 1,
                          color: Color(0xff278d46),
                        ),
                      ],
                    ),
                  ),

                  ///Customer Purchase list
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.purchases.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Center(
                                    child: Text(
                                      "No Sales & Received Available",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: widget.purchases.length,
                                  itemBuilder: (context, index) {
                                    final purchase = widget.purchases[index];

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Text(purchase.id.toString()),
                                        ),
                                        title: Text(
                                          "Bill: ${purchase.billNumber}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Date: ${purchase.purchaseDate}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13)),
                                            Text(
                                                "Total: ৳ ${purchase.grossTotal}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        // trailing: const Icon(Icons.receipt_long,
                                        //     color: Colors.blue),
                                      ),
                                    );
                                  },
                                ),
                        ]),
                  ),
                ]),
    );
  }
}
