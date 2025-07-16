import 'package:emart_app/consts/colors.dart';
import 'package:emart_app/consts/styles.dart';
import 'package:emart_app/controllers/favorite_controller.dart';
import 'package:emart_app/views/category_screen/category_screen.dart';
import 'package:emart_app/views/home_screen/home_screen.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController = Get.put(FavoriteController());

    return bgWidget(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 187, 187, 187),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: "My Favorites".text.fontFamily(bold).white.size(25).make(),
          centerTitle: true,
        ),
        body: Obx(() {
          if (favoriteController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          }

         if (favoriteController.favorites.isEmpty) {
  return _buildEmptyFavorites(context); // Pass the context here
}

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteController.favorites.length,
            itemBuilder: (context, index) {
              final favorite = favoriteController.favorites[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.white.withOpacity(0.9),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      favorite.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(favorite.name),
                  subtitle: Text("\$${favorite.price.toStringAsFixed(2)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      favoriteController.toggleFavorite(favorite);
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Empty Favorites Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_border,
            size: 60,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        
        30.heightBox,
        
        // Empty Favorites Title
        "Your Favorites is Empty"
            .text
            .fontFamily(bold)
            .white
            .size(24)
            .make(),
        
        15.heightBox,
        
        // Empty Favorites Subtitle
        "Looks like you haven't added\nanything to your favorites yet"
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
          width: MediaQuery.of(context).size.width - 60,
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
          width: MediaQuery.of(context).size.width - 60,
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
}