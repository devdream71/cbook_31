import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/banner_image.dart';
import 'package:cbook_dt/common/fi_chart_date_amount.dart';
import 'package:cbook_dt/common/round_fi_chart_document_view.dart';
import 'package:cbook_dt/common/feature_not_available.dart';
import 'package:cbook_dt/feature/Received/received_list.dart';
import 'package:cbook_dt/feature/account/ui/bank_ui.dart';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/cash_in_hand.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/dashboard_report/model/sales_report_model_home.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:cbook_dt/feature/home/presentation/layer/dashboard/dashboard_controller.dart';
import 'package:cbook_dt/feature/home/provider/profile_provider.dart';
import 'package:cbook_dt/feature/party/party_list.dart';
import 'package:cbook_dt/feature/payment_out/payment_out_list.dart';
import 'package:cbook_dt/feature/purchase/purchase_list_api.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_list.dart';
import 'package:cbook_dt/feature/sales/sales_list.dart';
import 'package:cbook_dt/feature/sales_bulk/sales_bulk.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_list.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => DashboardReportProvider()),
      ],
      child: const Layout(),
    );
  }
}

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => LayoutState();
}

class LayoutState extends State<Layout> {
  List<double> salesValues = [];
  int? userID;

  @override
  void initState() {
    super.initState();

    final provider =
        Provider.of<DashboardReportProvider>(context, listen: false);

    Future.microtask(() async {
      await provider.fetchCustomerTransaction();
      await provider.fetchSupplierTransaction();
      await provider.fetchCashInHandTransaction();
      await provider.fetchBankBalance();
      await provider.fetchVoucherSummary();
      await provider.fetchSalesLast30Days();
      _loadUserIdAndFetchProfile();
    });
  }

  Future<void> _loadUserIdAndFetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      setState(() {
        userID = userId;
      });

      // Call fetchProfile after userId is loaded
      Provider.of<ProfileProvider>(context, listen: false)
          .fetchProfile(userID!);
    } else {
      // Handle null userId
      debugPrint('User ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final controller = context.watch<DashboardController>();
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: AppColors.sfWhite,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FocusableActionDetector(
                  autofocus: true,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => _buildBottomSheetContent(context),
                      );
                    },
                    child: Container(
                      width: 50, // Make sure width and height are equal
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Row(
                            //   children: [
                            //     Image.asset(
                            //       "assets/image/cbook_logo.png",
                            //       height: 40,
                            //       width: 40,
                            //     ),
                            //     const SizedBox(width: 12),
                            //     const Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           "Commerce Book Ltd",
                            //           style: TextStyle(
                            //             fontFamily: 'Calibri',
                            //             color: Colors.white,
                            //             fontWeight: FontWeight.w700,
                            //             fontSize: 20,
                            //           ),
                            //         ),
                            //         Text(
                            //           "Admin",
                            //           style: TextStyle(
                            //               fontFamily: 'Calibri',
                            //               color: Colors.white,
                            //               fontWeight: FontWeight.w800,
                            //               fontSize: 12),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),

                            Consumer<ProfileProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (provider.profile != null) {
                                  final user = provider.profile!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        // CircleAvatar(
                                        //   radius: 15,
                                        //   backgroundColor: Colors.white,
                                        //   child: CircleAvatar(
                                        //     radius: 15,
                                        //     backgroundImage: user.avatar != null
                                        //         ? NetworkImage(user.avatar!)
                                        //         : const AssetImage(
                                        //                 'assets/image/cbook_logo.png') //assets\image\cbook_logo.png
                                        //             as ImageProvider,
                                        //   ),
                                        // ),

                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundImage: (user.avatar !=
                                                        null &&
                                                    user.avatar!.isNotEmpty)
                                                ? NetworkImage(
                                                    "https://commercebook.site/${user.avatar}")
                                                : const AssetImage(
                                                        'assets/image/cbook_logo.png')
                                                    as ImageProvider,
                                          ),
                                        ),

                                        const SizedBox(width: 4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.companyName,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      provider.errorMessage.isNotEmpty
                                          ? provider.errorMessage
                                          : "No profile data found",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                  );
                                }
                              },
                            ),

                            const Icon(
                              Icons.notification_add,
                              color: Colors.white,
                            ),
                            // You can add a button or search icon here
                          ],
                        ),
                      ),

                      //vPad16,
                    ],
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    hPad5,

                    ///customer.
                    Expanded(
                      child: Consumer<DashboardReportProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(child: SizedBox());
                          } else if (provider.error != null) {
                            return Text("Error: ${provider.error}");
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Party()));
                              },
                              child: _buildSummaryCard(
                                title: "Customer",
                                amount: '${provider.customerTransaction ?? 0}',

                                ///
                                //icon: Icons.person_rounded,
                                color: Colors.green.shade100,
                                iconColor: Colors.green.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 0,
                    ),

                    ///supplier
                    Expanded(
                      child: Consumer<DashboardReportProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(child: SizedBox());
                          } else if (provider.error != null) {
                            return Text("Error: ${provider.error}");
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Party()));
                              },
                              child: _buildSummaryCard(
                                title: "Supplier",
                                amount: '${provider.supplierTransaction ?? 0}',
                                //icon: Icons.handshake_rounded,
                                color: Colors.red.shade100,
                                iconColor: Colors.red.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 0,
                    ),

                    ///cash in hand
                    Expanded(
                      child: Consumer<DashboardReportProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(child: SizedBox());
                          } else if (provider.error != null) {
                            return Text("Error: ${provider.error}");
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CashInHand()));
                              },
                              child: _buildSummaryCard(
                                title: "Cash",
                                //amount: "${provider.cashInHand.toStringAsFixed(2) ?? 0}",

                                //icon: Icons.attach_money_rounded,
                                amount: double.tryParse(
                                            provider.cashInHand?.toString() ??
                                                '')
                                        ?.toStringAsFixed(2) ??
                                    '0.00',
                                color: Colors.blue.shade100,
                                iconColor: Colors.blue.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 0,
                    ),

                    ///bank
                    Expanded(
                      child: Consumer<DashboardReportProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(child: SizedBox());
                          } else if (provider.error != null) {
                            return Text("Error: ${provider.error}");
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Bank()));
                              },
                              child: _buildSummaryCard(
                                title: "Bank",
                                amount: '${provider.bankBalance ?? 0}',
                                //icon: Icons.account_balance_rounded,
                                color: Colors.orange.shade100,
                                iconColor: Colors.orange.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    hPad5,
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),

                Text(
                  "Transaction History - Last 30 days",
                  style: GoogleFonts.notoSansPhagsPa(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),

                ///Transaction History
                const CustomBarChart(),

                //const SalesLast30DaysChart(),

                Text(
                  "Transaction summary",
                  style: GoogleFonts.notoSansPhagsPa(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),

                ///Transaction summary
                Consumer<DashboardReportProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Column(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    } else if (provider.error != null) {
                      return Text('Error: ${provider.error}');
                    } else if (provider.voucherSummary == null) {
                      return const Text('No data available');
                    } else {
                      final summary = provider.voucherSummary!;

                      final values = [
                        summary.received.toDouble(),
                        summary.payment.toDouble(),
                        summary.income.toDouble(),
                        summary.expense.toDouble(),
                      ];

                      final labels = [
                        'Received',
                        'Payment',
                        'Income',
                        'Expense'
                      ];
                      final legendLabels = [
                        '৳ ${summary.received}',
                        '৳ ${summary.payment}',
                        '৳ ${summary.income}',
                        '৳ ${summary.expense}',
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //const SizedBox(height: 16),
                          DonutChartViewRound(
                            values: values,
                            labels: labels,
                            legendLabels: legendLabels,
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(
                  height: 6,
                ),

                const AutoScrollCarousel(),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}

////summary pay , expense
Widget _buildSummaryCard({
  required String title,
  required dynamic amount,
  //required IconData icon,
  required Color color,
  required Color iconColor,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    //width: 106,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '৳ $amount',
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
              ),
            ),
          ],
        ),
        //Icon(icon, size: 28, color: iconColor),
      ],
    ),
  );
}

///bottom sheet content.
Widget _buildBottomSheetContent(BuildContext context) {
  return SafeArea(
    child: SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for Sales Transaction
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context, MaterialPageRoute(builder: (_) => SalesScreen()));

                  _buildBottomSheetContent(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0), // Only vertical padding
                      child: Text(
                        "Sales Transaction",
                        style: GoogleFonts.notoSansPhagsPa(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),

              // Icons with text in a Wrap for Sales Transaction
              Wrap(
                spacing: 10,
                runSpacing: 20,
                children: [
                  //// Sales/Bill/\nInvoice
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SalesScreen()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(Icons.shopping_cart_checkout,
                          "Sales/Bill/\nInvoice", context)),

                  //// bulk sales
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ItemListPage()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.apps, "Bulk sales/\nInvoice", context)),

                  //// Estimate/\nQuotation
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.view_timeline, "Estimate/\nQuotation", context),
                  ),

                  //// Challan
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child:
                          _buildIconWithLabel(Icons.tab, "Challan", context)),

                  //// Receipt In
                  InkWell(
                      onTap: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReceivedList()));
                      },
                      child: _buildIconWithLabel(
                          Icons.receipt, "Receipt In", context)),

                  ////Sales\nReturn
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SalesReturnScreen())); //SalesReturnView
                      //showFeatureNotAvailableDialog(context);
                    },
                    child: _buildIconWithLabel(
                        Icons.redo, "Sales\nReturn", context),
                  ),

                  ////Delivery
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.delivery_dining, "Delivery", context)),
                ],
              ),

              // Purchase Transaction Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Purchase Transaction",
                  style: GoogleFonts.notoSansPhagsPa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Wrap(
                runSpacing: 20,
                spacing: 10,
                children: [
                  ////Purchase
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PurchaseListApi()));

                      //showFeatureNotAvailableDialog(context);
                    },
                    child: _buildIconWithLabel(
                        Icons.add_shopping_cart_rounded, "Purchase", context),
                  ),

                  ////  Purchase/\nOrder
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.work_history, "Purchase/\nOrder", context),
                  ),

                  //// Payment\nOut
                  InkWell(
                      onTap: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PaymentOutList()));
                      },
                      child: _buildIconWithLabel(
                          Icons.tab, "Payment\nOut", context)),

                  ///// Purchase\nReturn
                  InkWell(
                    onTap: () {},
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PurchaseReturnList()));

                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.redo_rounded, "Purchase\nReturn", context),
                    ),
                  ),
                ],
              ),

              // Account Transaction Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Only vertical padding
                child: Text(
                  "Account Transaction",
                  style: GoogleFonts.notoSansPhagsPa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              Wrap(
                runSpacing: 20,
                spacing: 10,
                children: [
                  ////Purchase
                  InkWell(
                    onTap: () {
                      // showDialog(
                      //     context: context,
                      //     builder: (context) =>
                      //         const FeatureNotAvailableDialog());
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Expanse()));
                    },
                    child: _buildIconWithLabel(
                        Icons.card_travel, "Expense", context),
                  ),

                  ////  Purchase/\nOrder
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.work_history, "Contra", context),
                  ),

                  //// Payment\nOut
                  InkWell(
                      onTap: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Income()));
                      },
                      child: _buildIconWithLabel(Icons.tab, "Income", context)),

                  //jurnal
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.article_sharp, "Jurnal", context)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// // Helper function to build an icon with a label
Widget _buildIconWithLabel(IconData icon, String label, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryColor,
          ),
        ),
      ), // Icon size and color
      const SizedBox(height: 4), // Space between icon and text
      Text(
        label,
        style: GoogleFonts.notoSansPhagsPa(fontSize: 12, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class ServiceBottmModel {
  String label;
  Widget page;

  ServiceBottmModel(this.label, this.page);
}

///sales last 30 days chart.
class SalesLast30DaysChart extends StatefulWidget {
  const SalesLast30DaysChart({
    super.key,
  });

  @override
  State<SalesLast30DaysChart> createState() => _SalesLast30DaysChartState();
}

class _SalesLast30DaysChartState extends State<SalesLast30DaysChart> {
  @override
  void initState() {
    super.initState();
    Provider.of<DashboardReportProvider>(context, listen: false)
        .fetchSalesLast30Days();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardReportProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.salesList.isEmpty) {
      return const Center(
          child: Text(
        'No sales data.',
        style: TextStyle(color: Colors.black),
      ));
    }

    return SizedBox(
      height: 300, // Set your desired height
      child: ListView.builder(
        itemCount: provider.salesList.length,
        itemBuilder: (context, index) {
          SalesReportModel sales = provider.salesList[index];
          return ListTile(
            title: Text('Date: ${sales.date}',
                style: const TextStyle(fontSize: 12)),
            subtitle: Text('Sales: ৳${sales.sales.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }
}
