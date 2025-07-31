import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_add.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_details.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_provider/user_provider.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCeate extends StatelessWidget {
  const UserCeate({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final userSettingProvider = Provider.of<SettingUserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // ignore: prefer_const_constructors
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const Text(
              'User',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UserAdd()));
              },
              child: const 
              Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    'Add user',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: userSettingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userSettingProvider.hasError
              ? const Center(
                  child: Text(
                  "Something went wrong.",
                  style: TextStyle(color: Colors.black),
                ))
              : userSettingProvider.users.isEmpty
                  ? const Center(
                      child: Text(
                      "No user found.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ))
                  : ListView.builder(
                      itemCount: userSettingProvider.users.length,
                      itemBuilder: (ctx, index) {
                        final user = userSettingProvider.users[index];

                        final userId = userSettingProvider.users[index].id;

                        return InkWell(
                          onLongPress: () {
                            editDeleteDiolog(context, userId);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsPage(user: user),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  backgroundImage: user.avatar != null
                                      ? NetworkImage(
                                          'https://commercebook.site/${user.avatar}')
                                      : const AssetImage(
                                              'assets/images/avatar_placeholder.png')
                                          as ImageProvider,
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user.nickName != null)
                                    Text(user.nickName!,
                                        style: const TextStyle(fontSize: 12)),
                                  Text(user.email,
                                      style: const TextStyle(fontSize: 12)),
                                  Text(user.phone,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  ///edit and delete pop up.
  Future<dynamic> editDeleteDiolog(BuildContext context, int userId) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjust side padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Height as per content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                              color: Colors.grey,
                              width: 1), // Border color and width
                          borderRadius: BorderRadius.circular(
                              50), // Corner radius, adjust as needed
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary, // Use your color
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    //Navigate to Edit Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserUpdate(userId: userId),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, userId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///delete bill person.
  void _showDeleteDialog(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete User',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this user?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog

              final provider = Provider.of<SettingUserProvider>(
                context,
                listen: false,
              );

              final success = await provider.deleteUser(userId);

              provider.fetchUsers();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User deleted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
