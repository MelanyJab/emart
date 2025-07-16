import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersTable extends StatelessWidget {
  const UsersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Users Management".text.size(24).fontFamily(bold).make(),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Create User',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _showCreateUserDialog(context),
              ),
            ],
          ),
          10.heightBox,
          "View and manage all registered users"
              .text
              .color(darkFontGrey)
              .make(),
          20.heightBox,
          Expanded(
            child: _buildUsersTable(),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isLoading = false.obs;

    showDialog(
      context: context,
      builder: (context) => Obx(() => AlertDialog(
            title: const Text('Create New User'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
           actions: [
  TextButton(
    onPressed: isLoading.value ? null : () {
      Navigator.of(context, rootNavigator: true).pop(); // Force close modal
    },
    child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
),
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          isLoading.value = true;
                          try {
                            // Create auth user
                            final userCredential =
                                await authController.signupMethod(
                              context: context,
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            if (userCredential != null) {
                              // Store additional user data
                              await authController.storeUserData(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              Get.back();
                              Get.snackbar(
                                'Success',
                                'User created successfully',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Failed to create user: ${e.toString()}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } finally {
                            isLoading.value = false;
                          }
                        }
                      },
                child: isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Create',
                        style: TextStyle(color: Colors.green)),
              ),
            ],
          )),
    );
  }

  Widget _buildUsersTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Joined')),
              DataColumn(label: Text('Actions')),
            ],
            rows: users.map((user) {
              final userData = user.data() as Map<String, dynamic>;
              final joinedDate =
                  (userData['createdAt'] as Timestamp?)?.toDate();

              return DataRow(
                cells: [
                  DataCell(Text(userData['name'] ?? 'N/A')),
                  DataCell(SizedBox(
                    width: 100,
                    child: Text(userData['email'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(Text(joinedDate != null
                      ? '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}'
                      : 'N/A')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(
                                context, user.id, userData['name']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.admin_panel_settings,
                              color: Colors.blue),
                          onPressed: () {
                            _showAdminDialog(
                                context, userData['email'], userData['name']);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $userName?'),
        content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () =>  Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
                Get.snackbar('Success', 'User deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete user: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }

  void _showAdminDialog(BuildContext context, String email, String name) {
    final adminController = Get.find<AdminController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Admin Privileges'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: $email'),
            Text('Name: $name'),
            10.heightBox,
            FutureBuilder<bool>(
              future: adminController.isCurrentUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () async {
                        await adminController.addAdminUser(email, name);
                        Get.back();
                      },
                      child: const Text('Make Admin'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await adminController.removeAdmin(email);
                        Get.back();
                      },
                      child: const Text('Remove Admin'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>   Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
