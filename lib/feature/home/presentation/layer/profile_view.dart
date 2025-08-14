import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/conformation_alart.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:cbook_dt/feature/authentication/provider/login_provider.dart';
import 'package:cbook_dt/feature/home/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int? userID;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchProfile();
  }

  Future<void> _loadUserIdAndFetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      setState(() {
        userID = userId;
      });

      // Call fetchProfile after userId is loaded
      Provider.of<ProfileProvider>(context, listen: false)
          .fetchProfile(userID!);
    } else {
      // Handle null userId
      debugPrint('User ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // ← makes back icon white
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.profile != null) {
                final user = provider.profile!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage: (user.avatar != null &&
                                      user.avatar!.isNotEmpty)
                                  ? NetworkImage(
                                      "https://commercebook.site/${user.avatar}")
                                  : const AssetImage(
                                          'assets/image/cbook_logo.png')
                                      as ImageProvider,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        user.nickName,
                        style: const TextStyle(color: Colors.black),
                      ),

                      // User Details
                      _buildInfoCard(Icons.phone, "Phone",

                          user.phone ?? "No phone number"),

                      GestureDetector(
                        onTap: () {
                          deleteAccount();
                        },
                        child: _buildInfoCard(
                            Icons.delete, "Delete", "Delete your account"),
                      ),

                      const SizedBox(height: 20),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            logoutAccount(context);
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    provider.errorMessage.isNotEmpty
                        ? provider.errorMessage
                        : "No profile data found",
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          subtitle: Text(value,
              style: const TextStyle(color: Colors.black87, fontSize: 12)),
        ),
      ),
    );
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: "Confirm Deletion",
          content: "Are you sure you want to delete this account?",
          onConfirm: () async {},
          titleBottomRight: 'Delete',
        );
      },
    );
  }

  void logoutAccount(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: "Logout",
          content: "Are you sure you want to logout?",
          onConfirm: () async {
            final loginProvider =
                Provider.of<LoginProvider>(context, listen: false);
            await loginProvider.logout();

            // Navigate to the login screen after logout
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ComapnyLogin()),
              (route) => false, // Remove all previous routes from the stack
            );
          },
          titleBottomRight: 'Logout',
        );
      },
    );
  }
}
