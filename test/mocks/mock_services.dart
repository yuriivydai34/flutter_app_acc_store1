import 'package:flutter_app_acc_store1/models/product.dart';
import 'package:flutter_app_acc_store1/services/product_service.dart';
import 'package:flutter_app_acc_store1/services/auth_service.dart';

class MockProductService extends ProductService {
  List<Product> _products = [
    Product(
      id: 1,
      title: 'Test Product 1',
      description: 'Description 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrls: [],
      files: [],
    ),
    Product(
      id: 2,
      title: 'Test Product 2',
      description: 'Description 2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrls: [],
      files: [],
    ),
  ];

  @override
  Future<List<Product>> getProducts() async {
    return _products;
  }

  @override
  Future<Product> getProduct(int id) async {
    return _products.firstWhere((p) => p.id == id);
  }

  @override
  Future<Product> createProduct(String title, String description) async {
    final newProduct = Product(
      id: _products.length + 1,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrls: [],
      files: [],
    );
    _products.add(newProduct);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(int id, String title, String description) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Product not found');
    
    final updatedProduct = Product(
      id: id,
      title: title,
      description: description,
      createdAt: _products[index].createdAt,
      updatedAt: DateTime.now(),
      imageUrls: _products[index].imageUrls,
      files: _products[index].files,
    );
    _products[index] = updatedProduct;
    return updatedProduct;
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
  }
}

class MockAuthService extends AuthService {
  bool _isAuthenticated = false;
  bool _isAdmin = false;

  @override
  Future<String?> getToken() async {
    return _isAuthenticated ? 'mock_token' : null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  void setAdmin(bool value) {
    _isAdmin = value;
  }
} 