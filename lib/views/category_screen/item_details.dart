import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/consts/lists.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ItemDetails extends StatefulWidget {
  final String productId;
  final String? title;
  const ItemDetails({Key? key, required this.title, required this.productId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int selectedColorIndex = 0;
  int quantity = 0;
  bool isFavorite = false;
  ProductModel? product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    
    if (doc.exists) {
      setState(() {
        product = ProductModel.fromMap(doc.data()!, doc.id);
      });
    }
  }

  void _showShareModal() {
    String shareLink = "https://emart.com/product/${product?.id}";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                "Share Product".text.fontFamily(bold).size(18).color(darkFontGrey).make(),
                20.heightBox,
                "Copy the link below to share this product:".text.color(darkFontGrey).make(),
                15.heightBox,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkFontGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: darkFontGrey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: shareLink.text.size(12).color(darkFontGrey).make(),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareLink));
                          Get.snackbar(
                            "Copied!",
                            "Link copied to clipboard",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: darkFontGrey,
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                      ),
                    ],
                  ),
                ),
                20.heightBox,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: "Close".text.white.fontFamily(bold).make(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(
        backgroundColor: lightGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: darkFontGrey),
        ),
        actions: [
          IconButton(
            onPressed: _showShareModal,
            icon: const Icon(Icons.share, color: darkFontGrey),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : darkFontGrey,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
       body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkFontGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        product!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.image_not_supported, size: 100, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  20.heightBox,

                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      product!.name.text.size(18).fontFamily(bold).color(darkFontGrey).make(),
                      10.heightBox,
                      Row(
                        children: [
                          VxRating(
                            onRatingUpdate: (value) {},
                            normalColor: darkFontGrey,
                            selectionColor: golden,
                            count: 5,
                            size: 20,
                            stepInt: true,
                            value: product!.rating,
                          ),
                          10.widthBox,
                          "(${product!.rating.toStringAsFixed(1)})".text.color(darkFontGrey).make(),
                        ],
                      ),
                      15.heightBox,
                      "\$${product!.price.toStringAsFixed(2)}"
                          .text.color(redColor).fontFamily(bold).size(20).make(),
                    ],
                  ),

                  // Color Selection
                  20.heightBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Color:".text.color(darkFontGrey).make(),
                      10.heightBox,
                      Wrap(
                        spacing: 8,
                        children: List.generate(
                          product!.colors.length,
                          (index) => GestureDetector(
                            onTap: () => setState(() => selectedColorIndex = index),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getColorFromString(product!.colors[index]),
                                shape: BoxShape.circle,
                                border: selectedColorIndex == index
                                    ? Border.all(color: Colors.blue, width: 3)
                                    : null,
                              ),
                              child: selectedColorIndex == index
                                  ? const Icon(Icons.check, color: darkFontGrey, size: 20)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quantity
                  20.heightBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Quantity:".text.color(darkFontGrey).make(),
                      10.heightBox,
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => quantity = quantity > 0 ? quantity - 1 : 0),
                            icon: const Icon(Icons.remove),
                          ),
                          "$quantity".text.size(16).fontFamily(bold).make(),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add),
                          ),
                          const Spacer(),
                          "Total: \$${(product!.price * quantity).toStringAsFixed(2)}"
                              .text.color(redColor).fontFamily(bold).make(),
                        ],
                      ),
                    ],
                  ),

                  // Description
                  20.heightBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Description".text.fontFamily(bold).color(darkFontGrey).make(),
                      10.heightBox,
                      product!.description.text.color(darkFontGrey).make(),
                    ],
                  ),

                  // Features
                  20.heightBox,
                  Column(
                    children: itemDetailButtonsList.map((item) => ListTile(
                      title: item.text.fontFamily(semibold).color(darkFontGrey).make(),
                      trailing: const Icon(Icons.arrow_forward),
                    )).toList(),
                  ),

                  // Related Products
                  20.heightBox,
                  "You may also like".text.fontFamily(bold).size(16).color(darkFontGrey).make(),
                  10.heightBox,
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) => Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(imgP1, height: 120, width: 150, fit: BoxFit.cover),
                            10.heightBox,
                            "Product $index".text.fontFamily(semibold).color(darkFontGrey).make(),
                            5.heightBox,
                            "\$600".text.color(redColor).fontFamily(bold).make(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  20.heightBox,
                ],
              ),
            ),
          ),

          // Add to Cart Button
          Container(
            height: 60,
            color: darkFontGrey,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: redColor,
                    child: "Add to Cart".text.white.fontFamily(bold).make().centered(),
                  ).onTap(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      default:
        return Colors.grey;
    }
  }
}