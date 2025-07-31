import 'package:cbook_dt/feature/account/account.dart';
import 'package:cbook_dt/feature/home/presentation/layer/dashboard/dashboard_view.dart';
import 'package:cbook_dt/feature/home/presentation/layer/item_view.dart';
import 'package:cbook_dt/feature/home/presentation/layer/report_view.dart';
import 'package:cbook_dt/feature/home/presentation/layer/transaction_view.dart';
import 'package:cbook_dt/feature/party/party_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'layer/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  //home, party, item, accounts, trangaction, report, settings

  // Pages corresponding to each tab
  final List<Widget> _pages = [
    const DashboardView(),
    const Party(),
    const ItemView(),
    const Account(),
    const TransactionView(),
    const ReportView(),
    const SettingsView(),
    //const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<String> title = [
    "Dashboard",
    'Party'
    "Item",
    "Account"
    "Transaction",
    "Report",
    'Settings',
    //"Profile",
  ];
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: colorScheme.primary, // status bar color
        statusBarIconBrightness: Brightness.light, // status bar icon color
      ),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors
                .transparent, // Ensure the Container itself is transparent
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2), topRight: Radius.circular(2)),
            child: BottomNavigationBar(
              backgroundColor:
                  colorScheme.primary, // Transparent background for the bar
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
              type: BottomNavigationBarType.fixed,
              elevation: 0, // Ensure no shadow or elevation
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: 'Party',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Item',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet), //
                  label: 'Account',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  label: 'Transaction',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
