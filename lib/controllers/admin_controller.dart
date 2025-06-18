import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/models/category_model.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin Methods
  Future<void> addAdminUser(String email, String name) async {
    try {
      await _firestore.collection('admins').doc(email).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Admin $email added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser;
      if (user == null || user.email == null) return false;

      final doc = await _firestore.collection('admins').doc(user.email).get();
      return doc.exists;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check admin status: ${e.toString()}');
      return false;
    }
  }

  Future<void> removeAdmin(String email) async {
    try {
      await _firestore.collection('admins').doc(email).delete();
      Get.snackbar('Success', 'Admin privileges removed');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Category Methods
  Future<void> addCategory(String name, String imageUrl) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'imageUrl': imageUrl, // Will be replaced with actual URL after upload
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: ${e.toString()}');
      return [];
    }
  }

  Future<void> updateCategory(String id, String newName) async {
    try {
      await _firestore.collection('categories').doc(id).update({
        'name': newName,
      });
      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  //Products Methods
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    List<String> colors = const [],
  }) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'colors': colors,
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: ${e.toString()}');
      return [];
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    List<String> colors = const [],
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'colors': colors,
      });
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
