import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> files;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrls,
    required this.files,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['files'] != null && json['files'] is List) {
      urls = (json['files'] as List)
          .map((file) {
            final url = file['url'] as String;
            return '${dotenv.env['API_URL']}$url';
          })
          .toList();
    }

    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      imageUrls: urls,
      files: List<Map<String, dynamic>>.from(json['files'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 