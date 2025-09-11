import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/no_data_fount.dart';
import 'package:cbook_dt/feature/unit/add_unit.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:cbook_dt/feature/unit/update_unit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnitListView extends StatefulWidget {
  const UnitListView({super.key});

  @override
  UnitListViewState createState() => UnitListViewState();
}

class UnitListViewState extends State<UnitListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnitDTProvider>(context, listen: false).fetchUnits();
    });
  }

  void _refreshUnits() {
    Provider.of<UnitDTProvider>(context, listen: false).refreshUnits();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Units List',
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddUnit()));

              if (result == 'refresh_needed') {
                _refreshUnits();
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Consumer<UnitDTProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.units.isEmpty) {
                  return const Center(
                    child: NoDataWidget(
                      message: "No unit records found.",
                      lottieAsset: "assets/animation/no_data.json",
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.refreshUnits();
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.units.length,
                    itemBuilder: (context, index) {
                      final unit = provider.units[index];
                      final unitId = unit.id.toString();

                      return InkWell(
                        onLongPress: () {
                          editDeleteDialog(context, unitId, unit);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 16),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryColor,
                              radius: 15,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                            title: Text(
                              unit.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Symbol: ${unit.symbol}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> editDeleteDialog(
      BuildContext context, String unitId, UnitResponseModel unit) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();

                    debugPrint(
                        '🔄 Before update - Unit exists: ${Provider.of<UnitDTProvider>(context, listen: false).unitExists(unit.id)}');

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateUnitPage(unit: unit),
                      ),
                    );

                    debugPrint(
                        '🔄 After update - Unit exists: ${Provider.of<UnitDTProvider>(context, listen: false).unitExists(unit.id)}');

                    if (result == 'refresh_needed') {
                      _refreshUnits();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, unitId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String unitId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Unit',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Unit?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _performDelete(context, unitId),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ Separated delete logic for better error handling
  void _performDelete(BuildContext dialogContext, String unitId) async {
    // Close the confirmation dialog first
    Navigator.of(dialogContext).pop();

    // Show loading dialog
    final loadingContext = context;
    showDialog(
      context: loadingContext,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Deleting unit...',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final provider = Provider.of<UnitDTProvider>(context, listen: false);

      debugPrint('🗑️ Starting delete operation for unit: $unitId');

      bool isDeleted = await provider.deleteUnit(int.parse(unitId), context);

      // ✅ Close loading dialog - check if context is still mounted
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      debugPrint('🗑️ Delete operation completed: $isDeleted');

      // Show result message
      if (mounted) {
        if (isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Unit deleted successfully!',
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          debugPrint('✅ Unit deleted from local list successfully');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Failed to delete unit',
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 3),
            ),
          );
          debugPrint('❌ Delete failed, refreshing list');
          _refreshUnits();
        }
      }
    } catch (e) {
      debugPrint('💥 Exception during delete: $e');

      // ✅ Ensure loading dialog is closed even on error
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error deleting unit: $e',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Refresh',
              textColor: Colors.white,
              onPressed: _refreshUnits,
            ),
          ),
        );
        _refreshUnits();
      }
    }
  }
}
