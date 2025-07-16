// In product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> categoryIds;  
  final List<String> colors;
  final double rating;
  final DateTime createdAt;
  final double? sale;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categoryIds = const [],  
    this.colors = const [],
    this.rating = 0.0,
    required this.createdAt,
    this.sale,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      categoryIds: List<String>.from(data['categoryIds'] ?? []),  
      colors: List<String>.from(data['colors'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sale: (data['sale'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryIds': categoryIds,  
      'colors': colors,
      'rating': rating,
      'createdAt': createdAt,
      'sale': sale,
    };
  }
   // Helper method to calculate sale price
  double? get salePrice {
    if (sale == null) return null;
    return price * (1 - (sale! / 100));
  }
}