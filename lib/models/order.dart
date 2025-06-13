class Order {
  final int productId;

  Order({
    required this.productId
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      productId: json['product_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
    };
  }
} 