import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateUnitPage extends StatefulWidget {
  final UnitResponseModel unit;

  const UpdateUnitPage({super.key, required this.unit});

  @override
  UpdateUnitPageState createState() => UpdateUnitPageState();
}

class UpdateUnitPageState extends State<UpdateUnitPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit.name);
    _symbolController = TextEditingController(text: widget.unit.symbol);
    
    debugPrint('🔍 UpdateUnitPage initialized with:');
    debugPrint('🔍 ID: ${widget.unit.id}');
    debugPrint('🔍 Name: ${widget.unit.name}');
    debugPrint('🔍 Symbol: ${widget.unit.symbol}');
    debugPrint('🔍 Status: ${widget.unit.status}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  void _updateUnit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      FocusScope.of(context).unfocus();

      try {
        final provider = Provider.of<UnitDTProvider>(context, listen: false);
        
        debugPrint('🚀 Calling updateUnit with:');
        debugPrint('🚀 ID: ${widget.unit.id}');
        debugPrint('🚀 Name: ${_nameController.text.trim()}');
        debugPrint('🚀 Symbol: ${_symbolController.text.trim()}');
        debugPrint('🚀 Status: 1 (hardcoded)');

        // ✅ Simple update call - always status 1
        bool success = await provider.updateUnit(
          widget.unit.id,
          _nameController.text.trim(),
          _symbolController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          if (success) {
            debugPrint('✅ Update successful');
            
            // Verify the unit in the provider
            final updatedUnit = provider.getUnitById(widget.unit.id);
            if (updatedUnit != null) {
              debugPrint('✅ Unit verified: ${updatedUnit.name}, Status: ${updatedUnit.status}');
            } else {
              debugPrint('⚠️ Unit not found after update - this might be the issue!');
              // Let's check if unit exists in backend
              await provider.debugCheckUnit(widget.unit.id);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Unit updated successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            
            Navigator.pop(context, true);
          } else {
            debugPrint('❌ Update failed');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text(
                  'Failed to update unit. Refreshing data...',
                  style: TextStyle(color: Colors.white),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _updateUnit,
                ),
              ),
            );
            
            await provider.refreshUnits();
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        debugPrint('💥 Exception in _updateUnit: $e');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Update Unit",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height - 
                 AppBar().preferredSize.height - 
                 MediaQuery.of(context).padding.top,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Debug card (remove in production)
                     
                      
                      AddSalesFormfield(
                        height: 40,
                        labelText: "Name",
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      AddSalesFormfield(
                        height: 40,
                        labelText: 'Symbol',
                        controller: _symbolController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Symbol is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateUnit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Updating...",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            "Update Unit",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}


