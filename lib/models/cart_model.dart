// models/cart_model.dart
class CartModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final List<String>? colors;
  final String? selectedColor;
  final double? sale;

  CartModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.colors,
    this.selectedColor,
    this.sale,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'colors': colors,
      'selectedColor': selectedColor,
      'sale': sale,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      quantity: map['quantity'],
      colors: List<String>.from(map['colors'] ?? []),
      selectedColor: map['selectedColor'],
      sale: map['sale'],
    );
  }

  double get totalPrice {
    if (sale != null) {
      return price * (1 - (sale! / 100)) * quantity;
    }
    return price * quantity;
  }
}