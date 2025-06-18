import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/admin_controller.dart';
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
          "Users Management".text.size(24).fontFamily(bold).make(),
          10.heightBox,
          "View and manage all registered users".text.color(darkFontGrey).make(),
          20.heightBox,
          
          Expanded(
            child: _buildUsersTable(),
          ),
        ],
      ),
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
              final joinedDate = (userData['createdAt'] as Timestamp?)?.toDate();
              
              return DataRow(
                cells: [
                 
                  DataCell(Text(userData['name'] ?? 'N/A')),
                 DataCell(SizedBox(
                    width: 100,
                    child: Text(userData['email'] ?? 'N/A', overflow: TextOverflow.ellipsis),
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
                            _showDeleteDialog(context, user.id, userData['name']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                          onPressed: () {
                            _showAdminDialog(context, userData['email'], userData['name']);
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
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: darkFontGrey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                Get.snackbar('Success', 'User deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete user: $e');
              }
            },
            child: Text('Delete', style: TextStyle(color: redColor)),
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
        title: Text('Manage Admin Privileges'),
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
                  return CircularProgressIndicator();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        await adminController.addAdminUser(email, name);
                        Get.back();
                      },
                      child: Text('Make Admin'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await adminController.removeAdmin(email);
                        Get.back();
                      },
                      child: Text('Remove Admin'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}