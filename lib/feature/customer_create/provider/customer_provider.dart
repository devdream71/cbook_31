import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/model/payment_voicer_model.dart';
import 'package:cbook_dt/feature/customer_create/model/received_voucher_model.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  Customer? _selectedCustomer;

  Customer? get selectedCustomer => _selectedCustomer;

  Customer? _selectedCustomerRecived;
  Customer? get selectedCustomerRecived => _selectedCustomerRecived;

  void setSelectedCustomer(Customer customer) {
    _selectedCustomer = customer;
    fetchPaymentVouchersByCustomerId(customer.id);
    notifyListeners();
  }

  void setSelectedCustomerRecived(Customer customer) {
    _selectedCustomerRecived = customer;
    fetchReceviedVouchersByCustomerId(customer.id);
    notifyListeners();
  }

  

  void clearSelectedCustomerRecived() {
    _selectedCustomerRecived = null;
    receivedVouchers.clear();

    notifyListeners();
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  void clearCustomerList() {
    customerResponse = null;
    notifyListeners();
  }


  
  // ✅ ADD: Payment customer selection (if you need separate payment customer tracking)
  Customer? _selectedCustomerPayment;
  Customer? get selectedCustomerPayment => _selectedCustomerPayment;

  void setSelectedCustomerPayment(Customer customer) {
    _selectedCustomerPayment = customer;
    fetchPaymentVouchersByCustomerId(customer.id);
    notifyListeners();
  }

  void clearSelectedCustomerPayment() {
    _selectedCustomerPayment = null;
    _paymentVouchers.clear();
    notifyListeners();
  }

  // ✅ ADD: Set selected payment customer by ID
  void setSelectedCustomerPaymentById(int customerId) {
    final customer = findCustomerById(customerId);
    if (customer != null) {
      setSelectedCustomerPayment(customer);
    }
  }


  



  bool isLoading = false;
  CustomerResponse? customerResponse;

  String errorMessage = "";

  ///show supplier
  Future<void> fetchCustomsr() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners(); // Notify listeners that data is being fetched

    //final url = Uri.parse('https://commercebook.site/api/v1/customers/list');

    final url = Uri.parse(
        'https://commercebook.site/api/v1/all/customers/'); //api/v1/all/customers/

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      // Print the entire response in the terminal
      debugPrint("API Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        customerResponse = CustomerResponse.fromJson(data);
        // Print the parsed data for debugging
        debugPrint("Parsed Supplier Data: ${customerResponse!.data}");
      } else {
        errorMessage = "Failed to fetch suppliers";
        debugPrint("Error: $errorMessage");
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners(); // Notify after data fetch is completed
  }


  // ✅ ADD THIS METHOD - Find customer by ID
  Customer? findCustomerById(int customerId) {
    if (customerResponse?.data == null) return null;
    
    try {
      return customerResponse!.data.firstWhere((customer) => customer.id == customerId);
    } catch (e) {
      debugPrint('Customer not found with ID: $customerId');
      return null;
    }
  }

  // ✅ ADD THIS METHOD - Set selected customer for received voucher by ID
  void setSelectedCustomerRecivedById(int customerId) {
    final customer = findCustomerById(customerId);
    if (customer != null) {
      setSelectedCustomerRecived(customer);
    }
  }

  // ✅ ADD THIS METHOD - Set selected customer by ID (for regular customer selection)
  void setSelectedCustomerById(int customerId) {
    final customer = findCustomerById(customerId);
    if (customer != null) {
      setSelectedCustomer(customer);
    }
  }


  ///paymet voucher
  List<PaymentVoucherCustomer> _paymentVouchers = [];
  List<PaymentVoucherCustomer> get paymentVouchers => _paymentVouchers;

  Future<void> fetchPaymentVouchersByCustomerId(int customerId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/payment-vouchers/purchase/invoice/$customerId');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      debugPrint("Payment Voucher Response: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> dataList = data['data'] ?? [];
        _paymentVouchers = dataList
            .map((item) => PaymentVoucherCustomer.fromJson(item))
            .toList();
      } else {
        _paymentVouchers = [];
      }
    } catch (e) {
      debugPrint("Error fetching vouchers: $e");
      _paymentVouchers = [];
    }

    notifyListeners();
  }

  ////received voucer
  List<ReceivedVoucherCustomer> _receivedVouchers = [];
  List<ReceivedVoucherCustomer> get receivedVouchers => _receivedVouchers;

  Future<void> fetchReceviedVouchersByCustomerId(int customerId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/receive-vouchers/sales/invoice/$customerId');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      debugPrint("received Voucher Response: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> dataList = data['data'] ?? [];
        _receivedVouchers = dataList
            .map((item) => ReceivedVoucherCustomer.fromJson(item))
            .toList();
      } else {
        _receivedVouchers = [];
      }
    } catch (e) {
      debugPrint("Error fetching vouchers: $e");
      _receivedVouchers = [];
    }

    notifyListeners();
  }

  ///delete customer
  Future<bool> deleteCustomer(int supplierId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/customer/remove/$supplierId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint("Delete Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        // Optional: remove from local list if needed
        customerResponse?.data
            .removeWhere((customer) => customer.id == supplierId);

        notifyListeners();
        return true; // Success
      } else {
        debugPrint("Error deleting supplier: ${data['message']}");
        return false; // Failed
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false; // Failed
    }
  }

  /// Create new customer
  // Future<void> createCustomer({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String address,
  //   required String status, // '1' or '0'
  //   required String proprietorName,
  //   required String openingBalance,
  //   String levelType = "",
  //   String level = "",
  //   File? imageFile,
  // }) async {
  //   isLoading = true;
  //   errorMessage = "";
  //   notifyListeners();

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String userId = prefs.getInt('user_id')?.toString() ?? '';

  //   final url = Uri.parse('https://commercebook.site/api/v1/customer/store');

  //   try {
  //     // Build the request body dynamically
  //     Map<String, dynamic> body = {
  //       'user_id': userId,
  //       'name': name,
  //       'email': email,
  //       'phone': phone,
  //       'address': address,
  //       'status': status, // Ensure it's '1' or '0'
  //       'proprietor_name': proprietorName,
  //       'opening_balance': openingBalance,
  //     };

  //     // Add level_type and level only if levelType is not empty
  //     if (levelType.isNotEmpty) {
  //       body['level_type'] = levelType;
  //       body['level'] = "1";
  //     }

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: jsonEncode(body),
  //     );

  //     // Debugging: Print the raw response
  //     debugPrint("Response Status: ${response.statusCode}");
  //     debugPrint("Response Body: ${response.body}");

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = jsonDecode(response.body);

  //       if (data["success"] == true) {
  //         debugPrint("Customer Created: ${data['data']['name']}");
  //       } else {
  //         errorMessage = data['message'] ?? "Failed to create customer";
  //       }
  //     } else {
  //       errorMessage = "Unexpected response from the server";
  //     }
  //   } catch (e) {
  //     errorMessage = "Error: $e";
  //     debugPrint("Error: $e");
  //   }

  //   isLoading = false;
  //   notifyListeners();
  // }



  Future<void> createCustomer({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String status, // '1' or '0'
  required String proprietorName,
  required String openingBalance,
  String levelType = "",
  String level = "",
  File? imageFile, // pass File(...) from XFile.path
}) async {
  isLoading = true;
  errorMessage = "";
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')?.toString() ?? '';

    final url = Uri.parse('https://commercebook.site/api/v1/customer/store');
    final request = http.MultipartRequest('POST', url);

    // ---- Fields (all as strings) ----
    request.fields.addAll({
      'user_id': userId,
      'name': name,
      'proprietor_name': proprietorName,
      'email': email,
      'phone': phone,
      'opening_balance': openingBalance,
      'address': address,
      'status': status, // '1' or '0'
    });

    // Optional level fields
    if (levelType.isNotEmpty) {
      request.fields['level_type'] = levelType; // e.g., dealer_price
      request.fields['level'] = "1";
    } else {
      // If API requires them even when empty, uncomment:
      // request.fields['level_type'] = '';
      // request.fields['level'] = '';
    }

    // ---- Optional image ----
    if (imageFile != null) {
      // Field name must match backend: 'avatar'
      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );
    }

    // Optional headers; DO NOT set Content-Type manually for MultipartRequest
    request.headers.addAll({
      'Accept': 'application/json',
      // 'Authorization': 'Bearer <token>', // if your API needs it
    });

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint("CreateCustomer Status: ${response.statusCode}");
    debugPrint("CreateCustomer Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data is Map && data['success'] == true) {
        errorMessage = "";
        // You can read returned fields if needed:
        // final createdName = data['data']?['name'];
        // debugPrint("Customer Created: $createdName");
      } else {
        errorMessage = (data is Map ? (data['message']?.toString() ?? '') : '')
            .isNotEmpty
            ? data['message'].toString()
            : "Failed to create customer";
      }
    } else {
      errorMessage = "Unexpected response (${response.statusCode})";
    }
  } catch (e) {
    errorMessage = "Error: $e";
    debugPrint("Create customer error: $e");
  }

  isLoading = false;
  notifyListeners();
}


  
  
  
  
  
  
  
  ///get customer by id
  Future<CustomerData?> fetchCustomerById(int customerId) async {
    final url =
        Uri.parse('https://commercebook.site/api/v1/customer/edit/$customerId');
    try {
      final response = await http.get(url);
      debugPrint("API Response: ${response.body}"); // 🔍 Debugging Step

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return CustomerCreateResponse.fromJson(data).data;
      } else {
        debugPrint("Error fetching customer: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }

 
  ///customer update.
  Future<void> updateCustomer({
    required String id,
    required String name,
    required String proprietorName,
    required String email,
    required String phone,
    required String address,
    required String status,
    required String level, // "0" or "1"
    required String levelType, // Only used if level is "1"
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getInt('user_id')?.toString();

    if (userId == null || userId.isEmpty) {
      errorMessage = "User ID is not available. Please login again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    if (id.isEmpty || id == '0') {
      errorMessage = "Customer ID is not valid!";
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('https://commercebook.site/api/v1/customer/update');

    Map<String, dynamic> body = {
      'user_id': userId,
      'id': id,
      'name': name,
      'proprietor_name': proprietorName,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'level': level,
    };

    // Only add `level_type` if level is "1"
    if (level == "1") {
      body['level_type'] = levelType;
    }

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        debugPrint("Customer updated successfully");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeView()));
      } else {
        errorMessage = data["message"] ?? "Failed to update customer";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
