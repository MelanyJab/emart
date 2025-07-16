import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/consts/lists.dart';
import 'package:emart_app/controllers/cart_controller.dart';
import 'package:emart_app/controllers/favorite_controller.dart';
import 'package:emart_app/models/favorite_model.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ItemDetails extends StatefulWidget {
  final String productId;
  final String? title;
  const ItemDetails({Key? key, required this.title, required this.productId})
      : super(key: key);

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int selectedColorIndex = 0;
  int quantity = 1;
  bool isFavorite = false;
  ProductModel? product;

  @override
  void initState() {
    super.initState();
    _loadProduct();

    // Initialize favorite status
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final favoriteController = Get.find<FavoriteController>();
    favoriteController.fetchFavorites(); // Ensure favorites are loaded
  });
  }

  Future<void> _loadProduct() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        setState(() {
          product = ProductModel.fromMap(doc.data()!, doc.id);
          if (product!.colors.isNotEmpty) {
            selectedColorIndex = 0;
          }
        });
      } else {
        Get.snackbar('Error', 'Product not found');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product details');
      Get.back();
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
                const Text(
                  "Share Product",
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: darkFontGrey,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Copy the link below to share this product:",
                  style: TextStyle(color: darkFontGrey),
                ),
                const SizedBox(height: 15),
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
                        child: Text(
                          shareLink,
                          style: const TextStyle(
                            fontSize: 12,
                            color: darkFontGrey,
                          ),
                        ),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>   Navigator.of(context, rootNavigator: true).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double get _currentPrice {
    if (product == null) return 0;
    if (product!.sale != null) {
      return product!.price * (1 - (product!.sale! / 100));
    }
    return product!.price;
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        backgroundColor: lightGrey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.back(); // Fallback to GetX navigation
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: lightGrey,
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
        actions: [
          IconButton(
            onPressed: _showShareModal,
            icon: const Icon(Icons.share, color: darkFontGrey),
          ),
            Obx(() {
    final favoriteController = Get.find<FavoriteController>();
    final isFavorite = favoriteController.isFavorite(product!.id);
    return IconButton(
      onPressed: () {
        favoriteController.toggleFavorite(
          FavoriteModel(
            productId: product!.id,
            name: product!.name,
            imageUrl: product!.imageUrl,
            price: product!.price,
            sale: product!.sale,
            colors: product!.colors,
          ),
        );
      },
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : darkFontGrey,
      ),
    );
  }),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product!.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 100, color: Colors.grey[400])),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: bold,
                          color: darkFontGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                          const SizedBox(width: 10),
                          Text(
                            "(${product!.rating.toStringAsFixed(1)})",
                            style: const TextStyle(color: darkFontGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (product!.sale != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "\$${product!.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontFamily: regular,
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: redColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${product!.sale!.toStringAsFixed(0)}% OFF",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "\$${_currentPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: redColor,
                                fontFamily: bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          "\$${product!.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: redColor,
                            fontFamily: bold,
                            fontSize: 22,
                          ),
                        ),
                    ],
                  ),

                  // Color Selection
                  if (product!.colors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Color:",
                          style: TextStyle(color: darkFontGrey),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: List.generate(
                            product!.colors.length,
                            (index) => GestureDetector(
                              onTap: () =>
                                  setState(() => selectedColorIndex = index),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getColorFromString(
                                      product!.colors[index]),
                                  shape: BoxShape.circle,
                                  border: selectedColorIndex == index
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                                ),
                                child: selectedColorIndex == index
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Quantity
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quantity:",
                        style: TextStyle(color: darkFontGrey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() {
                              if (quantity > 1) quantity--;
                            }),
                            icon: const Icon(Icons.remove),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: darkFontGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add),
                          ),
                          const Spacer(),
                          Text(
                            "Total: \$${(_currentPrice * quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: redColor,
                              fontFamily: bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Description
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontFamily: bold,
                          color: darkFontGrey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product!.description,
                        style: const TextStyle(color: darkFontGrey),
                      ),
                    ],
                  ),

                  // Features
                  const SizedBox(height: 20),
                  Column(
                    children: itemDetailButtonsList
                        .map((item) => ListTile(
                              title: Text(
                                item,
                                style: const TextStyle(
                                  fontFamily: semibold,
                                  color: darkFontGrey,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                            ))
                        .toList(),
                  ),

                  // Related Products
                  const SizedBox(height: 20),
                  const Text(
                    "You may also like",
                    style: TextStyle(
                      fontFamily: bold,
                      fontSize: 16,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            Image.asset(imgP1,
                                height: 120, width: 150, fit: BoxFit.cover),
                            const SizedBox(height: 10),
                            Text(
                              "Product $index",
                              style: const TextStyle(
                                fontFamily: semibold,
                                color: darkFontGrey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "\$600",
                              style: TextStyle(
                                color: redColor,
                                fontFamily: bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Add to Cart Button
          // Replace your existing Add to Cart button section with this:
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    // Add SizedBox to constrain width
                    child: ElevatedButton(
                      onPressed: () {
                        if (product == null) return;

                        try {
                          final cartController = Get.find<CartController>();
                          cartController.addToCart(
                            product!,
                            quantity: quantity,
                            selectedColor: product!.colors.isNotEmpty
                                ? product!.colors[selectedColorIndex]
                                : null,
                          );
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            "Failed to add to cart",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8), // Reduced spacing
                          Flexible(
                            // Use Flexible to prevent overflow
                            child: Text(
                              "Add to Cart",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'grey':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
