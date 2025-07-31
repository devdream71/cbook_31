import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/conformation_alart.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:cbook_dt/feature/authentication/provider/login_provider.dart';
import 'package:cbook_dt/feature/home/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.profile != null) {
            final user = provider.profile!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user.avatar != null
                              ? NetworkImage(user.avatar!)
                              : const AssetImage(
                                      'assets/image/cbook_logo.png') //assets\image\cbook_logo.png
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  const SizedBox(height: 10),

                  // User Details
                  Column(
                    children: [
                      _buildInfoCard(Icons.phone, "Phone",
                          user.phone ?? "No phone number"),
                      _buildInfoCard(Icons.badge, "User Type",
                          user.userType.toUpperCase()),
                      //_buildInfoCard(Icons.verified, "Verification Code", user.varificationCode),
                      _buildInfoCard(Icons.access_time, "Created At",
                          user.createdAt.split("T")[0]),
                  
                      GestureDetector(
                        onTap: () {
                          deleteAccount();
                        },
                        child: _buildInfoCard(
                            Icons.delete, "Delete", "Delete your account"),
                      ),
                    ],
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
