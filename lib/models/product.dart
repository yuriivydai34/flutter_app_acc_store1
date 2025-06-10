import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['files'] != null && 
        json['files'] is List) {
      urls = (json['files'] as List)
          .map((file) {
            final url = file['url'] as String;
            return '${dotenv.env['API_URL']}${url}';
          })
          .toList();
    }
    
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrls: urls,
    );
  }
} 