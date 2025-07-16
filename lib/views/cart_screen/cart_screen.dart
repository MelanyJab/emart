import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/cart_controller.dart';
import 'package:emart_app/views/category_screen/category_screen.dart';
import 'package:emart_app/views/home_screen/home_screen.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return bgWidget(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 187, 187, 187),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          title: "Shopping Cart"
              .text
              .fontFamily(bold)
              .white
              .size(25)
              .make(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: cartController.clearCart,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ],
        ),
        body: Obx(() {
          if (cartController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          }

          if (cartController.cartItems.isEmpty) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Empty Cart Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  
                  30.heightBox,
                  
                  // Empty Cart Title
                  "Your Cart is Empty"
                      .text
                      .fontFamily(bold)
                      .white
                      .size(24)
                      .make(),
                  
                  15.heightBox,
                  
                  // Empty Cart Subtitle
                  "Looks like you haven't added\nanything to your cart yet"
                      .text
                      .fontFamily(semibold)
                      .white
                      .size(16)
                      .textStyle(const TextStyle(height: 1.5))
                      .center
                      .make(),
                  
                  50.heightBox,
                  
                  // Start Shopping Button
                  SizedBox(
                    width: context.screenWidth - 60,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const HomeScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: "Start Shopping"
                          .text
                          .white
                          .fontFamily(bold)
                          .size(16)
                          .make(),
                    ),
                  ),
                  
                  20.heightBox,
                  
                  // Browse Categories Button
                  SizedBox(
                    width: context.screenWidth - 60,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const CategoryScreen(title: '', categoryId: ''));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: "Browse Categories"
                          .text
                          .white
                          .fontFamily(semibold)
                          .size(16)
                          .make(),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: darkFontGrey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.selectedColor != null)
                                    Text(
                                      "Color: ${item.selectedColor}",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  Text(
                                    "\$${item.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: redColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity Controls
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    cartController.updateQuantity(
                                      item.productId,
                                      item.quantity - 1,
                                      selectedColor: item.selectedColor,
                                    );
                                  },
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartController.updateQuantity(
                                      item.productId,
                                      item.quantity + 1,
                                      selectedColor: item.selectedColor,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Checkout Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Subtotal:".text.size(16).color(darkFontGrey).make(),
                        "\$${cartController.totalPrice.value.toStringAsFixed(2)}"
                            .text.size(16).fontFamily(bold).color(redColor).make(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Shipping:".text.size(16).color(darkFontGrey).make(),
                        "\$0.00".text.size(16).color(darkFontGrey).make(),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Total:".text.size(18).fontFamily(bold).color(darkFontGrey).make(),
                        "\$${cartController.totalPrice.value.toStringAsFixed(2)}"
                            .text.size(18).fontFamily(bold).color(redColor).make(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            "Checkout", 
                            "Proceeding to checkout",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: "Proceed to Checkout"
                            .text
                            .white
                            .fontFamily(bold)
                            .size(16)
                            .make(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}