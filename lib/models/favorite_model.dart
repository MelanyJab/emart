// models/favorite_model.dart
class FavoriteModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final double? sale;
  final List<String>? colors;

  FavoriteModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.sale,
    this.colors,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'sale': sale,
      'colors': colors,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      productId: map['productId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      sale: map['sale'],
      colors: List<String>.from(map['colors'] ?? []),
    );
  }
}