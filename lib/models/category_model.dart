// models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
  return CategoryModel(
    id: id,
    name: data['name'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}