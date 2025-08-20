import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/bill_voucher_settings/screen/bill_settings_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bill_settings_provider.dart';

class BillSettingsView extends StatefulWidget {
  const BillSettingsView({super.key});

  @override
  State<BillSettingsView> createState() => _BillSettingsViewState();
}

class _BillSettingsViewState extends State<BillSettingsView> {
  @override
  void initState() {
    super.initState();
    // Fetch settings when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<BillSettingsProvider>(context, listen: false);
      if (!provider.hasSettings) {
        provider.fetchSettings();
      }
    });
  }

  Future<void> _navigateToUpdate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BillSettingsUpdate(),
      ),
    );

    // If update was successful, refresh the settings
    if (result == true && mounted) {
      final provider =
          Provider.of<BillSettingsProvider>(context, listen: false);
      await provider.fetchSettings();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings refreshed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        actions: [
          InkWell(
            onTap: _navigateToUpdate,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Update',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Consumer<BillSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && !provider.hasSettings) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchSettings(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.settings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No settings found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure your bill settings to get started',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToUpdate,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSettings(),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(4),
              itemCount: provider.settings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final setting = provider.settings[index];
                return Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // radius 0
                  ),

                  //elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    leading: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _formatSettingKey(setting.data),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      setting.value ?? 'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to format setting keys for better display
  String _formatSettingKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
