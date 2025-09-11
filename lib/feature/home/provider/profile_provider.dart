import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/authentication/model/country_response_model.dart';
import 'package:cbook_dt/feature/home/model/user_profile.dart';
import 'package:cbook_dt/feature/settings/ui/company_information/model/company_update_model.dart';
import 'package:cbook_dt/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileProvider with ChangeNotifier {
  
  UserProfile? profile;
  bool isLoading = false;
  String errorMessage = '';

  /// Load profile from SharedPreferences or fetch from API
  Future<void> fetchProfileFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedProfile = prefs.getString('cached_profile');

    if (cachedProfile != null) {
      // Load saved profile
      profile = UserProfile.fromJson(json.decode(cachedProfile));
      notifyListeners();
      debugPrint("Loaded profile from SharedPreferences.");
    }

    // Fetch from API only if no cached data
    int? userId = prefs.getInt('user_id');
    if (userId != null && cachedProfile == null) {
      await fetchProfile(userId);
    }
  }

  /// Fetch profile from API and save to SharedPreferences
  Future<void> fetchProfile(int userId) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      errorMessage = 'No token found. Please login again.';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}profile/$userId'),
         
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        profile = ProfileResponse.fromJson(data).data;
        //debugPrint("Profile fetched successfully: ${profile!.name}");

        // Save profile in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_profile', json.encode(profile!.toJson()));
      } else {
        errorMessage = "Failed to fetch profile: ${response.statusCode}";
        debugPrint(errorMessage);
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  CompanyProfileUpdate? updateprofile;

  // Update profile
  /// Update profile via API
  // Future<bool> updateProfile({
  //   required int userId,
  //   required String companyName,
  //   required String email,
  //   required String phone,
  //   required String currency,
  //   required String name,
  //   required String nickName,
  //   required String address,
  //   required int countryId,
  //   File? avatar,
  //   File? logo,
  //   File? signature,
  // }) async {
  //   final uri = Uri.parse("${AppUrl.baseurl}profile/update");

  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');

  //   var request = http.MultipartRequest(
  //     'POST',
  //     uri,
  //   );

  //   request.fields.addAll({
  //     'user_id': userId.toString(),
  //     'company_name': companyName,
  //     'country_id': countryId.toString(),
  //     'currency': currency,
  //     'email': email,
  //     'phone': phone,
  //     'address': address,
  //     'name': name,
  //     'nick_name': nickName,
  //   });

  //   if (avatar != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath('avatar', avatar.path));
  //   }
  //   if (logo != null) {
  //     request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
  //   }
  //   if (signature != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath('singture', signature.path));
  //   }

  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     debugPrint('Url === $response');

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       if (responseData['success'] == true) {
  //         updateprofile = CompanyProfileUpdate.fromJson(responseData['data']);

  //         // Save updated profile
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         prefs.setString('cached_profile', json.encode(profile!.toJson()));

  //         notifyListeners();
  //         return true;
  //       } else {
  //         errorMessage = responseData['message'] ?? "Unknown error";
  //         debugPrint("Update failed: $errorMessage");
  //       }
  //     } else {
  //       debugPrint(
  //           "Failed to update profile. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     debugPrint("Update profile error: $e");
  //   }

  //   return false;
  // }

  
  Future<bool> updateProfile({
  required int userId,
  required String companyName,
  required String email,
  required String phone,
  required String currency,
  required String name,
  required String nickName,
  required String address,
  required int countryId,
  File? avatar,
  File? logo,
  File? signature,
}) async {
  final uri = Uri.parse("${AppUrl.baseurl}profile/update");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    errorMessage = 'No token found. Please login again.';
    isLoading = false;
    notifyListeners();
    return false;
  }

  var request = http.MultipartRequest('POST', uri);

  // Add headers with token
  request.headers.addAll({
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  });

  request.fields.addAll({
    'user_id': userId.toString(),
    'company_name': companyName,
    'country_id': countryId.toString(),
    'currency': currency,
    'email': email,
    'phone': phone,
    'address': address,
    'name': name,
    'nick_name': nickName,
  });

  if (avatar != null) {
    request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
  }
  if (logo != null) {
    request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
  }
  if (signature != null) {
    request.files.add(await http.MultipartFile.fromPath('signature', signature.path));
  }

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Response === ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        updateprofile = CompanyProfileUpdate.fromJson(responseData['data']);

        // Save updated profile locally
        //prefs.setString('cached_profile', json.encode(updateprofile!.toJson()));

        notifyListeners();
        return true;
      } else {
        errorMessage = responseData['message'] ?? "Unknown error";
        debugPrint("Update failed: $errorMessage");
      }
    } else {
      debugPrint("Failed to update profile. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Update profile error: $e");
  }

  return false;
}





  ////country provider

  List<Country> countries = [];

  Future<void> fetchCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      errorMessage = 'No token found. Please login again.';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppUrl.baseurl}country/list'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> countryList = data['data'];
        countries = countryList.map((json) => Country.fromJson(json)).toList();
        notifyListeners();
      } else {
        debugPrint('Failed to load countries');
      }
    } catch (e) {
      debugPrint('Error loading countries: $e');
    }
  }

  /// Helper to get country name by ID
  String getCountryNameById(int? id) {
    try {
      final country = countries.firstWhere((c) => c.id == id);
      return country.name;
    } catch (e) {
      return '';
    }
  }
}
