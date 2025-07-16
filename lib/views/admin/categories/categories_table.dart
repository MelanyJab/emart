import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesTable extends StatelessWidget {
  final AdminController _adminController = Get.find();

  CategoriesTable({Key? key}) : super(key: key);

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
              "Categories Management".text.size(24).fontFamily(bold).make(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: redColor),
                onPressed: () => _showAddCategoryDialog(context),
                child: "Add Category".text.white.make(),
              ),
            ],
          ),
          10.heightBox,
          "View and manage all product categories".text.color(darkFontGrey).make(),
          20.heightBox,
          
          Expanded(
            child: _buildCategoriesTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
            
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Created At')),
              DataColumn(label: Text('Actions')),
            ],
            rows: categories.map((category) {
              final categoryData = category.data() as Map<String, dynamic>;
              final createdAt = (categoryData['createdAt'] as Timestamp).toDate();
              
              return DataRow(
                cells: [
                
                  DataCell(Text(categoryData['name'] ?? 'N/A')),
                  DataCell(Text('${createdAt.day}/${createdAt.month}/${createdAt.year}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(
                              context, 
                              category.id, 
                              categoryData['name']
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(context, category.id, categoryData['name']);
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

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            10.heightBox,
            // TODO: Add image upload functionality later
          
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter a category name');
                return;
              }
              
              Get.back();
              await _adminController.addCategory(
                nameController.text.trim(),
                'assets/images/s1.jpg', // Placeholder image
              );
            },
            child: const Text('Add', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>   Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter a category name');
                return;
              }
              
              Get.back();
              await _adminController.updateCategory(id, nameController.text.trim());
            },
            child: const Text('Save', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $name?'),
        content: const Text('Are you sure you want to delete this category? This will not delete products in this category.'),
        actions: [
          TextButton(
            onPressed: () =>   Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _adminController.deleteCategory(id);
                Get.snackbar('Success', 'Category deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete category: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }
}