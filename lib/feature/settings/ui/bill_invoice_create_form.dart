import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillInvoiceCreateForm extends StatefulWidget {
  const BillInvoiceCreateForm({super.key});

  @override
  State<BillInvoiceCreateForm> createState() => _BillInvoiceCreateFormState();
}

class _BillInvoiceCreateFormState extends State<BillInvoiceCreateForm> {
  bool _isSwitchedCategory = false;
  bool _isSwitchedPrice = false;
  bool _isSwitchedCategoryPrice = false;
  bool _isStataus = false;
  bool _isSwitchedQtyPrice = false;
  bool _isLoading = true; // NEW: Loading flag
  bool _billInvoiceNumber = false;
  bool _defiledCash = false;
  bool _categorySubCategory = false;
  bool _stockQtyUnitShow = false;
  bool _salesPrice = false;
  bool _purchasePrice = false;
  bool _itemWiseDiscount = false;
  bool _itemWiseVatTax = false;
  bool _billWiseDiscount = false;
  bool _billWiseVatTax = false;
  bool _narrationText = false;
  bool _showProfitLossIcon = false;
  bool _saveNew = false;
  bool _saveA4 = false;
  bool _saveA5 = false;
  bool _qrCodeGen = false;
  bool _shareButton = false;
  bool _smsSend = false;
  bool _maskingCompanyNameSms = false;

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

      //
      _billInvoiceNumber = prefs.getBool('billInvoiceNumber') ?? false;
      _defiledCash = prefs.getBool('defiledCash') ?? false;
      _categorySubCategory = prefs.getBool('categorySubCategory') ?? false;
      _stockQtyUnitShow = prefs.getBool('stockQtyUnitShow') ?? false;
      _salesPrice = prefs.getBool('salesPrice') ?? false;
      _purchasePrice = prefs.getBool('purchasePrice') ?? false;
      _itemWiseDiscount = prefs.getBool('itemWiseDiscount') ?? false;
      _itemWiseVatTax = prefs.getBool('itemWiseVatTax') ?? false;
      _billWiseDiscount = prefs.getBool('billWiseDiscount') ?? false;
      _billWiseVatTax = prefs.getBool('billWiseVatTax') ?? false;
      _narrationText = prefs.getBool('narrationText') ?? false;
      _showProfitLossIcon = prefs.getBool('showProfitLossIcon') ?? false;
      _saveNew = prefs.getBool('saveNew') ?? false;
      _saveA4 = prefs.getBool('saveA4') ?? false;
      _saveA5 = prefs.getBool('saveA5') ?? false;
      _qrCodeGen = prefs.getBool('qrCodeGen') ?? false;
      _shareButton = prefs.getBool('shareButton') ?? false;
      _smsSend = prefs.getBool('smsSend') ?? false;
      _maskingCompanyNameSms = prefs.getBool('maskingCompanyNameSms') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitchedCategory', _isSwitchedCategory);
    prefs.setBool('isSwitchedPrice', _isSwitchedPrice);
    prefs.setBool('isSwitchedCategoryPrice', _isSwitchedCategoryPrice);
    prefs.setBool('isStatus', _isStataus);
    prefs.setBool('isSwitchedQtyPrice', _isSwitchedQtyPrice);

    prefs.setBool('billInvoiceNumber', _billInvoiceNumber);
    prefs.setBool('defiledCash', _defiledCash);
    prefs.setBool('categorySubCategory', _categorySubCategory);
    prefs.setBool('stockQtyUnitShow', _stockQtyUnitShow);
    prefs.setBool('salesPrice', _salesPrice);
    prefs.setBool('purchasePrice', _purchasePrice);
    prefs.setBool('itemWiseDiscount', _itemWiseDiscount);
    prefs.setBool('itemWiseVatTax', _itemWiseVatTax);
    prefs.setBool('billWiseDiscount', _billWiseDiscount);
    prefs.setBool('billWiseVatTax', _billWiseVatTax);
    prefs.setBool('narrationText', _narrationText);
    prefs.setBool('showProfitLossIcon', _showProfitLossIcon);
    prefs.setBool('saveNew', _saveNew);
    prefs.setBool('saveA4', _saveA4);
    prefs.setBool('saveA5', _saveA5);
    prefs.setBool('qrCodeGen', _qrCodeGen);
    prefs.setBool('shareButton', _shareButton);
    prefs.setBool('smsSend', _smsSend);
    prefs.setBool('maskingCompanyNameSms', _maskingCompanyNameSms);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        title: const Text(
          'Bill Invoice Create Form',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // ← makes back icon white
        ),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
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
              ///===>>>Bill/Invoice Number
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Bill/Invoice Number",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    //inactiveTrackColor: Colors.orange,
                    inactiveThumbColor: const Color(0xff278d46),

                    //activeColor: Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),

                    value: _billInvoiceNumber,
                    onChanged: (bool value) {
                      setState(() {
                        _billInvoiceNumber = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///===>>> Defiled cash
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Defiled cash",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _defiledCash,
                    onChanged: (bool value) {
                      setState(() {
                        _defiledCash = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Category/Sub Category
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Category/Sub Category",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    
                    value: _categorySubCategory,
                    onChanged: (bool value) {
                      setState(() {
                        _categorySubCategory = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Stock Qty & Unit Show
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Stock Qty & Unit Show",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _stockQtyUnitShow,
                    onChanged: (bool value) {
                      setState(() {
                        _stockQtyUnitShow = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Sale Price
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Sale Price",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _salesPrice,
                    onChanged: (bool value) {
                      setState(() {
                        _salesPrice = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Purchase Price
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Purchase Price",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _purchasePrice,
                    onChanged: (bool value) {
                      setState(() {
                        _purchasePrice = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Item wise Discount
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Item wise Discount",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _itemWiseDiscount,
                    onChanged: (bool value) {
                      setState(() {
                        _itemWiseDiscount = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///_itemWiseVatTax
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Bill Wise Discount",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _itemWiseVatTax,
                    onChanged: (bool value) {
                      setState(() {
                        _itemWiseVatTax = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Bill Wise Discount
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Bill Wise Discount",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _billWiseDiscount,
                    onChanged: (bool value) {
                      setState(() {
                        _billWiseDiscount = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Bill Wise Vat/Tax
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Bill Wise Vat/Tax",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _billWiseVatTax,
                    onChanged: (bool value) {
                      setState(() {
                        _billWiseVatTax = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Narration Text
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Narration Text",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _narrationText,
                    onChanged: (bool value) {
                      setState(() {
                        _narrationText = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Show Profit/Loss Icon
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Show Profit/Loss Icon",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _showProfitLossIcon,
                    onChanged: (bool value) {
                      setState(() {
                        _showProfitLossIcon = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Save & New
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Save & New",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _saveNew,
                    onChanged: (bool value) {
                      setState(() {
                        _saveNew = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Save & A4
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Save & A4",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _saveA4,
                    onChanged: (bool value) {
                      setState(() {
                        _saveA4 = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Save & A5
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Save & A5",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _saveA5,
                    onChanged: (bool value) {
                      setState(() {
                        _saveA5 = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///QR Coad Ganaret
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "QR Coad Ganaret",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _qrCodeGen,
                    onChanged: (bool value) {
                      setState(() {
                        _qrCodeGen = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Share Button
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Share Button",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _shareButton,
                    onChanged: (bool value) {
                      setState(() {
                        _shareButton = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///SMS send
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "SMS send",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _smsSend,
                    onChanged: (bool value) {
                      setState(() {
                        _smsSend = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),

              ///Masking/Company Name SMS Sent
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: const Text(
                  "Masking/Company Name SMS Sent",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    inactiveThumbColor: const Color(0xff278d46),
                    activeTrackColor: const Color(0xff278d46),
                    trackOutlineColor:
                        WidgetStateProperty.all(const Color(0xff278d46)),
                    value: _maskingCompanyNameSms,
                    onChanged: (bool value) {
                      setState(() {
                        _maskingCompanyNameSms = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
