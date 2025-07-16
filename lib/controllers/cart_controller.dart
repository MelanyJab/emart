// controllers/cart_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/models/cart_model.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var cartItems = <CartModel>[].obs;
  var isLoading = false.obs;
  var totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: user.uid)
          .get();

      cartItems.assignAll(
        snapshot.docs.map((doc) => CartModel.fromMap(doc.data())).toList(),
      );

      calculateTotal();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cart items: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

 Future<void> addToCart(ProductModel product, {int quantity = 1, String? selectedColor}) async {
  try {
    isLoading(true);
    final user = Get.find<AuthController>().currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please login first');
      return;
    }

    // Check if product already exists in cart
    final existingItemIndex = cartItems.indexWhere(
      (item) => item.productId == product.id && item.selectedColor == selectedColor,
    );

    if (existingItemIndex >= 0) {
      // Update quantity if item exists
      final existingItem = cartItems[existingItemIndex];
      await _firestore
          .collection('cart')
          .doc('${user.uid}_${product.id}_$selectedColor')
          .update({
        'quantity': existingItem.quantity + quantity,
      });
    } else {
      // Add new item to cart
      final cartItem = CartModel(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        quantity: quantity,
        colors: product.colors,
        selectedColor: selectedColor,
        sale: product.sale,
      );

      await _firestore
          .collection('cart')
          .doc('${user.uid}_${product.id}_$selectedColor')
          .set({
        ...cartItem.toMap(),
        'userId': user.uid,
      });
    }

    await fetchCartItems();
    Get.closeCurrentSnackbar(); // Close any existing snackbar
    Get.snackbar(
      'Success',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  } catch (e) {
    Get.closeCurrentSnackbar(); // Close any existing snackbar
    Get.snackbar(
      'Error', 
      'Failed to add to cart: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading(false);
  }
}
  Future<void> removeFromCart(String productId, {String? selectedColor}) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return;

      await _firestore
          .collection('cart')
          .doc('${user.uid}_${productId}_$selectedColor')
          .delete();

      await fetchCartItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove from cart: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity, {String? selectedColor}) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return;

      if (newQuantity <= 0) {
        await removeFromCart(productId, selectedColor: selectedColor);
        return;
      }

      await _firestore
          .collection('cart')
          .doc('${user.uid}_${productId}_$selectedColor')
          .update({
        'quantity': newQuantity,
      });

      await fetchCartItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update quantity: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void calculateTotal() {
    totalPrice.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  void clearCart() {
    cartItems.clear();
    totalPrice.value = 0.0;
  }
}