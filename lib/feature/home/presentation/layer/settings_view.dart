import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/screen/bill_settings_view.dart';
import 'package:cbook_dt/feature/home/presentation/layer/profile_view.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_print.dart';
import 'package:cbook_dt/feature/settings/ui/bill/bill_person_list.dart';
import 'package:cbook_dt/feature/settings/ui/company_settings.dart';
import 'package:cbook_dt/feature/settings/ui/general_settings.dart';
import 'package:cbook_dt/feature/settings/ui/module_settings.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata
    final forms = [
      const FormSettingMeta(
        name: 'Company Settings',
        iconPath: 'assets/image/setting_one.svg',
        destination: CompanySettings(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'My Profile',
        iconPath: 'assets/image/profile.svg',
        destination: ProfileView(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'General Setting',
        iconPath: 'assets/image/setting_four.svg',
        destination: GeneralSettings(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Module Setting',
        iconPath: 'assets/image/settings.svg',
        destination: ModuleSettings(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Bill/Invoice Create Form',
        iconPath: 'assets/image/form.svg',
        destination: BillInvoiceCreateForm(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Bill/Invoice Print',
        iconPath: 'assets/image/print_print.svg',
        destination: BillInvoicePrint(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'User',
        iconPath: 'assets/image/profile.svg',
        destination: UserCeate(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Bill Person',
        iconPath: 'assets/image/profile.svg',
        destination: BillPersonList(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Bill Settings',
        iconPath: 'assets/image/profile.svg',
        destination: BillSettingsView(), //SalesFormSetting
      ),
    ];

    return Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero, // <== removes outer ListView padding
          itemCount: forms.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          itemBuilder: (context, index) {
            final form = forms[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              //visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              dense: true, // <== smaller vertical size
              visualDensity: VisualDensity.compact, // <== even more compact
              //contentPadding: EdgeInsets.zero, // <== removes ListTile padding

              title: Text(
                form.name,
                style: GoogleFonts.notoSansPhagsPa(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              leading: SvgPicture.asset(
                form.iconPath,
                width: 20,
                height: 20,
                color: colorScheme.primary,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: colorScheme.primary,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => form.destination),
              ),
            );
          },
        ));
  }
}

class FormSettingMeta {
  final String name;
  final String iconPath;
  final Widget destination;

  const FormSettingMeta({
    required this.name,
    required this.iconPath,
    required this.destination,
  });
}
