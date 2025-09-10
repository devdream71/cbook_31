import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
import 'package:cbook_dt/feature/settings/ui/bill/model/designation_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BillPersonProvider with ChangeNotifier {
  List<BillPersonModel> _billPersons = [];
  bool isLoading = false;
  String errorMessage = '';

  List<BillPersonModel> get billPersons => _billPersons;

  ///bill person list.
  Future<void> fetchBillPersons() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        errorMessage = 'No token found. Please login again.';
        isLoading = false;
        notifyListeners();
        return;
      }

    final url = Uri.parse('${AppUrl.baseurl}bill/person/list');

    try {
      final response = await http.get(url,
      headers: {
         "Authorization": "Bearer $token",
          "Accept": "application/json",
      }
      );
      debugPrint('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> billPersonsData = data['data'];
          _billPersons = billPersonsData
              .map((item) => BillPersonModel.fromJson(item))
              .toList();
        } else {
          errorMessage = 'Failed to load bill persons';
          _billPersons = [];
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        _billPersons = [];
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      _billPersons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///delete billl person
  Future<bool> deleteBillPerson(String id) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/bill/person/remove/?id=$id');

    try {
      final response = await http.post(url); // ✅ API uses POST for deletion

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Optionally remove the deleted item from local list
          _billPersons.removeWhere((person) => person.id.toString() == id);
          notifyListeners();
          return true;
        } else {
          errorMessage = data['message'] ?? 'Failed to delete bill person.';
          return false;
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    }
  }

  ///create bill person.
  Future<bool> createBillPerson({
    required String userId,
    required String name,
    required String nickName,
    required String email,
    required String phone,
    required String designation,
    required String address,
    required String date,
      String ? status,
    File? avatarFile, // use File, not base64
  }) async {
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    try {
      var uri = Uri.parse('https://commercebook.site/api/v1/bill/person/store');

      var request = http.MultipartRequest('POST', uri);

      // ✅ Add form fields
      request.fields.addAll({
        'user_id': userId,
        'name': name,
        'nick_name': nickName,
        'email': email,
        'phone': phone,
        'designation': designation,
        'address': address,
        'date': '2025-07-16', //date //2025-07-25
        'status': '1', //status!
      });

      // ✅ Add avatar image file if provided
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            filename:
                avatarFile.path.split('/').last, // ✅ No path package needed
          ),
        );
      }

      // ✅ Send request
      final response = await request.send();

      debugPrint("📤 Request sent to: $request");
      debugPrint("📡 Status Code: ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      debugPrint("📥 Response Body: $responseBody");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['success'] == true) {
          await fetchBillPersons();
          return true;
        } else {
          errorMessage = data['message'] ?? 'Failed to create bill person.';
          return false;
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e, stacktrace) {
      errorMessage = 'Exception: $e';
      debugPrint(" Exception: $e");
      debugPrint(" Stacktrace:\n$stacktrace");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///bill person update
  Future<bool> updateBillPerson({
    required String id,
    required String userId,
    required String name,
    required String nickName,
    required String email,
    required String phone,
    required String designation,
    required String address,
    required String date,
      String ? status,
    File? avatarFile,
  }) async {
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
          'https://commercebook.site/api/v1/bill/person/update?id=$id');
      var request = http.MultipartRequest('POST', uri);

      final fields = {
        'user_id': userId,
        'name': name,
        'nick_name': nickName,
        'email': email,
        'phone': phone,
        'designation': designation,
        'address': address,
        'date': date,
        'status': '1' //status!,
      };

      request.fields.addAll(fields);

      if (avatarFile != null) {
        final fileName = avatarFile.path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          filename: fileName,
        )); 
      }

      // ✅ Debug logs
      final debugUrlParams = fields.entries
          .map((e) => "${e.key}=${Uri.encodeComponent(e.value)}")
          .join("&");
      debugPrint(
          " FULL API URL: https://commercebook.site/api/v1/bill/person/update?id=$id&$debugUrlParams");

      debugPrint(" Fields Sent:");
      fields.forEach((key, value) => debugPrint("  $key: $value"));

      if (request.files.isNotEmpty) {
        for (var file in request.files) {
          debugPrint(" File Sent: ${file.field} → ${file.filename}");
        }
      } else {
        debugPrint(" No image file sent.");
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      debugPrint(" Status Code: ${response.statusCode}");
      debugPrint(" Response Body: $responseBody");

      final data = json.decode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        await fetchBillPersons();
        return true;
      } else {
        errorMessage =
            data['message']?.toString() ?? ' Failed to update bill person.';
        debugPrint(" Error Message: $errorMessage");
        return false;
      }
    } catch (e) {
      errorMessage = ' Exception: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///designation
  List<DesignationModel> _designations = [];
  List<DesignationModel> get designations => _designations;

  /// For dropdown list
  List<String> get designationNames =>
      _designations.map((e) => e.name).toList();

  List<int> get designationId => _designations.map((e) => e.id).toList();

  /// Fetch designation from API
  Future<void> fetchDesignations() async {
    final url = Uri.parse('https://commercebook.site/api/v1/designation');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        List<dynamic> designationData = data['data'];
        _designations = designationData
            .map<DesignationModel>((item) => DesignationModel.fromJson(item))
            .toList();
      } else {
        _designations = [];
      }
    } catch (e) {
      _designations = [];
    }

    notifyListeners();
  }
}
