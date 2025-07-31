import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemSettingsPage extends StatefulWidget {
  const ItemSettingsPage({super.key});

  @override
  State<ItemSettingsPage> createState() => _ItemSettingsPageState();
}

class _ItemSettingsPageState extends State<ItemSettingsPage> {
  bool _isSwitchedCategory = false;
  bool _isSwitchedPrice = false;
  bool _isSwitchedCategoryPrice = false;
  bool _isStataus = false;
  bool _isSwitchedQtyPrice = false;
  bool _isLoading = true; // NEW: Loading flag

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSwitchedCategory = prefs.getBool('isSwitchedCategory') ?? false;
      _isSwitchedPrice = prefs.getBool('isSwitchedPrice') ?? false;
      _isSwitchedCategoryPrice =
          prefs.getBool('isSwitchedCategoryPrice') ?? false;
      _isStataus = prefs.getBool('isStatus') ?? false;
      _isSwitchedQtyPrice = prefs.getBool('isSwitchedQtyPrice') ?? false;
      _isLoading = false; // Loading done
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitchedCategory', _isSwitchedCategory);
    prefs.setBool('isSwitchedPrice', _isSwitchedPrice);
    prefs.setBool('isSwitchedCategoryPrice', _isSwitchedCategoryPrice);
    prefs.setBool('isStatus', _isStataus);
    prefs.setBool('isSwitchedQtyPrice', _isSwitchedQtyPrice);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // <-- Show loading
      );
    }

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activation Switch",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Now your switches

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable item category & subcategory",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  inactiveThumbColor: const Color(0xff278d46),
                  activeTrackColor: const Color(0xff278d46),
                  trackOutlineColor:
                      WidgetStateProperty.all(const Color(0xff278d46)),
                  value: _isSwitchedCategory,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedCategory = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable item price level",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  inactiveThumbColor: const Color(0xff278d46),
                  activeTrackColor: const Color(0xff278d46),
                  trackOutlineColor:
                      WidgetStateProperty.all(const Color(0xff278d46)),
                  value: _isSwitchedPrice,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedPrice = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable item price Category",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  inactiveThumbColor: const Color(0xff278d46),
                  activeTrackColor: const Color(0xff278d46),
                  trackOutlineColor:
                      WidgetStateProperty.all(const Color(0xff278d46)),
                  value: _isSwitchedCategoryPrice,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedCategoryPrice = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable item Status",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  inactiveThumbColor: const Color(0xff278d46),
                  activeTrackColor: const Color(0xff278d46),
                  trackOutlineColor:
                      WidgetStateProperty.all(const Color(0xff278d46)),
                  value: _isStataus,
                  onChanged: (bool value) {
                    setState(() {
                      _isStataus = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: const Text(
                "Enable item QTY price",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Transform.scale(
                scale: 0.75,
                child: Switch(
                  inactiveThumbColor: const Color(0xff278d46),
                  activeTrackColor: const Color(0xff278d46),
                  trackOutlineColor:
                      WidgetStateProperty.all(const Color(0xff278d46)),
                  value: _isSwitchedQtyPrice,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedQtyPrice = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
