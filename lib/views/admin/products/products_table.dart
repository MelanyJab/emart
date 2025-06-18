import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsTable extends StatefulWidget {

  ProductsTable({Key? key}) : super(key: key);

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  final AdminController _adminController = Get.find();

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
              "Products Management".text.size(24).fontFamily(bold).make(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: redColor),
                onPressed: () => _showAddProductDialog(context),
                child: "Add Product".text.white.make(),
              ),
            ],
          ),
          10.heightBox,
          "View and manage all products".text.color(darkFontGrey).make(),
          20.heightBox,
          
          Expanded(
            child: _buildProductsTable(),
          ),
        ],
      ),
    );
  }

 Widget _buildProductsTable() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('products').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final products = snapshot.data!.docs;

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
             
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: products.map((product) {
              final productData = product.data() as Map<String, dynamic>;
              return DataRow(
                cells: [
              
                  DataCell(Text(productData['name'] ?? 'N/A')),
                  DataCell(Text('\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}')),
                  DataCell(
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('categories')
                          .doc(productData['categoryId'])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final category = snapshot.data!.data() as Map<String, dynamic>;
                          return Text(category['name'] ?? 'N/A');
                        }
                        return const Text('Loading...');
                      },
                    ),
                  ),
                  DataCell(Text('${productData['rating']?.toStringAsFixed(1) ?? '0.0'}')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(context, product.id, productData),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, product.id, productData['name']),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}

  void _showAddProductDialog(BuildContext context) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? selectedCategoryId;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Product Name Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Price Field
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final categories = snapshot.data!.docs;
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          hint: const Text('Select Category'),
                          items: categories.map((category) {
                            final data = category.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(data['name'] ?? 'Unnamed Category'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: darkFontGrey)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        if (nameController.text.isEmpty || 
                            descriptionController.text.isEmpty || 
                            priceController.text.isEmpty ||
                            selectedCategoryId == null) {
                          Get.snackbar('Error', 'Please fill all fields');
                          return;
                        }
                        
                        final price = double.tryParse(priceController.text) ?? 0.0;
                        
                        Navigator.pop(context);
                        await _adminController.addProduct(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: price,
                          imageUrl: 'assets/images/placeholder.png',
                          categoryId: selectedCategoryId!,
                        );
                      },
                      child: const Text('Add Product', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _showEditDialog(BuildContext context, String productId, Map<String, dynamic> productData) {
    final nameController = TextEditingController(text: productData['name']);
    final descriptionController = TextEditingController(text: productData['description']);
    final priceController = TextEditingController(text: productData['price']?.toString());
    String? selectedCategoryId = productData['categoryId'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: "Edit Product".text.make(),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  10.heightBox,
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  10.heightBox,
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  10.heightBox,
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final categories = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          final data = category.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(data['name']),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedCategoryId = value),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: "Cancel".text.color(darkFontGrey).make(),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || 
                      descriptionController.text.isEmpty || 
                      priceController.text.isEmpty ||
                      selectedCategoryId == null) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }
                  
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  
                  Get.back();
                  await _adminController.updateProduct(
                    productId: productId,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    price: price,
                    categoryId: selectedCategoryId!,
                  );
                },
                child: "Save".text.color(redColor).make(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $productName?'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: "Cancel".text.color(darkFontGrey).make(),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _adminController.deleteProduct(productId);
                Get.snackbar('Success', 'Product deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete product: $e');
              }
            },
            child: "Delete".text.color(redColor).make(),
          ),
        ],
      ),
    );
  }
}