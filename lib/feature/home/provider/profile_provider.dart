import 'dart:convert';

import 'package:cbook_dt/feature/home/model/user_profile.dart';
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

    try {
      final response = await http
          .get(Uri.parse('https://commercebook.site/api/v1/profile/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        profile = ProfileResponse.fromJson(data).data;
        debugPrint("Profile fetched successfully: ${profile!.name}");

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
}
