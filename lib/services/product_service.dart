import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductService {
  final AuthService _authService = AuthService();

  Future<String?> _getAuthHeader() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return 'Bearer $token';
  }

  Future<List<Product>> getProducts() async {
    try {
      final authHeader = await _getAuthHeader();
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final authHeader = await _getAuthHeader();
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/product/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader!,
        },
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to load product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Product> createProduct(String title, String description) async {
    try {
      final authHeader = await _getAuthHeader();
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader!,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to create product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Product> updateProduct(int id, String title, String description) async {
    try {
      final authHeader = await _getAuthHeader();
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/product/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader!,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        // After successful update, fetch the updated product
        return await getProduct(id);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final authHeader = await _getAuthHeader();
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/product/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader!,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
} 