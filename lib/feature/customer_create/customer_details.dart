import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
import 'package:cbook_dt/feature/customer_create/customer_update.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create_model.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

    Future.microtask(() =>
        Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
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
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final c = widget.customer;

                final customerData = CustomerData(
                  id: c.id,
                  userId: c.userId,
                  name: c.name,
                  proprietorName: c.proprietorName,
                  email: customerDetails?["email"] ?? "",
                  phone: c.phone ?? "",
                  address: c.address ?? "",
                  openingBalance: c.due,
                  avatar: c.avatar,
                  logo: c.logo,
                  status: 1,
                  createdAt: "",
                  updatedAt: "",
                  type: c.type,
                  level: customerDetails?["level"],
                  levelType: customerDetails?["level_type"],
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
              : Column(
                  children: [
                    // Fixed header section
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer details section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // name
                                    Text(
                                      customerDetails?["name"] ?? "Customer Name",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    // proprietor_name
                                    Text(
                                      customerDetails?["proprietor_name"] ?? "proprietor name",
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                    ),
                                    // phone
                                    Text(
                                      customerDetails?["phone"] ?? "phone",
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                    ),
                                    // gmail
                                    Text(
                                      customerDetails?["email"] ?? "email",
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                    ),
                                    // address
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        customerDetails?["address"] ?? "address",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Avatar and receivable section
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Stack(
                                      children: [
                                        // Avatar image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.network(
                                            'https://commercebook.site/${widget.customer.avatar ?? ''}',
                                            fit: BoxFit.cover,
                                            height: 40,
                                            width: 40,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.person);
                                            },
                                          ),
                                        ),

                                        // Logo image overlay
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: Image.network(
                                              'https://commercebook.site/${widget.customer.logo ?? ''}',
                                              fit: BoxFit.cover,
                                              height: 20,
                                              width: 20,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const SizedBox.shrink();
                                                // const Icon(
                                                //   Icons.business,
                                                //   size: 20,
                                                // );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                    
                    // Scrollable list section - FIXED PART
                    Expanded(
                      child: widget.purchases.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "No Sales & Received Available",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(0),
                              itemCount: widget.purchases.length,
                              separatorBuilder: (context, index) => Container(
                                height: 1,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              itemBuilder: (context, index) {
                                final purchase = widget.purchases[index];

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Colors.white,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Left side content
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Date
                                            Text(
                                              "${purchase.purchaseDate}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 1),

                                            // Type
                                            Text(
                                              "${purchase.type}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 1),

                                            // Bill Number
                                            Text(
                                              "${purchase.billNumber}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        height: 35,
                                        width: 2,
                                        color: const Color(0xff278d46),
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                      ),

                                      const Spacer(),

                                      // Right side content
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Bill Amount",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 2),

                                          Consumer<CurrencyProvider>(
                                            builder: (context, currencyProvider, child) {
                                              final currency = currencyProvider
                                                  .currencyModel?.currency ?? '';

                                              return Text(
                                                "${purchase.grossTotal} $currency",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                              );
                                            }
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}



// import 'dart:convert';
// import 'dart:io';
// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
// import 'package:cbook_dt/feature/customer_create/customer_update.dart';
// import 'package:cbook_dt/feature/customer_create/model/customer_create_model.dart';
// import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CustomerDetailsScreen extends StatefulWidget {
//   final int customerId;
//   final List<Purchase> purchases;
//   final Customer customer;

//   const CustomerDetailsScreen({
//     super.key,
//     required this.customerId,
//     required this.purchases,
//     required this.customer,
//   });

//   @override
//   _SupplierDetailsScreenState createState() => _SupplierDetailsScreenState();
// }

// class _SupplierDetailsScreenState extends State<CustomerDetailsScreen> {
//   bool isLoading = true;
//   String errorMessage = "";
//   Map<String, dynamic>? customerDetails;

//   @override
//   void initState() {
//     super.initState();
//     fetchSupplierDetails();

//     Future.microtask(() =>
//         Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
//   }

//   Future<void> fetchSupplierDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     final url = Uri.parse(
//         'https://commercebook.site/api/v1/customer/edit/${widget.customerId}');

//     try {
//       final response = await http.get(url, headers: {
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       });
//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data["success"] == true) {
//         setState(() {
//           customerDetails = data["data"];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = "Failed to load customer details";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "Error: $e";
//         isLoading = false;
//       });
//     }
//   }

//   ///open sms
//   Future<void> _openSms({required String phone, String? body}) async {
//     final encodedBody = body != null ? Uri.encodeComponent(body) : '';
//     final uriString = Platform.isAndroid
//         ? 'sms:$phone?body=$encodedBody'
//         : 'sms:$phone&body=$encodedBody';
//     final uri = Uri.parse(uriString);

//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $uri';
//     }
//   }

//   ////open whats app
//   Future<void> openWhatsApp({
//     required BuildContext context,
//     required String phone, // include country code, e.g. "919876543210"
//     String message = '',
//   }) async {
//     final encodedMsg = Uri.encodeComponent(message);
//     final uri = Platform.isIOS
//         ? Uri.parse("https://wa.me/$phone?text=$encodedMsg")
//         : Uri.parse("whatsapp://send?phone=$phone&text=$encodedMsg");

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('WhatsApp is not installed')),
//       );
//     }
//   }

//   Widget buildDetailRow(String label, String? value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value ?? 'N/A',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                 color: Colors.black87,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       backgroundColor: AppColors.sfWhite,
//       appBar: AppBar(
//         title: const Text(
//           "Party Details",
//           style: TextStyle(color: Colors.yellow, fontSize: 16),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: colorScheme.primary,
//         centerTitle: true,
//         actions: [
//           //edit data
//           SizedBox(
//             width: 20,
//             height: 20,
//             child: IconButton(
//               iconSize: 20,  
//               padding: EdgeInsets
//                   .zero,  
//               constraints:
//                   const BoxConstraints(),  
//               visualDensity: VisualDensity
//                   .compact,  
//               onPressed: () {
//                 final c = widget.customer;

//                 final customerData = CustomerData(
//                   id: c.id,
//                   userId: c.userId,
//                   name: c.name,
//                   proprietorName:
//                       c.proprietorName, // This should work correctly
//                   email: customerDetails?["email"] ??
//                       "", // Use actual email from API data
//                   phone: c.phone ?? "",
//                   address: c.address ?? "",
//                   openingBalance: c.due,
//                   avatar: c.avatar,
//                   logo: c.logo, // Make sure your Customer model has logo field
//                   status: 1,
//                   createdAt: "",
//                   updatedAt: "",
//                   type: c.type,
//                   level:
//                       customerDetails?["level"], // Pass actual level from API
//                   levelType: customerDetails?[
//                       "level_type"], // Pass actual levelType from API
//                 );

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         CustomerUpdate(customer: customerData),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.edit_document, size: 20),
//             ),
//           )
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(
//                   child: Text(
//                     errorMessage,
//                     style: const TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                 )
//               : Column(children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 0, right: 0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ///left text , name, phone, gmail, address, levell
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   //name
//                                   Text(
//                                     customerDetails?["name"] ?? "Customer Name",
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   //proprietor_name
//                                   Text(
//                                     customerDetails?["proprietor_name"] ??
//                                         "proprietor name",
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black),
//                                   ),

//                                   //phone
//                                   Text(
//                                     customerDetails?["phone"] ?? "phone",
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black),
//                                   ),

//                                   //gmail
//                                   Text(
//                                     customerDetails?["email"] ?? "email",
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black),
//                                   ),

//                                   //address
//                                   SizedBox(
//                                     width: 250,
//                                     child: Text(
//                                       customerDetails?["address"] ?? "address",
//                                       maxLines: 1, // Limit to one line
//                                       overflow: TextOverflow
//                                           .ellipsis, // Show ... if overflow
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               ///edit, value, icon,

//                               Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       // Second image (avatar) - Full size, positioned at the back
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(50),
//                                         child: Image.network(
//                                           'https://commercebook.site/${widget.customer.avatar ?? ''}',
//                                           fit: BoxFit.cover,
//                                           height: 40,
//                                           width: 40,
//                                           errorBuilder:
//                                               (context, error, stackTrace) {
//                                             return const Icon(
//                                                 Icons.person); // fallback
//                                           },
//                                         ),
//                                       ),

//                                       // First image (logo) - Smaller, positioned in bottom-left
//                                       Positioned(
//                                         bottom: 0,
//                                         left: 0,
//                                         child: ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(50),
//                                           child: Image.network(
//                                             'https://commercebook.site/${widget.customer.logo ?? ''}',
//                                             fit: BoxFit.cover,
//                                             height:
//                                                 20, // Made even smaller for better overlay effect
//                                             width: 20,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) {
//                                               return const Icon(
//                                                 Icons.business,
//                                                 size: 20,
//                                               ); // Different fallback icon for logo
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 8,
//                                   ),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       const Text(
//                                         "Receivable",
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green,
//                                         ),
//                                       ),
//                                       Text(
//                                         "${widget.customer.due}",
//                                         style: const TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               )

//                               // Column(
//                               //   crossAxisAlignment: CrossAxisAlignment.end,
//                               //   children: [

//                               //   ],
//                               // ),
//                             ],
//                           ),
//                         ),
//                         const Divider(
//                           height: 10,
//                           thickness: 1,
//                           color: Color(0xff278d46),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 0.0, right: 0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         widget.purchases.isEmpty
//                             ? Padding(
//                                 padding: const EdgeInsets.only(top: 6.0),
//                                 child: Center(
//                                   child: Text(
//                                     "No Sales & Received Available",
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : ListView.separated(
//                                 // ✅ Changed to ListView.separated
//                                 shrinkWrap: true,
//                                 padding: const EdgeInsets.all(0),
//                                 itemCount: widget.purchases.length,
//                                 // ✅ Add separator builder
//                                 separatorBuilder: (context, index) => Container(
//                                   height: 1,
//                                   color: Colors.grey.shade300,
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 8),
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   final purchase = widget.purchases[index];
                            
//                                   return Container(
//                                     // ✅ Changed from Card to Container
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 8), // ✅ Reduced padding
//                                     color: Colors.white,
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment
//                                           .center, // ✅ Changed to center
//                                       children: [
//                                         // Left side content
//                                         SizedBox(
//                                           width: 100,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisSize: MainAxisSize
//                                                 .min, // ✅ Minimize height
//                                             children: [
//                                               // Date (title equivalent)
//                                               Text(
//                                                 "${purchase.purchaseDate}",
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize:
//                                                       12, // ✅ Reduced font size
//                                                   height:
//                                                       1.2, // ✅ Reduced line height
//                                                 ),
//                                               ),
//                                               const SizedBox(
//                                                   height:
//                                                       1), // ✅ Minimal spacing
                            
//                                               // Type (subtitle content)
//                                               Text(
//                                                 "${purchase.type}",
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize:
//                                                       12, // ✅ Reduced font size
//                                                   fontWeight: FontWeight.bold,
//                                                   height:
//                                                       1.2, // ✅ Reduced line height
//                                                 ),
//                                               ),
//                                               const SizedBox(
//                                                   height:
//                                                       1), // ✅ Minimal spacing
                            
//                                               // Bill Number
//                                               Text(
//                                                 "${purchase.billNumber}",
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize:
//                                                       12, // ✅ Reduced font size
//                                                   height:
//                                                       1.2, // ✅ Reduced line height
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
                            
//                                         Container(
//                                           height: 35, // ✅ Reduced height
//                                           width: 2,
//                                           color: const Color(0xff278d46),
//                                           margin: const EdgeInsets.symmetric(
//                                               horizontal: 6),
//                                         ),
                            
//                                         const Spacer(),
                            
//                                         // Right side content (trailing equivalent)
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           mainAxisSize: MainAxisSize
//                                               .min, // ✅ Minimize height
//                                           children: [
//                                             const Text(
//                                               "Bill Amount",
//                                               style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize:
//                                                     12, // ✅ Reduced font size
//                                                 height:
//                                                     1.2, // ✅ Reduced line height
//                                               ),
//                                             ),
//                                             const SizedBox(height: 2),
//                                             // Text(
//                                             //   "${purchase.grossTotal} TK",
//                                             //   style: const TextStyle(
//                                             //     color: Colors.black,
//                                             //     fontSize:
//                                             //         12, // ✅ Reduced font size
//                                             //     fontWeight: FontWeight.bold,
//                                             //     height:
//                                             //         1.2, // ✅ Reduced line height
//                                             //   ),
//                                             // ),
                            
//                                             Consumer<CurrencyProvider>(builder:
//                                                 (context, currencyProvider,
//                                                     child) {
//                                               // ✅ Added missing comma
//                                               final currency = currencyProvider
//                                                       .currencyModel
//                                                       ?.currency ??
//                                                   '';
                            
//                                               return Text(
//                                                 "${purchase.grossTotal} $currency", // ✅ Use currency instead of hardcoded "TK"
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   height: 1.2,
//                                                 ),
//                                               );
//                                             }),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//                 ]),
//     );
//   }
// }
