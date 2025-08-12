import 'package:cbook_dt/feature/Received/provider/received_provider.dart';
import 'package:cbook_dt/feature/account/ui/account_type/provider/account_type_provider.dart';
import 'package:cbook_dt/feature/account/ui/adjust_bank/provider/bank_adjust_provider.dart';
import 'package:cbook_dt/feature/account/ui/adjust_cash/provider/adjust_cash_provider.dart';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/provider/cash_in_hand.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/authentication/provider/login_provider.dart';
import 'package:cbook_dt/feature/authentication/provider/otp_provider.dart';
import 'package:cbook_dt/feature/authentication/provider/reg_provider.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/provider/bill_settings_provider.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:cbook_dt/feature/home/provider/profile_provider.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/item_save_provider.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/item/provider/update_item_provider.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/purchase/controller/purchase_controller.dart';
import 'package:cbook_dt/feature/purchase/provider/purchase_provider.dart';
import 'package:cbook_dt/feature/purchase/purchase_update.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:cbook_dt/feature/sales/provider/sales_provider.dart';
import 'package:cbook_dt/feature/sales/sales_update.dart';
import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_provider/user_provider.dart';
import 'package:cbook_dt/feature/splash_screen.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_const/app_colors.dart';
import 'feature/sales/controller/sales_controller.dart';

//  ===> 13/04.25

//  DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => MultiProvider(
//         providers: [
//           ChangeNotifierProvider(create: (_) => SalesController()),
//           ChangeNotifierProvider(create: (_) => PurchaseController()),
//           ChangeNotifierProvider(create: (_) => SalesReturnController()),
//           ChangeNotifierProvider(create: (_) => PurchaseReturnController()),
//           ChangeNotifierProvider(create: (context) => AuthService()),
//           ChangeNotifierProvider(create: (context) => VerificationProvider()),
//           ChangeNotifierProvider(create: (context) => LoginProvider()),
//           ChangeNotifierProvider(create: (context) => ProfileProvider()),
//           ChangeNotifierProvider(create: (context) => ItemProvider()),
//           ChangeNotifierProvider(create: (context) => AddItemProvider()..fetchItems()),
//           ChangeNotifierProvider(create: (context) => ItemUpdateProvider()),
//           ChangeNotifierProvider(create: (context) => UnitProvider()),
//           ChangeNotifierProvider(create: (context) => SupplierProvider()),
//           ChangeNotifierProvider(create: (context) => CustomerProvider()),
//           ChangeNotifierProvider(create: (context) => ItemCategoryProvider()),
//           ChangeNotifierProvider(create: (context) => PurchaseProvider()),
//           ChangeNotifierProvider(create: (context) => UnitDTProvider()),
//           ChangeNotifierProvider(create: (context) => PurchaseUpdateProvider()),
//           ChangeNotifierProvider(create: (context) => SalesProvider()),
//           ChangeNotifierProvider(create: (context) => SaleUpdateProvider()),
//           ChangeNotifierProvider(create: (_) => PurchaseReturnProvider()),
//         ],
//         child: const MyApp(),

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // or your desired color
      statusBarIconBrightness: Brightness.light, // light icons
      statusBarBrightness: Brightness.dark, // for iOS
    ),
  );

  ////!====>issue
  ////----->>>invoice unit not found
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SalesController()),
          ChangeNotifierProvider(create: (_) => PurchaseController()),
          ChangeNotifierProvider(create: (_) => SalesReturnController()),
          ChangeNotifierProvider(create: (_) => PurchaseReturnController()),
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProvider(create: (context) => VerificationProvider()),
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => ProfileProvider()),
          ChangeNotifierProvider(create: (context) => ItemProvider()),
          ChangeNotifierProvider(create: (context) => AddItemProvider()..fetchItems()),
          ChangeNotifierProvider(create: (context) => ItemUpdateProvider()),
          ChangeNotifierProvider(create: (context) => UnitProvider()),
          ChangeNotifierProvider(create: (context) => SupplierProvider()),
          ChangeNotifierProvider(create: (context) => CustomerProvider()),
          ChangeNotifierProvider(create: (context) => ItemCategoryProvider()),
          ChangeNotifierProvider(create: (context) => PurchaseProvider()),
          ChangeNotifierProvider(create: (context) => UnitDTProvider()),
          ChangeNotifierProvider(create: (context) => PurchaseUpdateProvider()),
          ChangeNotifierProvider(create: (context) => SalesProvider()),
          ChangeNotifierProvider(create: (context) => SaleUpdateProvider()),
          ChangeNotifierProvider(create: (_) => PurchaseReturnProvider()),
          ChangeNotifierProvider(create: (_) => SalesReturnProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TaxProvider()..fetchTaxes()),
          ChangeNotifierProvider(create: (_) => SettingUserProvider()..fetchUsers()),
          ChangeNotifierProvider(create: (_) => IncomeProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
          ChangeNotifierProvider(create: (_) => ReceiveVoucherProvider()),
          ChangeNotifierProvider(create: (_) => BillPersonProvider()),
          ChangeNotifierProvider(create: (_) => AccountTypeProvider()),
          ChangeNotifierProvider(create: (_) => CashInHandProvider()),
          ChangeNotifierProvider(create: (_) => AdjustCashProvider()),
          ChangeNotifierProvider(create: (_) => BankAdjustProvider()),
          ChangeNotifierProvider(create: (_) => BillSettingsProvider()..fetchSettings()),
          ChangeNotifierProvider(create: (_) =>DashboardReportProvider()..fetchCustomerTransaction(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.fetchProfileFromPrefs(); //Load once
    });
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token'); // Returns true if token exists
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        return MaterialApp(
          //useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          theme: ThemeData(
            fontFamily: 'Calibri',
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              secondary: AppColors.secondaryColor,
              onSecondary: Colors.black,
              surface: AppColors.backgroundColor,
              onSurface: Colors.black,
              error: Colors.red,
              onError: Colors.white,
            ),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.notoSansPhagsPa(
                color: AppColors.textColor,
                fontSize: 18,
              ),
              bodyMedium: GoogleFonts.notoSansPhagsPa(
                color: AppColors.textColor,
                fontSize: 16,
              ),
              bodySmall: GoogleFonts.notoSansPhagsPa(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.iconColor),
          ),
          home: const SplashScreen(),
          //loginProvider.isLoggedIn ? const HomeView() : const ComapnyLogin(),
        );
      },
    );
  }
}  


////key tool for genarate the jks file.  
////keytool -genkey -v -keystore "C:\Users\ak_dev\.android\upload-keystore.jks" -alias upload -keyalg RSA -keysize 2048 -validity 10000 -storepass cbook@123 -keypass cbook@123
