import 'package:emart_app/consts/lists.dart';
import 'package:emart_app/views/category_screen/category_screen.dart';
import 'package:emart_app/views/home_screen/components/featured_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/home_controller.dart';
import 'package:emart_app/views/category_screen/category_details_screen.dart';
import 'package:emart_app/views/category_screen/item_details.dart';
import 'package:emart_app/widgets_common/home_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: searchAny,
                    hintStyle: const TextStyle(color: textfieldGrey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // First Slider (keeping static as requested)
              VxSwiper.builder(
                aspectRatio: 16 / 9,
                autoPlay: true,
                height: 180,
                enlargeCenterPage: true,
                itemCount: slidersList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle slider tap if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          slidersList[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // First Row of Buttons (dynamic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Today's Deals
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: homeButtons(
                            height: context.screenHeight * 0.12,
                            width: context.screenWidth / 2.3,
                            icon: const Icon(Icons.local_offer,
                                size: 30, color: Colors.black),
                            title: todayDeal,
                            onTap: () {
                              Get.to(() => const CategoryDetailsScreen(
                                    categoryId: "today_deals",
                                    title: todayDeal,
                                  ));
                            },
                            count: controller.todayDeals.length,
                          ),
                        )),

                    // Flash Sale
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: homeButtons(
                            height: context.screenHeight * 0.12,
                            width: context.screenWidth / 2.3,
                            icon: const Icon(Icons.flash_on,
                                size: 30, color: Colors.black),
                            title: flashSale,
                            onTap: () {
                              Get.to(() => const CategoryDetailsScreen(
                                    categoryId: "flash_sale",
                                    title: flashSale,
                                  ));
                            },
                            count: controller.flashSales.length,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Second Slider (keeping static as requested)
              VxSwiper.builder(
                aspectRatio: 16 / 9,
                autoPlay: true,
                height: 180,
                enlargeCenterPage: true,
                itemCount: secSlidersList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle slider tap if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          secSlidersList[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Second Row of Buttons (dynamic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Categories
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: homeButtons(
                            height: context.screenHeight * 0.12,
                            width: context.screenWidth / 3.5,
                            icon: const Icon(Icons.category,
                                size: 30, color: Colors.black),
                            title: topCategories,
                            onTap: () {
                              Get.to(() => const CategoryScreen(
                                  title: '', categoryId: ''));
                            },
                            count: controller.topCategories.length,
                          ),
                        )),

                    // Brands
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: homeButtons(
                            height: context.screenHeight * 0.12,
                            width: context.screenWidth / 3.5,
                            icon: const Icon(Icons.branding_watermark,
                                size: 30, color: Colors.black),
                            title: brand,
                            onTap: () {
                              Get.to(() => const CategoryDetailsScreen(
                                    categoryId: "brands",
                                    title: brand,
                                  ));
                            },
                            count: controller.featuredCategories.length,
                          ),
                        )),

                    // Top Sellers
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: homeButtons(
                            height: context.screenHeight * 0.12,
                            width: context.screenWidth / 3.5,
                            icon: const Icon(Icons.people,
                                size: 30, color: Colors.black),
                            title: topSellers,
                            onTap: () {
                              Get.to(() => const CategoryDetailsScreen(
                                    categoryId: "top_sellers",
                                    title: topSellers,
                                  ));
                            },
                            count: controller.topSellers.length,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

             // Featured Categories
const Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Text(
      featuredCategories,
      style: TextStyle(
        color: darkFontGrey,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 16),

// Featured Categories Grid in two rows
Column(
  children: [
    // First row (3 items)
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeaturedCategoryButton(
            icon: Icons.branding_watermark,
            title: brand,
            onTap: () {
              Get.to(() => const CategoryDetailsScreen(
                    categoryId: "brands",
                    title: brand,
                  ));
            },
          ),
          _buildFeaturedCategoryButton(
            icon: Icons.people,
            title: topSellers,
            onTap: () {
              Get.to(() => const CategoryDetailsScreen(
                    categoryId: "top_sellers",
                    title: topSellers,
                  ));
            },
          ),
          _buildFeaturedCategoryButton(
            icon: Icons.local_offer,
            title: todayDeal,
            onTap: () {
              Get.to(() => const CategoryDetailsScreen(
                    categoryId: "today_deals",
                    title: todayDeal,
                  ));
            },
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    // Second row (2 items)
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeaturedCategoryButton(
            icon: Icons.category,
            title: topCategories,
            onTap: () {
              Get.to(() => const CategoryScreen(
                    title: topCategories,
                    categoryId: "top_categories",
                  ));
            },
          ),
          _buildFeaturedCategoryButton(
            icon: Icons.flash_on,
            title: flashSale,
            onTap: () {
              Get.to(() => const CategoryDetailsScreen(
                    categoryId: "flash_sale",
                    title: flashSale,
                  ));
            },
          ),
          _buildFeaturedCategoryButton(
            icon: Icons.flash_on,
            title: flashSale,
            onTap: () {
              Get.to(() => const CategoryDetailsScreen(
                    categoryId: "flash_sale",
                    title: flashSale,
                  ));
            },
          ),
        
        ],
      ),
    ),
  ],
),
              const SizedBox(height: 24),

              // Featured Products (dynamic)
              Obx(
                () => controller.featuredProducts.isEmpty
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () {
                          Get.to(() => const CategoryDetailsScreen(
                                categoryId: "featured", // Adjust as needed
                                title: "Featured Products",
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: redColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Featured Product",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: controller.featuredProducts
                                      .take(6)
                                      .map((product) {
                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(() => ItemDetails(
                                              title: product.name,
                                              productId: product.id,
                                            ));
                                      },
                                      child: Container(
                                        width: 160,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  product.imageUrl,
                                                  height: 120,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(imgP1,
                                                          height: 120,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: darkFontGrey,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                product.sale != null
                                                    ? "\$${product.salePrice?.toStringAsFixed(2)}"
                                                    : "\$${product.price.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  color: redColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (product.sale != null)
                                                Text(
                                                  "\$${product.price.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Third Slider (keeping static as requested)
              VxSwiper.builder(
                aspectRatio: 16 / 9,
                autoPlay: true,
                height: 180,
                enlargeCenterPage: true,
                itemCount: slidersList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle slider tap if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          slidersList[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Top Sellers Section
              Obx(() {
                return Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: redColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Top Sellers",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Content
                      controller.topSellers.isEmpty
                          ? _buildEmptyPlaceholder()
                          : _buildProductsRow(controller),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoryButton({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: redColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkFontGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.store_mall_directory,
                color: Colors.white.withOpacity(0.5), size: 40),
            const SizedBox(height: 8),
            Text(
              "No top sellers available",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Check back later!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsRow(HomeController controller) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.topSellers.take(6).map((product) {
              return GestureDetector(
                onTap: () => Get.to(() => ItemDetails(
                      title: product.name,
                      productId: product.id,
                    )),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              imgP1,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Product Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkFontGrey,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: redColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (product.salePrice != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "\$${product.salePrice!.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (controller.topSellers.length > 6)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.to(() => const CategoryDetailsScreen(
                      categoryId: "top_sellers",
                      title: "All Top Sellers",
                    ));
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
