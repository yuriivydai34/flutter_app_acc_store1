import 'package:flutter_app_acc_store1/models/product.dart';

class Order {
  final int id;
  final int productId;
  final String? cashReceiptId;
  final Product? product;

  Order({
    required this.id,
    required this.productId,
    this.cashReceiptId,
    this.product,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      productId: json['product']?['id'] as int? ?? 0,
      cashReceiptId: json['cash_receipt_id'] as String?,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'cash_receipt_id': cashReceiptId,
    };
  }
} 