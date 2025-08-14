import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/settings/model/model_user_setting.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/role_model.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/user_create_model.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/user_edit_model.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingUserProvider with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nickController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confromController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  List<SetingsUserModel> _users = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<SetingsUserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError; // 👈 Add this line

  ///fetch user
  Future<void> fetchUsers() async {
    _isLoading = true;
    _hasError = false; // reset error before fetching
    notifyListeners();

    final url = '${AppUrl.baseurl}users/list/';
    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _hasError = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      final response = await http.get(Uri.parse(url,
      
      
      ),
      
      headers: {

        "Authorization": "Bearer $token",
        "Accept": "application/json",

      }
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List usersJson = data['data'];
        _users = usersJson.map((e) => SetingsUserModel.fromJson(e)).toList();
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }




  ///delete user
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ///delete user
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final url = Uri.parse('${AppUrl.baseurl}users/remove/$id');

    try {
      final response = await http.post(url); // or POST if backend expects POST

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _users.removeWhere((user) => user.id == id);
          notifyListeners();
          debugPrint("✅ User deleted successfully.");
          return true;
        } else {
          _errorMessage = data['message'] ?? "Failed to delete user.";
          debugPrint("❌ $errorMessage");
          return false;
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
        debugPrint("❌ $_errorMessage");
        return false;
      }
    } catch (e) {
      _errorMessage = "Exception: $e";
      debugPrint("❌ $_errorMessage");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///create user.
  Future<UserCreateResponseModel?> createUser({
    required String userType,
    required String name,
    required String nickName,
    required String email,
    required String phone,
    required String password,
    required String designation,
    required String billPersonId,
    required String defaultBillPersonId,
    required String address,
    required String createdDate,
    required String status,
    String? avatarPath,
    String? signaturePath,
  }) async {
    final url = Uri.parse('${AppUrl.baseurl}users/store');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'user_type': userType,
        'name': name,
        'nick_name': nickName,
        'email': email,
        'phone': phone,
        'password': password,
        'designation': designation,
        'bill_person': billPersonId,
        'default_bill_person': defaultBillPersonId,
        'address': address,
        'created_date': createdDate,
        'status': status,
      });

      // request.files
      //     .add(await http.MultipartFile.fromPath('avatar', avatarPath));
      // request.files
      //     .add(await http.MultipartFile.fromPath('singture', signaturePath));

      // ✅ Only add avatar if available
      if (avatarPath != null && avatarPath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('avatar', avatarPath));
      }

      // ✅ Only add signature if available
      if (signaturePath != null && signaturePath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('singture', signaturePath));
      }

      final response = await request.send();

      debugPrint("Sending user create request with:");
      request.fields.forEach((key, value) {
        debugPrint("🟩 $key: $value");
      });
      debugPrint("Avatar path: $avatarPath");
      debugPrint("Signature path: $signaturePath");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        return UserCreateResponseModel.fromJson(decoded);
      } else {
        debugPrint("❌ Failed: ${response.statusCode} ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception during user creation: $e");
      return null;
    }
  }

  ///edit user data
  UserEditModel? _editUser;
  bool _isEditLoading = false;
  String? _editError;

  UserEditModel? get editUser => _editUser;
  bool get isEditLoading => _isEditLoading;
  String? get editError => _editError;

  ///fetch user by id
  Future<void> fetchUserById(int userId) async {
    _isEditLoading = true;
    _editError = null;
    notifyListeners();

    final url =
        Uri.parse('${AppUrl.baseurl}users/edit/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        _editUser = UserEditModel.fromJson(data);
      } else {
        _editError = "Failed to fetch user: ${response.statusCode}";
      }
    } catch (e) {
      _editError = "Exception occurred: $e";
    }

    _isEditLoading = false;
    notifyListeners();
  }

  
  ///user update
  Future<Map<String, dynamic>> updateUser({
    required int id,
    required String userType,
    //required int roleId,
    required int designation,
    required String password,
    required String billPersonIds,
    required int defaultBillPerson,
    required String status,
    required String createdDate,
    XFile? avatar,
    XFile? signature,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppUrl.baseurl}users/update?id=$id&user_type=$userType',
      );

      final request = http.MultipartRequest('POST', uri);

      // Define fields
      final fields = {
        'id': id.toString(),
        'user_type': userType,
        //'role_id': roleId.toString(),
        'name': nameController.text.trim(),
        'nick_name': nickController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': password,
        'designation': designation.toString(),
        'bill_person': billPersonIds,
        'default_bill_person': defaultBillPerson.toString(),
        'address': addressController.text.trim(),
        'created_date': createdDate,
        'status': status,
      };

      request.fields.addAll(fields);

      // Add files if available
      if (avatar != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          File(avatar.path).path,
        ));
      }

      if (signature != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'singture',
          File(signature.path).path,
        ));
      }

      // ✅ PRINT FULL INFO BEFORE SENDING
      debugPrint('📤 Sending request to: ${request.url}');
      debugPrint('📦 Form Fields:');
      fields.forEach((key, value) {
        debugPrint('  $key = $value');
      });

      if (avatar != null) {
        debugPrint('🖼️ Avatar path: ${avatar.path}');
      }
      if (signature != null) {
        debugPrint('✍️ Signature path: ${signature.path}');
      }

      // Send request
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      // ✅ Print Response
      debugPrint('📩 Status Code: ${response.statusCode}');
      debugPrint('📩 Response Body: $resBody');

      if (response.statusCode == 200) {
        final jsonData = json.decode(resBody);
        return {
          'success': jsonData['success'],
          'message': jsonData['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  ///role mnodel.
  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;

  ///roles
  Future<void> fetchRoles() async {
    final url = '${AppUrl.baseurl}roles/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rolesJson = data['data'];
        _roles = rolesJson.map((e) => RoleModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        debugPrint("❌ Failed to fetch roles: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching roles: $e");
    }
  }
}
