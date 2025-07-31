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
  bool _status = true;

  String selectedStatus = "1";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit.name);
    _symbolController = TextEditingController(text: widget.unit.symbol);
    _status = widget.unit.status == "1";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  void _updateUnit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<UnitDTProvider>(context, listen: false)
          .updateUnit(
        widget.unit.id,
        _nameController.text,
        _symbolController.text,
        _status ? "1" : "0",
        context,
      )
          .then((_) {
        Navigator.pop(context); // Go back to the list after update
      });
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
          )),
      body: Padding(
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
                    AddSalesFormfield(
                      height: 40,
                      labelText: "Name",
                      controller: _nameController,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    AddSalesFormfield(
                      height: 40,
                      labelText: 'Symbol',
                      controller: _symbolController,
                    ),
                    const SizedBox(height: 10),
                   
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateUnit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Update Unit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

               const SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}
