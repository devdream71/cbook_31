import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/customer_create/customer_update.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create_model.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
        'https://commercebook.site/api/v1/customer/edit/${widget.customerId}');

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
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
        actions: [
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
                // final customerData = CustomerData(
                //   id: c.id,
                //   userId: c.userId,
                //   name: c.name,
                //   proprietorName: c.proprietorName,
                //   email: "", // or pass real email if available
                //   phone: c.phone ?? "",
                //   address: c.address ?? "",
                //   openingBalance: c.due,
                //   avatar: c.avatar,
                //   logo: c.logo,
                //   status: 1,
                //   createdAt: "",
                //   updatedAt: "",
                //   type: c.type,
                //   level: null,
                //   levelType: null,
                // );

                 final customerData = CustomerData(
    id: c.id,
    userId: c.userId,
    name: c.name,
    proprietorName: c.proprietorName, // This should work correctly
    email: customerDetails?["email"] ?? "", // Use actual email from API data
    phone: c.phone ?? "",
    address: c.address ?? "",
    openingBalance: c.due,
    avatar: c.avatar,
    logo: c.logo, // Make sure your Customer model has logo field
    status: 1,
    createdAt: "",
    updatedAt: "",
    type: c.type,
    level: customerDetails?["level"], // Pass actual level from API
    levelType: customerDetails?["level_type"], // Pass actual levelType from API
  );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerUpdate(customer: customerData),
                  ),
                );
              },
              icon: const Icon(Icons.edit_document, size: 20),
            ),
          )
        ],
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
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///left text , name, phone, gmail, address, levell
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          'https://commercebook.site/${widget.customer.avatar ?? ''}',
                                          fit: BoxFit.cover,
                                          height: 40,
                                          width: 40,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.person); // fallback
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          'https://commercebook.site/${widget.customer.logo ?? ''}',
                                          fit: BoxFit.cover,
                                          height: 25,
                                          width: 25,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.person); // fallback
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "Receivable",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        "${widget.customer.due}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )

                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.end,
                              //   children: [

                              //   ],
                              // ),
                            ],
                          ),
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
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
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
                                  padding: const EdgeInsets.all(0),
                                  itemCount: widget.purchases.length,
                                  itemBuilder: (context, index) {
                                    final purchase = widget.purchases[index];

                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Left side content
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Date (title equivalent)
                                                  Text(
                                                    "${purchase.purchaseDate}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),

                                                  // Type (subtitle content)
                                                  Text(
                                                    "${purchase.type}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  // Bill Number
                                                  Text(
                                                    "${purchase.billNumber}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              height: 50,
                                              width: 2,
                                              color: Colors.green.shade200,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                            ),

                                            Spacer(),

                                            // Right side content (trailing equivalent)
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  "Bill Amount",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "${purchase.grossTotal} TK",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    // Card(
                                    //   shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(4)),
                                    //   margin: const EdgeInsets.symmetric(
                                    //       vertical: 2),
                                    //   child: ListTile(

                                    //       title: Text(
                                    //           "${purchase.purchaseDate}",
                                    //           style: const TextStyle(
                                    //               color: Colors.black,
                                    //               fontSize: 13)),
                                    //       subtitle: Column(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,
                                    //         children: [
                                    //           Text(
                                    //             "${purchase.type}",
                                    //             style: const TextStyle(
                                    //                 color: Colors.black,
                                    //                 fontSize: 13,
                                    //                 fontWeight:
                                    //                     FontWeight.bold),
                                    //           ),
                                    //           Text(
                                    //             "${purchase.billNumber}",
                                    //             style: const TextStyle(
                                    //                 color: Colors.black,
                                    //                 fontSize: 13),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //       trailing: Column(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.end,
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.end,
                                    //         children: [
                                    //           const Text("Bill Amount",
                                    //               style: const TextStyle(
                                    //                   color: Colors.black,
                                    //                   fontSize: 13)),
                                    //           Text("${purchase.grossTotal} TK",
                                    //               style: const TextStyle(
                                    //                   color: Colors.black,
                                    //                   fontSize: 13)),
                                    //         ],
                                    //       )),
                                    // );
                                  },
                                ),
                        ]),
                  ),
                ]),
    );
  }
}
