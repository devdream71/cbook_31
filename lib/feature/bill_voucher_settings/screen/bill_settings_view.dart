import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bill_settings_provider.dart';

class BillSettingsView extends StatelessWidget {
  const BillSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    final provider = Provider.of<BillSettingsProvider>(context);

    return Scaffold(
     backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'Bill Settings',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
         
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.settings.length,
              itemBuilder: (context, index) {
                final setting = provider.settings[index];
                return ListTile(
                  title: Text(setting.data),
                  subtitle: Text(setting.value ?? 'N/A'),
                );
              },
            ),
    );
  }
}
