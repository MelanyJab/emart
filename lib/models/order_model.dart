// models/order_model.dart
import 'package:emart_app/models/cart_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<CartModel> items;
  final double totalAmount;
  late final String status; 
  final DateTime createdAt;
  final String? shippingAddress;
  final String? paymentMethod;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.shippingAddress,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['userId'],
      userEmail: map['userEmail'],
      items: List<CartModel>.from(
          map['items'].map((item) => CartModel.fromMap(item))),
      totalAmount: map['totalAmount'],
      status: map['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      shippingAddress: map['shippingAddress'],
      paymentMethod: map['paymentMethod'],
    );
  }
}