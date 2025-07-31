import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/account/ui/account_type/account_type_list.dart';
import 'package:cbook_dt/feature/account/ui/bank_ui.dart';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/cash_in_hand.dart';
import 'package:cbook_dt/feature/account/ui/discount.dart';
 import 'package:cbook_dt/feature/account/ui/expense/expense_report.dart';
 import 'package:cbook_dt/feature/account/ui/income/income_report.dart';
 import 'package:cbook_dt/feature/tax/UI/tax_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final forms = [
      FormSettingMeta(
        name: 'Cash In Hand',
        iconPath: 'assets/image/cash.svg',
        destination: CashInHand(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Bank',
        iconPath: 'assets/image/bank.svg',
        destination: Bank(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Income',
        iconPath: 'assets/image/income.svg',
        destination: IncomeReport(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Expanse',
        iconPath: 'assets/image/expanse.svg',
        destination: ExpenseReport(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Discount',
        iconPath: 'assets/image/discount.svg',
        destination: Discount(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Vat/Tax',
        iconPath: 'assets/image/vat_tax.svg',
        destination: TaxListView(), //SalesFormSetting
      ),
      const FormSettingMeta(
        name: 'Account Type',
        iconPath: 'assets/image/vat_tax.svg',
        destination: AccountListPage(), //SalesFormSetting
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Account',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: forms.length,
          separatorBuilder: (context, index) => Divider(
            height: 1, // Adjust height to eliminate vertical gap
            thickness: 1, // Optional: control thickness of the divider
            color: Colors.grey.shade300, // Optional: customize divider color
          ),
          itemBuilder: (context, index) {
            final form = forms[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: true,
              visualDensity: VisualDensity.compact,
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
                size: 10,
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
