// controllers/favorite_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/models/favorite_model.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var favorites = <FavoriteModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      favorites.assignAll(
        snapshot.docs.map((doc) => FavoriteModel.fromMap(doc.data())).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorites: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleFavorite(FavoriteModel product) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      final docRef = _firestore
          .collection('favorites')
          .doc('${user.uid}_${product.productId}');

      final isFavorite = favorites.any((fav) => fav.productId == product.productId);

      if (isFavorite) {
        await docRef.delete();
        favorites.removeWhere((fav) => fav.productId == product.productId);
        Get.snackbar('Removed', 'Removed from favorites');
      } else {
        await docRef.set({
          ...product.toMap(),
          'userId': user.uid,
        });
        favorites.add(product);
        Get.snackbar('Added', 'Added to favorites');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  bool isFavorite(String productId) {
    return favorites.any((fav) => fav.productId == productId);
  }
}