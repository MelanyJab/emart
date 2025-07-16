import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({Key? key}) : super(key: key);

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  final AdminController _adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: redColor),
                  onPressed: () => _showAddProductDialog(context),
                  child: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'View and manage all products',
              style: const TextStyle(color: darkFontGrey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildProductsTable(),
            ),
          ],
        ),
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
                DataColumn(
                    label: Text('Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Price',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Sale',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                
                DataColumn(
                    label: Text('Actions',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: products.map((product) {
                final productData = product.data() as Map<String, dynamic>;
                final price = (productData['price'] as num?)?.toDouble() ?? 0.0;
                final sale = (productData['sale'] as num?)?.toDouble();
                final salePrice =
                    sale != null ? price * (1 - (sale / 100)) : null;

                return DataRow(
                  cells: [
                    DataCell(Text(productData['name'] ?? 'N/A')),
                    DataCell(
                      salePrice != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '\$${salePrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text('\$${price.toStringAsFixed(2)}'),
                    ),
                    DataCell(
                      sale != null
                          ? Chip(
                              label: Text('${sale.toStringAsFixed(0)}%'),
                              backgroundColor: Colors.red.withOpacity(0.2),
                              labelStyle: TextStyle(color: Colors.red),
                            )
                          : const Text('N/A'),
                    ),
                    DataCell(
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('categories')
                            .doc(productData['categoryId'])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final category =
                                snapshot.data!.data() as Map<String, dynamic>;
                            return Text(category['name'] ?? 'N/A');
                          }
                          return const Text('Loading...');
                        },
                      ),
                    ),
                  
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(
                                context, product.id, productData),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(
                                context, product.id, productData['name']),
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
    final saleController = TextEditingController();
    List<String> selectedCategoryIds = []; // Changed from selectedCategoryId
    List<String> selectedColors = [];
    bool isSaleEnabled = false;

    final List<String> availableColors = [
      'red',
      'blue',
      'green',
      'yellow',
      'black',
      'white',
      'purple',
      'orange',
      'pink',
      'brown'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                          labelText: 'Product Name*',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description*',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Price Field
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price*',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Color Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Colors',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableColors.map((color) {
                              return FilterChip(
                                label: Text(
                                  color,
                                  style: TextStyle(
                                    color: selectedColors.contains(color)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                selected: selectedColors.contains(color),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedColors.add(color);
                                    } else {
                                      selectedColors.remove(color);
                                    }
                                  });
                                },
                                selectedColor: _getColorFromString(color),
                                backgroundColor: Colors.grey[200],
                                checkmarkColor: Colors.white,
                                showCheckmark: true,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Selection (now multi-select)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categories')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final categories = snapshot.data!.docs;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Categories*',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories.map((category) {
                                  final data =
                                      category.data() as Map<String, dynamic>;
                                  final categoryName =
                                      data['name'] ?? 'Unnamed Category';
                                  return FilterChip(
                                    label: Text(categoryName),
                                    selected: selectedCategoryIds
                                        .contains(category.id),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedCategoryIds.add(category.id);
                                        } else {
                                          selectedCategoryIds
                                              .remove(category.id);
                                        }
                                      });
                                    },
                                    selectedColor: Colors.blue,
                                    backgroundColor: Colors.grey[200],
                                    checkmarkColor: Colors.white,
                                    showCheckmark: true,
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sale Percentage Field (now truly optional)
                      TextField(
                        controller: saleController,
                        decoration: const InputDecoration(
                          labelText: 'Sale Percentage (optional)',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                          hintText: 'Enter discount percentage if applicable',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      if (priceController.text.isNotEmpty &&
                          saleController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Sale Price: \$${_calculateSalePrice(priceController.text, saleController.text)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>   Navigator.of(context, rootNavigator: true).pop(),
                            child: const Text('Cancel',
                                style: TextStyle(color: darkFontGrey)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: redColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () async {
                              if (nameController.text.isEmpty ||
                                  descriptionController.text.isEmpty ||
                                  priceController.text.isEmpty ||
                                  selectedCategoryIds.isEmpty) {
                                // Changed check
                                Get.snackbar(
                                    'Error', 'Please fill all required fields');
                                return;
                              }

                              final price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final sale = saleController.text.isNotEmpty
                                  ? double.tryParse(saleController.text)
                                  : null;

                              if (saleController.text.isNotEmpty &&
                                  sale == null) {
                                Get.snackbar('Error',
                                    'Please enter a valid sale percentage');
                                return;
                              }

                              Navigator.pop(context);
                              await _adminController.addProduct(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                price: price,
                                imageUrl: 'assets/images/placeholder.png',
                                categoryIds:
                                    selectedCategoryIds, // Changed from categoryId
                                colors: selectedColors,
                                sale: sale,
                              );
                            },
                            child: const Text('Add Product',
                                style: TextStyle(color: Colors.white)),
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
      },
    );
  }

// Add these helper methods to your _ProductsTableState class
  String _calculateSalePrice(String price, String percentage) {
    try {
      final priceValue = double.tryParse(price) ?? 0;
      final percentageValue = double.tryParse(percentage) ?? 0;
      if (priceValue <= 0 || percentageValue <= 0) return '0.00';
      final salePrice = priceValue * (1 - (percentageValue / 100));
      return salePrice.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context, String productId, Map<String, dynamic> productData) {
  final nameController = TextEditingController(text: productData['name']);
  final descriptionController = TextEditingController(text: productData['description']);
  final priceController = TextEditingController(text: productData['price']?.toString());
  final saleController = TextEditingController(text: productData['sale']?.toString());
  List<String> selectedCategoryIds = List<String>.from(productData['categoryIds'] ?? []);
  List<String> selectedColors = List<String>.from(productData['colors'] ?? []);

  final List<String> availableColors = [
    'red', 'blue', 'green', 'yellow', 'black', 
    'white', 'purple', 'orange', 'pink', 'brown'
  ];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit Product',
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
                        labelText: 'Product Name*',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description*',
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
                        labelText: 'Price*',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Color Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Colors',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableColors.map((color) {
                            return FilterChip(
                              label: Text(
                                color,
                                style: TextStyle(
                                  color: selectedColors.contains(color) 
                                      ? Colors.white 
                                      : Colors.black,
                                ),
                              ),
                              selected: selectedColors.contains(color),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedColors.add(color);
                                  } else {
                                    selectedColors.remove(color);
                                  }
                                });
                              },
                              selectedColor: _getColorFromString(color),
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                              showCheckmark: true,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category Selection (multi-select)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final categories = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categories*',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categories.map((category) {
                                final data = category.data() as Map<String, dynamic>;
                                final categoryName = data['name'] ?? 'Unnamed Category';
                                return FilterChip(
                                  label: Text(categoryName),
                                  selected: selectedCategoryIds.contains(category.id),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedCategoryIds.add(category.id);
                                      } else {
                                        selectedCategoryIds.remove(category.id);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.grey[200],
                                  checkmarkColor: Colors.white,
                                  showCheckmark: true,
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sale Percentage Field (optional)
                    TextField(
                      controller: saleController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Percentage (optional)',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                        hintText: 'Enter discount percentage if applicable',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                    if (priceController.text.isNotEmpty && saleController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Sale Price: \$${_calculateSalePrice(priceController.text, saleController.text)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>  Navigator.of(context, rootNavigator: true).pop(),
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
                                selectedCategoryIds.isEmpty) {
                              Get.snackbar('Error', 'Please fill all required fields');
                              return;
                            }
                            
                            final price = double.tryParse(priceController.text) ?? 0.0;
                            final sale = saleController.text.isNotEmpty
                                ? double.tryParse(saleController.text)
                                : null;
                            
                            if (saleController.text.isNotEmpty && sale == null) {
                              Get.snackbar('Error', 'Please enter a valid sale percentage');
                              return;
                            }
                            
                            Navigator.pop(context);
                            await _adminController.updateProduct(
                              productId: productId,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              price: price,
                              categoryIds: selectedCategoryIds,
                              colors: selectedColors,
                              sale: sale,
                            );
                          },
                          child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
    },
  );
}
  void _showDeleteDialog(
      BuildContext context, String productId, String productName) {
    final isLoading = false.obs;

    showDialog(
      context: context,
      builder: (context) {
        return Obx(() {
          return AlertDialog(
            title: Text('Delete $productName?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to delete this product?'),
                if (isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading.value ? null : () =>   Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;
                        try {
                          await _adminController.deleteProduct(productId);
                          if (mounted) {
                            Navigator.pop(context);
                            // Refresh the product list
                            setState(() {});
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete: ${e.toString()}')),
                            );
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
      },
    );
  }
}
