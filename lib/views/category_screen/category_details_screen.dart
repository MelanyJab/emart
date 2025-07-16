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
  onPressed: () {
   
    // Fallback to Flutter navigation
   if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Final fallback
    else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  },
  icon: Icon(Icons.arrow_back),
),
          title: title!.text.fontFamily(bold).white.make(),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              20.heightBox,
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('categoryIds', arrayContains: categoryId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading products'));
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
                        
                        // Check if product is on sale
                        final isOnSale = productData['sale'] != null;
                        final originalPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;
                        final salePercent = (productData['sale'] as num?)?.toDouble();
                        final salePrice = salePercent != null 
                            ? originalPrice * (1 - (salePercent / 100))
                            : null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                // Updated image widget with placeholder
                                productData['imageUrl'] == null || productData['imageUrl'].isEmpty
                                    ? Container(
                                        height: 150,
                                        width: 200,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image, size: 50, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            "No Image".text.color(Colors.grey[600]).make(),
                                          ],
                                        ),
                                      )
                                    : Image.network(
                                        productData['imageUrl'],
                                        height: 150,
                                        width: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 150,
                                            width: 200,
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                                                const SizedBox(height: 8),
                                                "Image Error".text.color(Colors.grey[600]).make(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                if (isOnSale)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      color: Colors.red,
                                      child: Text(
                                        '${salePercent?.toStringAsFixed(0)}% OFF',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              productData['name'] ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontFamily: semibold,
                                color: darkFontGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            10.heightBox,
                            if (isOnSale)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${originalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: regular,
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    '\$${salePrice?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const TextStyle(
                                      color: redColor,
                                      fontFamily: bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '\$${originalPrice.toStringAsFixed(2)}',
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