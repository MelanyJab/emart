import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/models/category_model.dart';
import 'package:emart_app/models/order_model.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:flutter/foundation.dart';
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


  // In admin_controller.dart
Future<void> addProduct({
  required String name,
  required String description,
  required double price,
  required String imageUrl,
  List<String> categoryIds = const [],  
  List<String> colors = const [],
  double? sale,
}) async {
  try {
    await _firestore.collection('products').add({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryIds': categoryIds,  
      'colors': colors,
      'rating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'sale': sale,
    });
    Get.snackbar('Success', 'Product added successfully');
  } catch (e) {
    Get.snackbar('Error', e.toString());
  }
}

Future<void> updateProduct({
  required String productId,
  required String name,
  required String description,
  required double price,
  List<String> categoryIds = const [],  
  List<String> colors = const [],
  double? sale,
}) async {
  try {
    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'description': description,
      'price': price,
      'categoryIds': categoryIds,  
      'colors': colors,
      'sale': sale,
    });
    Get.snackbar('Success', 'Product updated successfully');
  } catch (e) {
    Get.snackbar('Error', e.toString());
  }
}

 

  Future<void> deleteProduct(String productId) async {
    try {
      // Verify document exists first
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw 'Product not found';
      }

      await _firestore.collection('products').doc(productId).delete();

      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e, stackTrace) {
      debugPrint('Delete error: $e');
      debugPrint('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to delete: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    }
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .limit(6)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch featured products');
      return [];
    }
  }

  Future<List<ProductModel>> getTodayDeals() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isTodayDeal', isEqualTo: true)
          .limit(6)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch today deals');
      return [];
    }
  }

  Future<List<ProductModel>> getFlashSales() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isFlashSale', isEqualTo: true)
          .limit(6)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch flash sales');
      return [];
    }
  }

  Future<List<ProductModel>> getTopSellers() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isTopSeller', isEqualTo: true)
          .limit(6)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch top sellers');
      return [];
    }
  }

  Future<List<ProductModel>> getTopCategories() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isTopCategory', isEqualTo: true)
          .limit(6)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch top categories');
      return [];
    }
  }

  // Orders
  Future<List<OrderModel>> getAllOrders() async {
  try {
    final snapshot = await _firestore.collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    Get.snackbar('Error', 'Failed to fetch orders: ${e.toString()}');
    return [];
  }
}
FirebaseFirestore get firestore => _firestore;

Future<Map<String, dynamic>> getOrderStats() async {
  try {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    // Get monthly orders
    final monthlySnapshot = await _firestore.collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth.millisecondsSinceEpoch)
        .get();
    
    // Get all-time stats
    final totalSnapshot = await _firestore.collection('orders').get();
    
    return {
      'monthlyOrders': monthlySnapshot.docs.length,
      'totalOrders': totalSnapshot.docs.length,
      'monthlyRevenue': monthlySnapshot.docs.fold(0.0, (sum, doc) => sum! + doc['totalAmount']),
      'totalRevenue': totalSnapshot.docs.fold(0.0, (sum, doc) => sum! + doc['totalAmount']),
    };
  } catch (e) {
    Get.snackbar('Error', 'Failed to fetch order stats: ${e.toString()}');
    return {};
  }
}
}

extension on Object {
  operator +(other) {}
}
