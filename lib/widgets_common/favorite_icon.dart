// Create a new file favorite_icon.dart
import 'package:emart_app/controllers/favorite_controller.dart';
import 'package:emart_app/models/favorite_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteIcon extends StatelessWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final double? sale;
  final List<String>? colors;
  final double size;

  const FavoriteIcon({
    Key? key,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.sale,
    this.colors,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      final isFavorite = favoriteController.isFavorite(productId);
      return IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
          size: size,
        ),
        onPressed: () {
          favoriteController.toggleFavorite(
            FavoriteModel(
              productId: productId,
              name: name,
              imageUrl: imageUrl,
              price: price,
              sale: sale,
              colors: colors,
            ),
          );
        },
      );
    });
  }
}