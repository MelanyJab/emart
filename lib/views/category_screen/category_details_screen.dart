// views/category_screen/category_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/views/category_screen/item_details.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryId;
  final String? title;
  
  const CategoryDetailsScreen({
    Key? key, 
    required this.categoryId,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: title!.text.fontFamily(bold).white.make(),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Subcategories could go here if needed
              20.heightBox,
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('categoryId', isEqualTo: categoryId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: const Text('Error loading products'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data!.docs;

                    if (products.isEmpty) {
                      return Center(
                        child: "No products in this category yet".text.make(),
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: products.length,
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 250,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final productData = product.data() as Map<String, dynamic>;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TODO: Replace with actual product image
                            Image.network(
                              productData['imageUrl'] ?? 'assets/images/s1.jpg',
                              height: 150,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              productData['name'] ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontFamily: semibold,
                                color: darkFontGrey,
                              ),
                            ),
                            10.heightBox,
                            Text(
                              "\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(
                                color: redColor,
                                fontFamily: bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                            .box
                            .white
                            .margin(const EdgeInsets.symmetric(horizontal: 4))
                            .roundedSM
                            .outerShadowSm
                            .padding(const EdgeInsets.all(12))
                            .make()
                            .onTap(() {
                              Get.to(() => ItemDetails(
                                productId: product.id,
                                title: productData['name'],
                              ));
                            });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}