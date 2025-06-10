import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'product_detail_screen.dart';
import 'create_product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const ProductsScreen({super.key, required this.prefs});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen(prefs: widget.prefs)),
      );
    }
  }

  Future<void> _navigateToCreateProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateProductScreen()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _navigateToProductDetail(Product product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productId: product.id,
          prefs: widget.prefs,
        ),
      ),
    );
    
    // Always refresh the list when returning from detail screen
    _loadProducts();
    
    if (mounted) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateProduct,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Created At')),
                      DataColumn(label: Text('Updated At')),
                    ],
                    rows: _products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(Text(product.id.toString())),
                          DataCell(Text(product.title)),
                          DataCell(Text(product.description)),
                          DataCell(Text(product.createdAt.toString())),
                          DataCell(Text(product.updatedAt.toString())),
                        ],
                        onSelectChanged: (_) => _navigateToProductDetail(product),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
} 