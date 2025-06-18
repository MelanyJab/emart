import 'package:emart_app/views/category_screen/category_screen.dart';
import 'package:emart_app/views/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        backgroundColor: Colors.red,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: "Shopping Cart"
              .text
              .fontFamily(bold)
              .white
              .size(25)
              .make(),
          centerTitle: true,
        ),
        body: SizedBox(
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
                    // Navigate back to home or products page
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
                    // Navigate to categories page
                   Get.to(() => const CategoryScreen());
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
        ),
      ),
    );
  }
}