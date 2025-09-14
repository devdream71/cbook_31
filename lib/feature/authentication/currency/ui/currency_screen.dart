import 'package:cbook_dt/feature/authentication/currency/provider/currency_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyWidget extends StatefulWidget {
  const CurrencyWidget({super.key});

  @override
  State<CurrencyWidget> createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CurrencyProvider>(context, listen: false).fetchCurrency());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CircularProgressIndicator();
        }
        if (provider.currencyModel == null ||
            provider.currencyModel!.currency.isEmpty) {
          return const Text("No currency found");
        }
        return Text(
          "Currency: ${provider.currencyModel!.currency}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
