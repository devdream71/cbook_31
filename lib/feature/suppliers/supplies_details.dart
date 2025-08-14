import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/suppliers/model/suppliers_list.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SupplierDetailsScreen extends StatefulWidget {
  final int supplierId;
  final List<Purchase> purchases;

  const SupplierDetailsScreen(
      {super.key, required this.supplierId, required this.purchases});

  @override
  SupplierDetailsScreenState createState() => SupplierDetailsScreenState();
}

class SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? supplierDetails;

  @override
  void initState() {
    super.initState();
    fetchSupplierDetails();
  }

  Future<void> fetchSupplierDetails() async {
    final url = Uri.parse(
        '${AppUrl.baseurl}supplier/edit/${widget.supplierId}');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          supplierDetails = data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load supplier details";
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
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Customer/ Supplier Details",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 4),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  supplierDetails?["name"] ?? "Customer Name",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.red[700],
                                    ),
                                    Text(
                                      "${supplierDetails?["opening_balance"] ?? '0'}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Text(
                              "${supplierDetails?["proprietor_name"]}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${supplierDetails?["phone"]}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${supplierDetails?["email"]}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${supplierDetails?["address"]}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Text(
                                      "Wholesaler",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),

                                ///icon
                                const Row(
                                  children: [
                                    Icon(Icons.info),
                                    Icon(Icons.help),
                                    Icon(Icons.info),
                                    Icon(Icons.help),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              height: 30,
                              thickness: 4,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Purchase",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                            widget.purchases.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Center(
                                      child: Text(
                                        "No Purchase Available",
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
                                        ),
                                      );
                                    },
                                  ),
                          ]),
                    ),
                  ],
                ),
    );
  }
}
